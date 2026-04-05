import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Auth repository implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final firebase_auth.FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required firebase_auth.FirebaseAuth firebaseAuth,
  }) : _firebaseAuth = firebaseAuth;

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final user = await remoteDataSource.login(
      email: email,
      password: password,
    );
    
    // ✅ SECURITY FIX: Get real Firebase ID token with timeout for Web
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      try {
        final String? idToken = await currentUser.getIdToken().timeout(
              const Duration(seconds: 5),
              onTimeout: () => '',
            );
        if (idToken != null && idToken.isNotEmpty) {
          await localDataSource.cacheToken(idToken);
        }
      } catch (_) {}
    }
    
    await localDataSource.cacheUser(user);
    return user;
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final user = await remoteDataSource.register(
      name: name,
      email: email,
      password: password,
    );
    
    // ✅ SECURITY FIX: Get real Firebase ID token with timeout for Web
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      try {
        final String? idToken = await currentUser.getIdToken().timeout(
              const Duration(seconds: 5),
              onTimeout: () => '',
            );
        if (idToken != null && idToken.isNotEmpty) {
          await localDataSource.cacheToken(idToken);
        }
      } catch (_) {}
    }
    
    await localDataSource.cacheUser(user);
    return user;
  }

  @override
  Future<void> logout() async {
    // Clear local cache
    await localDataSource.clearCache();
    
    // Attempt Firebase logout if possible
    try {
      await firebase_auth.FirebaseAuth.instance.signOut();
    } catch (e) {
      // Ignored if firebase isn't active or fails
    }
  }

  @override
  Future<User?> checkAuth() async {
    // ✅ SECURITY FIX: Verify with Firebase, not just cache
    final firebaseUser = _firebaseAuth.currentUser;
    
    if (firebaseUser == null) {
      // User not authenticated, clear cache
      await localDataSource.clearCache();
      return null;
    }
    
    // Check if cached user matches current Firebase user
    final cachedUser = localDataSource.getCachedUser();
    if (cachedUser?.id != firebaseUser.uid) {
      // Cached user is stale, fetch fresh data
      return await remoteDataSource.checkAuth();
    }
    
    // Refresh token if needed with timeout
    try {
      final String? idToken = await firebaseUser.getIdToken().timeout(
            const Duration(seconds: 5),
            onTimeout: () => '',
          );
      if (idToken != null && idToken.isNotEmpty) {
        await localDataSource.cacheToken(idToken);
      }
    } catch (_) {}
    
    return cachedUser;
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await remoteDataSource.forgotPassword(email: email);
  }

  @override
  Future<void> sendEmailVerification() async {
    await remoteDataSource.sendEmailVerification();
  }

  @override
  Future<bool> isEmailVerified() async {
    return await remoteDataSource.isEmailVerified();
  }

  @override
  Future<User> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? avatarUrl,
  }) async {
    final user = await remoteDataSource.updateProfile(
      name: name,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl,
    );
    
    // ✅ Refresh token after profile update with timeout
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      try {
        final String? idToken = await currentUser.getIdToken(true).timeout(
              const Duration(seconds: 5),
              onTimeout: () => '',
            );
        if (idToken != null && idToken.isNotEmpty) {
          await localDataSource.cacheToken(idToken);
        }
      } catch (_) {}
    }
    
    await localDataSource.cacheUser(user);
    return user;
  }
}
