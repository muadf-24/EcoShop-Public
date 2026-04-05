import '../../domain/entities/wishlist_item.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_remote_datasource.dart';
import '../models/wishlist_item_model.dart';

/// Implementation of the Wishlist repository.
class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistRemoteDataSource _remoteDataSource;

  WishlistRepositoryImpl({
    required WishlistRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<WishlistItem>> getWishlist() async {
    return await _remoteDataSource.getWishlist();
  }

  @override
  Stream<List<WishlistItem>> getWishlistStream() {
    return _remoteDataSource.getWishlistStream();
  }

  @override
  Future<void> addToWishlist(WishlistItem item) async {
    final model = WishlistItemModel.fromEntity(item);
    await _remoteDataSource.addToWishlist(model);
  }

  @override
  Future<void> removeFromWishlist(String productId) async {
    await _remoteDataSource.removeFromWishlist(productId);
  }

  @override
  Future<bool> isInWishlist(String productId) async {
    return await _remoteDataSource.isInWishlist(productId);
  }

  @override
  Future<void> clearWishlist() async {
    await _remoteDataSource.clearWishlist();
  }
}
