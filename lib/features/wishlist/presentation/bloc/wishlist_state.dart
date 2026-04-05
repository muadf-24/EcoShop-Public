import 'package:equatable/equatable.dart';
import '../../domain/entities/wishlist_item.dart';

abstract class WishlistState extends Equatable {
  const WishlistState();

  @override
  List<Object?> get props => [];
}

class WishlistInitial extends WishlistState {}

class WishlistLoading extends WishlistState {}

class WishlistLoaded extends WishlistState {
  final List<WishlistItem> items;
  final String? lastActionMessage;

  const WishlistLoaded({
    required this.items,
    this.lastActionMessage,
  });

  bool isFavorite(String productId) => items.any((item) => item.productId == productId);

  @override
  List<Object?> get props => [items, lastActionMessage];

  WishlistLoaded copyWith({
    List<WishlistItem>? items,
    String? lastActionMessage,
  }) {
    return WishlistLoaded(
      items: items ?? this.items,
      lastActionMessage: lastActionMessage ?? this.lastActionMessage,
    );
  }
}

class WishlistError extends WishlistState {
  final String message;

  const WishlistError(this.message);

  @override
  List<Object?> get props => [message];
}
