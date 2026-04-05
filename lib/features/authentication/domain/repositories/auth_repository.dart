import '../entities/user.dart';

/// Auth repository contract
abstract class AuthRepository {
  Future<User> login({required String email, required String password});
  Future<User> register({
    required String name,
    required String email,
    required String password,
  });
  Future<void> logout();
  Future<User?> checkAuth();
  Future<void> forgotPassword({required String email});
  Future<void> sendEmailVerification();
  Future<bool> isEmailVerified();
  Future<User> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? avatarUrl,
  });
}
