import '../models/order_model.dart';

/// In-memory order data source
class OrderLocalDataSource {
  final List<OrderModel> _orders = [];

  List<OrderModel> getOrders() => List.unmodifiable(_orders);

  void addOrder(OrderModel order) {
    _orders.insert(0, order);
  }

  OrderModel? getOrderById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }
}
