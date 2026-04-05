import 'package:equatable/equatable.dart';
import '../../domain/entities/wishlist_item.dart';

abstract class WishlistEvent extends Equatable {
  const WishlistEvent();

  @override
  List<Object?> get props => [];
}

class WishlistLoadRequested extends WishlistEvent {}

class WishlistProductAdded extends WishlistEvent {
  final String productId;
  final String productName;
  final String productImage;
  final double price;

  const WishlistProductAdded({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
  });

  @override
  List<Object?> get props => [productId, productName, productImage, price];
}

class WishlistProductRemoved extends WishlistEvent {
  final String productId;

  const WishlistProductRemoved(this.productId);

  @override
  List<Object?> get props => [productId];
}

class WishlistCleared extends WishlistEvent {}

class WishlistSubscriptionRequested extends WishlistEvent {}

class WishlistUpdated extends WishlistEvent {
  final List<WishlistItem> items;
  const WishlistUpdated(this.items);

  @override
  List<Object?> get props => [items];
}

class WishlistToggleProduct extends WishlistEvent {
  final String productId;
  final String productName;
  final String productImage;
  final double price;

  const WishlistToggleProduct({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
  });

  @override
  List<Object?> get props => [productId, productName, productImage, price];
}
