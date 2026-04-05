import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';

abstract class CartState extends Equatable {
  const CartState();
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> items;
  final String? lastAddedProduct; // ✅ FIX PROD-H03: Track last added product for snackbar

  const CartLoaded({this.items = const [], this.lastAddedProduct});

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  bool get isEmpty => items.isEmpty;

  // Helper to create copy with cleared message
  CartLoaded clearMessage() => CartLoaded(items: items, lastAddedProduct: null);

  @override
  List<Object?> get props => [items, lastAddedProduct];
}

class CartError extends CartState {
  final String message;
  const CartError(this.message);
  @override
  List<Object?> get props => [message];
}

// ✅ REMOVED: CartItemAddedSuccess - now using lastAddedProduct field in CartLoaded
