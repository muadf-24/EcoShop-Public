import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl({required this.localDataSource});

  @override
  Future<List<CartItem>> getCartItems() async {
    return localDataSource.getItems();
  }

  @override
  Future<void> addToCart(CartItem item) async {
    localDataSource.addItem(item);
  }

  @override
  Future<void> removeFromCart(String itemId) async {
    localDataSource.removeItem(itemId);
  }

  @override
  Future<void> updateQuantity(String itemId, int quantity) async {
    localDataSource.updateQuantity(itemId, quantity);
  }

  @override
  Future<void> clearCart() async {
    localDataSource.clearAll();
  }
}
