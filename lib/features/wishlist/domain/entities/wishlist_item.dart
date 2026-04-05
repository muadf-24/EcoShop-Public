import 'package:equatable/equatable.dart';

/// Wishlist item entity for the EcoShop wishlist system.
class WishlistItem extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final DateTime addedAt;

  const WishlistItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.addedAt,
  });

  WishlistItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    DateTime? addedAt,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, productId, productName, productImage, price, addedAt,
      ];
}
