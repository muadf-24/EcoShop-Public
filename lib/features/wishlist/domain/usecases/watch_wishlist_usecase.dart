import '../entities/wishlist_item.dart';
import '../repositories/wishlist_repository.dart';

/// Use case for watching the user's wishlist in real-time.
class WatchWishlistUseCase {
  final WishlistRepository repository;

  WatchWishlistUseCase(this.repository);

  Stream<List<WishlistItem>> call() {
    return repository.getWishlistStream();
  }
}
