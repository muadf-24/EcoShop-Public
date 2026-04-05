import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../../../core/utils/error_message_handler.dart';

/// Remote data source for auth using Firebase
class AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSource({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  /// Map Firebase User to UserModel
  Future<UserModel> _mapFirebaseUser(firebase_auth.User user, {String? defaultName}) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        return UserModel(
          id: user.uid,
          name: data['name'] as String? ?? user.displayName ?? defaultName ?? 'User',
          email: user.email ?? '',
          phone: data['phone'] as String?,
          avatarUrl: data['avatar_url'] as String? ?? user.photoURL,
          createdAt: user.metadata.creationTime,
        );
      }
    } catch (_) {
      // If Firestore is unavailable, use Firebase Auth data only
    }

    return UserModel(
      id: user.uid,
      name: user.displayName ?? defaultName ?? 'User',
      email: user.email ?? '',
      avatarUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  /// Login via Firebase Auth
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw Exception('Login failed: User is null');
      }

      return _mapFirebaseUser(userCredential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      final userMessage = ErrorMessageHandler.getUserFriendlyAuthMessage(e.code);
      throw Exception(userMessage);
    }
  }

  /// Register via Firebase Auth
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Registration failed: User is null');
      }

      // ✅ FIX: Add timeout for Web to prevent hanging
      try {
        await user.updateDisplayName(name).timeout(
          const Duration(seconds: 5),
          onTimeout: () => {},
        );
      } catch (_) {
        // Non-critical if updateDisplayName fails
      }

      try {
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'created_at': FieldValue.serverTimestamp(),
        }).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            // Log and continue - the user is still created in Auth
            return Future.value();
          },
        );
      } catch (_) {
        // Continue if Firestore fails - critical for Web reliability
      }

      // ✅ CRITICAL FIX for Web: Return directly instead of calling _mapFirebaseUser
      // This avoids a redundant Firestore 'get' which often hangs on Web right after a 'set'
      return UserModel(
        id: user.uid,
        name: name,
        email: email,
        avatarUrl: user.photoURL,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      final userMessage = ErrorMessageHandler.getUserFriendlyAuthMessage(e.code);
      throw Exception(userMessage);
    }
  }

  /// Logout
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  /// Check current user
  Future<UserModel?> checkAuth() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return _mapFirebaseUser(user);
  }

  /// Password reset
  Future<void> forgotPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to send password reset email');
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No user logged in');
      if (!user.emailVerified) await user.sendEmailVerification();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Email verification failed');
    }
  }

  /// Check if email is verified
  Future<bool> isEmailVerified() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No user logged in');
      await user.reload();
      return _firebaseAuth.currentUser?.emailVerified ?? false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to check verification status');
    }
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('User is not logged in');

      if (name != user.displayName) await user.updateDisplayName(name);
      if (email != user.email) await user.verifyBeforeUpdateEmail(email);
      if (avatarUrl != null) await user.updatePhotoURL(avatarUrl);

      try {
        final updateData = {
          'name': name,
          'email': email,
          'updated_at': FieldValue.serverTimestamp(),
        };
        if (phone != null) updateData['phone'] = phone;
        if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

        await _firestore.collection('users').doc(user.uid).set(
          updateData,
          SetOptions(merge: true),
        );
      } catch (_) {
        // Continue if Firestore fails
      }

      return _mapFirebaseUser(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to update profile');
    }
  }
}
