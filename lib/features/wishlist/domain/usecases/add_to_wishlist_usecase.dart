import '../entities/wishlist_item.dart';
import '../repositories/wishlist_repository.dart';

class AddToWishlistUseCase {
  final WishlistRepository repository;
  AddToWishlistUseCase(this.repository);

  Future<void> call(WishlistItem item) => repository.addToWishlist(item);
}
