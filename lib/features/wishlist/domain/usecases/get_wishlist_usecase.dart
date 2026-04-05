import '../entities/wishlist_item.dart';
import '../repositories/wishlist_repository.dart';

class GetWishlistUseCase {
  final WishlistRepository repository;
  GetWishlistUseCase(this.repository);

  Future<List<WishlistItem>> call() => repository.getWishlist();
}
