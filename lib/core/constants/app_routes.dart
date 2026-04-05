/// Named routes for navigation
class AppRoutes {
  AppRoutes._();

  // ─── Root ─────────────────────────────────────────────────────
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String main = '/main';

  // ─── Authentication ───────────────────────────────────────────
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // ─── Product ──────────────────────────────────────────────────
  static const String home = '/home';
  static const String productList = '/products';
  static const String productDetails = '/product/:id';
  static const String search = '/search';

  // ─── Cart & Checkout ──────────────────────────────────────────
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String addressForm = '/checkout/address';
  static const String payment = '/checkout/payment';
  static const String orderSuccess = '/checkout/success';

  // ─── Profile ──────────────────────────────────────────────────
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String orders = '/profile/orders';
  static const String wishlist = '/profile/wishlist';
  static const String settings = '/profile/settings';
}
