import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';

class AddressRepositoryImpl implements AddressRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  AddressRepositoryImpl({
    required this.firestore,
    required this.auth,
  });

  String get _uid => auth.currentUser?.uid ?? (throw Exception('User not logged in'));

  CollectionReference get _addressCollection =>
      firestore.collection('users').doc(_uid).collection('addresses');

  @override
  Future<List<Address>> getAddresses() async {
    final snapshot = await _addressCollection.get();
    return snapshot.docs
        .map((doc) => Address.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  @override
  Future<void> addAddress(Address address) async {
    final addressMap = address.toMap();
    addressMap.remove('id'); // ID is the document ID
    await _addressCollection.add(addressMap);
  }

  @override
  Future<void> updateAddress(Address address) async {
    final addressMap = address.toMap();
    addressMap.remove('id');
    await _addressCollection.doc(address.id).update(addressMap);
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    await _addressCollection.doc(addressId).delete();
  }

  @override
  Future<void> setDefaultAddress(String addressId) async {
    final snapshot = await _addressCollection.get();
    final batch = firestore.batch();
    
    for (var doc in snapshot.docs) {
      if (doc.id == addressId) {
        batch.update(doc.reference, {'isDefault': true});
      } else if (doc.data() != null && (doc.data() as Map)['isDefault'] == true) {
        batch.update(doc.reference, {'isDefault': false});
      }
    }
    
    await batch.commit();
  }
}
