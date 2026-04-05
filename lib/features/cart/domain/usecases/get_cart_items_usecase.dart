import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

class GetCartItemsUseCase {
  final CartRepository repository;
  GetCartItemsUseCase(this.repository);
  Future<List<CartItem>> call() => repository.getCartItems();
}
