import '../entities/order.dart';
import '../../../profile/domain/entities/address.dart';
import '../../data/models/order_model.dart';

/// Order repository contract
abstract class OrderRepository {
  Future<Order> createOrder(CreateOrderParams params);
  Future<List<Order>> getOrders();
  Future<Order> getOrderById(String id);
}

/// Parameters for creating an order
class CreateOrderParams {
  final List<OrderItemModel> items;
  final Address shippingAddress;
  final String paymentMethod;
  final double subtotal;
  final double tax;
  final double shipping;
  final double discount;
  final String? promoCode;

  const CreateOrderParams({
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    this.discount = 0.0,
    this.promoCode,
  });

  double get total => subtotal + tax + shipping - discount;
}
