import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class CartLoadRequested extends CartEvent {}

class CartItemAdded extends CartEvent {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  const CartItemAdded({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    this.quantity = 1,
  });
  @override
  List<Object?> get props => [productId, productName, price, quantity];
}

class CartItemRemoved extends CartEvent {
  final String itemId;
  const CartItemRemoved(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

class CartItemQuantityUpdated extends CartEvent {
  final String itemId;
  final int quantity;
  const CartItemQuantityUpdated({required this.itemId, required this.quantity});
  @override
  List<Object?> get props => [itemId, quantity];
}

class CartCleared extends CartEvent {}
