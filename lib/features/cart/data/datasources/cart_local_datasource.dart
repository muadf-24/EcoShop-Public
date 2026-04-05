import '../../domain/entities/cart_item.dart';
import '../models/cart_item_model.dart';

/// In-memory local data source for cart
class CartLocalDataSource {
  final List<CartItemModel> _items = [];

  List<CartItemModel> getItems() => List.unmodifiable(_items);

  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere((i) => i.productId == item.productId);
    if (existingIndex >= 0) {
      final existing = _items[existingIndex];
      _items[existingIndex] = CartItemModel(
        id: existing.id,
        productId: existing.productId,
        productName: existing.productName,
        productImage: existing.productImage,
        price: existing.price,
        quantity: existing.quantity + item.quantity,
        selectedSize: item.selectedSize ?? existing.selectedSize,
        selectedColor: item.selectedColor ?? existing.selectedColor,
      );
    } else {
      _items.add(CartItemModel.fromEntity(item));
    }
  }

  void removeItem(String itemId) {
    _items.removeWhere((i) => i.id == itemId);
  }

  void updateQuantity(String itemId, int quantity) {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index >= 0) {
      final item = _items[index];
      _items[index] = CartItemModel(
        id: item.id,
        productId: item.productId,
        productName: item.productName,
        productImage: item.productImage,
        price: item.price,
        quantity: quantity,
        selectedSize: item.selectedSize,
        selectedColor: item.selectedColor,
      );
    }
  }

  void clearAll() => _items.clear();
}
