/// Asset paths used throughout the application
class AppAssets {
  AppAssets._();

  // ─── Icons ────────────────────────────────────────────────────
  static const String iconsPath = 'assets/icons';
  static const String logo = '$iconsPath/logo.svg';
  static const String logoFull = '$iconsPath/logo_full.svg';

  // ─── Images ───────────────────────────────────────────────────
  static const String imagesPath = 'assets/images';
  static const String onboarding1 = '$imagesPath/onboarding_1.png';
  static const String onboarding2 = '$imagesPath/onboarding_2.png';
  static const String onboarding3 = '$imagesPath/onboarding_3.png';
  static const String emptyCart = '$imagesPath/empty_cart.png';
  static const String emptyWishlist = '$imagesPath/empty_wishlist.png';
  static const String emptyOrders = '$imagesPath/empty_orders.png';
  static const String noResults = '$imagesPath/no_results.png';
  static const String errorImage = '$imagesPath/error.png';
  static const String placeholder = '$imagesPath/placeholder.png';

  // ─── Animations ───────────────────────────────────────────────
  static const String animationsPath = 'assets/animations';
  static const String successAnimation = '$animationsPath/success.json';
  static const String loadingAnimation = '$animationsPath/loading.json';

  // ─── Placeholder URLs ────────────────────────────────────────
  static const String networkPlaceholder =
      'https://via.placeholder.com/400x400/E8D5C4/8B7355?text=EcoShop';
  static const String avatarPlaceholder =
      'https://via.placeholder.com/150x150/2D6A4F/FFFFFF?text=U';
}
