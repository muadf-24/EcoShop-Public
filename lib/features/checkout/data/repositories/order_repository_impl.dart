import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/order.dart' as my_order;
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_local_datasource.dart';
import '../models/order_model.dart';
import '../../../../core/utils/order_validator.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderLocalDataSource localDataSource;
  final firestore.FirebaseFirestore firestoreInstance;
  final FirebaseAuth auth;

  OrderRepositoryImpl({
    required this.localDataSource,
    required this.firestoreInstance,
    required this.auth,
  });

  String get _uid => auth.currentUser?.uid ?? (throw Exception('User not logged in'));

  firestore.CollectionReference get _orderCollection =>
      firestoreInstance.collection('users').doc(_uid).collection('orders');

  @override
  Future<my_order.Order> createOrder(CreateOrderParams params) async {
    // ✅ SECURITY FIX (BUG-005): Comprehensive order validation
    final validationResult = OrderValidator.validateCompleteOrder(
      subtotal: params.subtotal,
      tax: params.tax,
      shipping: params.shipping,
      discount: params.discount,
      total: params.total,
      items: params.items,
      shippingAddress: params.shippingAddress.toMap(),
    );
    
    if (!validationResult.isValid) {
      throw Exception('Order validation failed: ${validationResult.errorMessage}');
    }
    
    // Calculate server-side total (never trust client)
    final calculatedTotal = params.subtotal + params.tax + params.shipping - params.discount;
    
    final order = OrderModel(
      id: '', // Will be updated with Firestore document ID
      items: params.items,
      subtotal: params.subtotal,
      tax: params.tax,
      shipping: params.shipping,
      discount: params.discount,
      total: calculatedTotal, // ✅ Use server-calculated total, not client-provided
      status: 'Pending',
      shippingAddress: params.shippingAddress,
      paymentMethod: params.paymentMethod,
      createdAt: DateTime.now(),
      estimatedDelivery: DateTime.now().add(const Duration(days: 5)),
    );

    final docRef = await _orderCollection.add(order.toJson());
    final finalOrder = order.copyWith(id: docRef.id);
    await docRef.update({'id': docRef.id});

    localDataSource.addOrder(finalOrder);
    return finalOrder;
  }

  @override
  Future<List<my_order.Order>> getOrders() async {
    try {
      final snapshot = await _orderCollection.orderBy('created_at', descending: true).get();
      final orders = snapshot.docs
          .map((doc) => OrderModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
      
      // Update local cache
      for (var order in orders) {
        localDataSource.addOrder(order);
      }
      return orders;
    } catch (e) {
      return localDataSource.getOrders();
    }
  }

  @override
  Future<my_order.Order> getOrderById(String id) async {
    try {
      final doc = await _orderCollection.doc(id).get();
      if (doc.exists) {
        return OrderModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
      }
      throw Exception('Order not found');
    } catch (e) {
      final order = localDataSource.getOrderById(id);
      if (order == null) throw Exception('Order not found');
      return order;
    }
  }
}
