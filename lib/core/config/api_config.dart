import 'environment_config.dart';

/// API configuration with endpoint definitions
class ApiConfig {
  ApiConfig._();

  static String get baseUrl => EnvironmentConfig.apiBaseUrl;

  // ─── Auth Endpoints ───────────────────────────────────────────
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get logout => '$baseUrl/auth/logout';
  static String get refreshToken => '$baseUrl/auth/refresh';
  static String get forgotPassword => '$baseUrl/auth/forgot-password';

  // ─── Product Endpoints ────────────────────────────────────────
  static String get products => '$baseUrl/products';
  static String productById(String id) => '$baseUrl/products/$id';
  static String get categories => '$baseUrl/categories';
  static String get searchProducts => '$baseUrl/products/search';
  static String get featuredProducts => '$baseUrl/products/featured';

  // ─── Cart Endpoints ───────────────────────────────────────────
  static String get cart => '$baseUrl/cart';
  static String cartItem(String id) => '$baseUrl/cart/$id';

  // ─── Order Endpoints ──────────────────────────────────────────
  static String get orders => '$baseUrl/orders';
  static String orderById(String id) => '$baseUrl/orders/$id';

  // ─── User Endpoints ───────────────────────────────────────────
  static String get profile => '$baseUrl/users/profile';
  static String get updateProfile => '$baseUrl/users/profile';
  static String get addresses => '$baseUrl/users/addresses';
  static String get wishlist => '$baseUrl/users/wishlist';
}
