import '../repositories/order_repository.dart';

class ProcessPaymentUseCase {
  final OrderRepository repository;
  ProcessPaymentUseCase(this.repository);

  /// In a real app, this would process payment through a payment gateway
  Future<bool> call({
    required String orderId,
    required String paymentMethod,
    required double amount,
  }) async {
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }
}
