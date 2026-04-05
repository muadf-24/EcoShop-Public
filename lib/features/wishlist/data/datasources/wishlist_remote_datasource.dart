import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/wishlist_item_model.dart';

/// Remote data source for Wishlist using Cloud Firestore.
class WishlistRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  WishlistRemoteDataSource({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  })  : _firestore = firestore,
        _firebaseAuth = firebaseAuth;

  String get _userId {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _userWishlistCollection =>
      _firestore.collection('users').doc(_userId).collection('wishlist');

  /// Fetches all items from the user's wishlist in Firestore.
  Future<List<WishlistItemModel>> getWishlist() async {
    try {
      final snapshot = await _userWishlistCollection
          .orderBy('added_at', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => WishlistItemModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch wishlist: ${e.message}');
    }
  }

  /// Streams the user's wishlist from Firestore for real-time updates.
  Stream<List<WishlistItemModel>> getWishlistStream() {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _userWishlistCollection
        .orderBy('added_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WishlistItemModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  /// Adds an item to the user's wishlist in Firestore.
  Future<void> addToWishlist(WishlistItemModel item) async {
    try {
      // Use productId as the document ID to prevent duplicates
      await _userWishlistCollection.doc(item.productId).set(item.toJson());
    } on FirebaseException catch (e) {
      throw Exception('Failed to add to wishlist: ${e.message}');
    }
  }

  /// Removes an item from the user's wishlist in Firestore.
  Future<void> removeFromWishlist(String productId) async {
    try {
      await _userWishlistCollection.doc(productId).delete();
    } on FirebaseException catch (e) {
      throw Exception('Failed to remove from wishlist: ${e.message}');
    }
  }

  /// Checks if a product exists in the user's wishlist.
  Future<bool> isInWishlist(String productId) async {
    try {
      final doc = await _userWishlistCollection.doc(productId).get();
      return doc.exists;
    } on FirebaseException catch (e) {
      throw Exception('Failed to check wishlist status: ${e.message}');
    }
  }

  /// Clears all items from the user's wishlist.
  Future<void> clearWishlist() async {
    try {
      final snapshot = await _userWishlistCollection.get();
      final batch = _firestore.batch();
      
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception('Failed to clear wishlist: ${e.message}');
    }
  }
}
