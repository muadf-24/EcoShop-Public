import 'dart:async';
import 'package:logger/logger.dart';

abstract class PaymentService {
  Future<void> init();
  Future<bool> processPayment({
    required double amount,
    required String currency,
    required String email,
  });
}

class StripePaymentService implements PaymentService {
  final Logger _logger = Logger();
  bool _isInitialized = false;

  @override
  Future<void> init() async {
    if (_isInitialized) return;
    
    // In a real app, you would load this from flutter_dotenv
    // Stripe.publishableKey = "your_publishable_key";
    // await Stripe.instance.applySettings();
    
    _isInitialized = true;
    _logger.i('Stripe initialized (Mock Keys)');
  }

  @override
  Future<bool> processPayment({
    required double amount,
    required String currency,
    required String email,
  }) async {
    try {
      _logger.i('Processing payment of $amount $currency for $email');
      
      // 1. In real app, call your backend to create PaymentIntent
      // final response = await dio.post('/create-payment-intent', data: {...});
      
      // 2. Mocking the API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // 3. Mocking Stripe Sheet or Payment flow
      // In real app:
      /*
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'EcoShop',
          customerEmail: email,
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      */
      
      _logger.i('Payment successful');
      return true;
    } catch (e) {
      _logger.e('Payment failed: $e');
      return false;
    }
  }
}

/// A pure mock implementation for rapid testing without any Stripe SDK overhead
class MockPaymentService implements PaymentService {
  @override
  Future<void> init() async => Future.value();

  @override
  Future<bool> processPayment({
    required double amount,
    required String currency,
    required String email,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    // Simulate 95% success rate
    return DateTime.now().millisecond % 20 != 0;
  }
}
