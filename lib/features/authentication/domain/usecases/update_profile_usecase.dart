import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<User> call({
    required String name,
    required String email,
    String? phone,
    String? avatarUrl,
  }) {
    return repository.updateProfile(
      name: name,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl,
    );
  }
}
