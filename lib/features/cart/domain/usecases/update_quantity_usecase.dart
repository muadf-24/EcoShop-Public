import '../repositories/cart_repository.dart';

class UpdateQuantityUseCase {
  final CartRepository repository;
  UpdateQuantityUseCase(this.repository);
  Future<void> call(String itemId, int quantity) =>
      repository.updateQuantity(itemId, quantity);
}
