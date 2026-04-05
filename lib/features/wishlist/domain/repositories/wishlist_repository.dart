import '../entities/wishlist_item.dart';

/// Repository interface for Wishlist management.
abstract class WishlistRepository {
  /// Fetches all wishlist items for the current user.
  Future<List<WishlistItem>> getWishlist();

  /// Streams the user's wishlist from the data source for real-time updates.
  Stream<List<WishlistItem>> getWishlistStream();

  /// Adds a product to the wishlist.
  Future<void> addToWishlist(WishlistItem item);

  /// Removes a product from the wishlist by ID.
  Future<void> removeFromWishlist(String productId);

  /// Checks if a product is in the wishlist.
  Future<bool> isInWishlist(String productId);

  /// Clears the entire wishlist.
  Future<void> clearWishlist();
}
