import '../entities/order.dart';
import '../repositories/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository repository;
  CreateOrderUseCase(this.repository);
  Future<Order> call(CreateOrderParams params) => repository.createOrder(params);
}
