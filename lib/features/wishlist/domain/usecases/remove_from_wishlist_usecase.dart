import '../repositories/wishlist_repository.dart';

class RemoveFromWishlistUseCase {
  final WishlistRepository repository;
  RemoveFromWishlistUseCase(this.repository);

  Future<void> call(String productId) => repository.removeFromWishlist(productId);
}
