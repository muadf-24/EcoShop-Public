import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Core
import 'core/network/api_client.dart';
import 'core/network/network_info.dart';
import 'core/network/notification_service.dart';
import 'core/network/auth_token_manager.dart';
import 'core/services/theme_service.dart';
import 'core/services/avatar_service.dart';
import 'core/services/payment_service.dart';
import 'core/services/sync_service.dart';
import 'core/router/app_router.dart';

// ═══════════ Authentication ═══════════
import 'features/authentication/data/datasources/auth_local_datasource.dart';
import 'features/authentication/data/datasources/auth_remote_datasource.dart';
import 'features/authentication/data/repositories/auth_repository_impl.dart';
import 'features/authentication/domain/repositories/auth_repository.dart';
import 'features/authentication/domain/usecases/login_usecase.dart';
import 'features/authentication/domain/usecases/register_usecase.dart';
import 'features/authentication/domain/usecases/logout_usecase.dart';
import 'features/authentication/domain/usecases/check_auth_usecase.dart';
import 'features/authentication/domain/usecases/update_profile_usecase.dart';
import 'features/authentication/domain/usecases/forgot_password_usecase.dart';
import 'features/authentication/domain/usecases/verify_email_usecase.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';

// ═══════════ Product ═══════════
import 'features/product/data/datasources/product_local_datasource.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/product/domain/repositories/product_repository.dart';
import 'features/product/domain/usecases/get_products_usecase.dart';
import 'features/product/domain/usecases/get_product_details_usecase.dart';
import 'features/product/domain/usecases/search_products_usecase.dart';
import 'features/product/domain/usecases/filter_products_usecase.dart';
import 'features/product/presentation/bloc/product_bloc.dart';

// ═══════════ Cart ═══════════
import 'features/cart/data/datasources/cart_local_datasource.dart';
import 'features/cart/data/repositories/cart_repository_impl.dart';
import 'features/cart/domain/repositories/cart_repository.dart';
import 'features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'features/cart/domain/usecases/update_quantity_usecase.dart';
import 'features/cart/domain/usecases/get_cart_items_usecase.dart';
import 'features/cart/domain/usecases/clear_cart_usecase.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';

// ═══════════ Checkout ═══════════
import 'features/checkout/data/datasources/order_local_datasource.dart';
import 'features/checkout/data/repositories/order_repository_impl.dart';
import 'features/checkout/data/repositories/coupon_repository_impl.dart';
import 'features/checkout/domain/repositories/order_repository.dart';
import 'features/checkout/domain/repositories/coupon_repository.dart';
import 'features/checkout/domain/usecases/create_order_usecase.dart';
import 'features/checkout/domain/usecases/get_orders_usecase.dart';
import 'features/checkout/domain/usecases/apply_coupon_usecase.dart';
import 'features/checkout/presentation/bloc/checkout_bloc.dart';

// ═══════════ Wishlist ═══════════
import 'features/wishlist/data/datasources/wishlist_remote_datasource.dart';
import 'features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'features/wishlist/domain/repositories/wishlist_repository.dart';
import 'features/wishlist/domain/usecases/get_wishlist_usecase.dart';
import 'features/wishlist/domain/usecases/add_to_wishlist_usecase.dart';
import 'features/wishlist/domain/usecases/remove_from_wishlist_usecase.dart';
import 'features/wishlist/domain/usecases/watch_wishlist_usecase.dart';
import 'features/wishlist/presentation/bloc/wishlist_bloc.dart';

// ═══════════ Profile ═══════════
import 'features/profile/data/repositories/address_repository_impl.dart';
import 'features/profile/domain/repositories/address_repository.dart';
import 'features/profile/presentation/bloc/address_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ─── External ───
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // ─── Firebase (FORCE LAZY REGISTRATION ONLY) ───
  // CRITICAL FIX: Configure Firestore with offline persistence
  sl.registerLazySingleton<FirebaseFirestore>(() {
    final firestore = FirebaseFirestore.instance;
    // Settings already configured in main.dart for Web
    // For mobile, default settings are fine
    return firestore;
  });
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  // ─── Core ───
  sl.registerLazySingleton<AuthTokenManager>(
    () => AuthTokenManager(sl<FirebaseAuth>()),
  );
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(tokenManager: sl<AuthTokenManager>()),
  );
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl<Connectivity>()));
  sl.registerLazySingleton<NotificationService>(() => NotificationService(sl<FirebaseMessaging>()));
  sl.registerLazySingleton<ThemeService>(() => ThemeService(sl<SharedPreferences>()));
  sl.registerLazySingleton<AvatarService>(() => AvatarService(storage: sl<FirebaseStorage>()));
  sl.registerLazySingleton<PaymentService>(() => StripePaymentService());
  sl.registerLazySingleton<SyncService>(
    () => SyncService(sl<Connectivity>(), sl<CartBloc>(), sl<WishlistBloc>()),
  );
  
  // ─── Authentication ───
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSource(sl<SharedPreferences>()));
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(
      firebaseAuth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
      firebaseAuth: sl<FirebaseAuth>(), // ✅ SECURITY FIX: Inject FirebaseAuth
    ),
  );

  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => CheckAuthUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => VerifyEmailUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => CheckEmailVerificationUseCase(sl<AuthRepository>()));

  // CRITICAL FIX: AuthBloc MUST be a LazySingleton so Router and UI share state
  sl.registerLazySingleton<AuthBloc>(() => AuthBloc(
    loginUseCase: sl<LoginUseCase>(),
    registerUseCase: sl<RegisterUseCase>(),
    logoutUseCase: sl<LogoutUseCase>(),
    checkAuthUseCase: sl<CheckAuthUseCase>(),
    updateProfileUseCase: sl<UpdateProfileUseCase>(),
    forgotPasswordUseCase: sl<ForgotPasswordUseCase>(),
    verifyEmailUseCase: sl<VerifyEmailUseCase>(),
    checkEmailVerificationUseCase: sl<CheckEmailVerificationUseCase>(),
  ));

  // Router (Depends on AuthBloc singleton)
  sl.registerLazySingleton<AppRouter>(() => AppRouter(sl<AuthBloc>()));

  // ─── Product Feature ───
  sl.registerLazySingleton<ProductLocalDataSource>(() => ProductLocalDataSource());
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(localDataSource: sl<ProductLocalDataSource>()),
  );
  sl.registerLazySingleton(() => GetProductsUseCase(sl<ProductRepository>()));
  sl.registerLazySingleton(() => GetProductDetailsUseCase(sl<ProductRepository>()));
  sl.registerLazySingleton(() => SearchProductsUseCase(sl<ProductRepository>()));
  sl.registerLazySingleton(() => FilterProductsUseCase(sl<ProductRepository>()));
  
  sl.registerLazySingleton<ProductBloc>(() => ProductBloc(
    getProductsUseCase: sl<GetProductsUseCase>(),
    getProductDetailsUseCase: sl<GetProductDetailsUseCase>(),
    searchProductsUseCase: sl<SearchProductsUseCase>(),
    filterProductsUseCase: sl<FilterProductsUseCase>(),
    productRepository: sl<ProductRepository>(),
  ));

  // ─── Cart Feature ───
  sl.registerLazySingleton<CartLocalDataSource>(() => CartLocalDataSource());
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(localDataSource: sl<CartLocalDataSource>()),
  );
  sl.registerLazySingleton(() => AddToCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => RemoveFromCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => UpdateQuantityUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => GetCartItemsUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => ClearCartUseCase(sl<CartRepository>()));
  
  sl.registerLazySingleton<CartBloc>(() => CartBloc(
    addToCartUseCase: sl<AddToCartUseCase>(),
    removeFromCartUseCase: sl<RemoveFromCartUseCase>(),
    updateQuantityUseCase: sl<UpdateQuantityUseCase>(),
    getCartItemsUseCase: sl<GetCartItemsUseCase>(),
    clearCartUseCase: sl<ClearCartUseCase>(),
  ));

  // ─── Checkout Feature ───
  sl.registerLazySingleton<OrderLocalDataSource>(() => OrderLocalDataSource());
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      localDataSource: sl<OrderLocalDataSource>(),
      firestoreInstance: sl<FirebaseFirestore>(),
      auth: sl<FirebaseAuth>(),
    ),
  );

  sl.registerLazySingleton<CouponRepository>(
    () => CouponRepositoryImpl(firestore: sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton(() => CreateOrderUseCase(sl<OrderRepository>()));
  sl.registerLazySingleton(() => GetOrdersUseCase(sl<OrderRepository>()));
  sl.registerLazySingleton(() => ApplyCouponUseCase(sl<CouponRepository>()));
  
  sl.registerLazySingleton<CheckoutBloc>(() => CheckoutBloc(
    createOrderUseCase: sl<CreateOrderUseCase>(),
    getOrdersUseCase: sl<GetOrdersUseCase>(),
    applyCouponUseCase: sl<ApplyCouponUseCase>(),
    cartBloc: sl<CartBloc>(),
    paymentService: sl<PaymentService>(),
  ));

  // ─── Wishlist Feature ───
  sl.registerLazySingleton<WishlistRemoteDataSource>(
    () => WishlistRemoteDataSource(
      firestore: sl<FirebaseFirestore>(),
      firebaseAuth: sl<FirebaseAuth>(),
    ),
  );
  
  sl.registerLazySingleton<WishlistRepository>(
    () => WishlistRepositoryImpl(
      remoteDataSource: sl<WishlistRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton(() => GetWishlistUseCase(sl<WishlistRepository>()));
  sl.registerLazySingleton(() => AddToWishlistUseCase(sl<WishlistRepository>()));
  sl.registerLazySingleton(() => RemoveFromWishlistUseCase(sl<WishlistRepository>()));
  sl.registerLazySingleton(() => WatchWishlistUseCase(sl<WishlistRepository>()));
  
  sl.registerLazySingleton<WishlistBloc>(
    () => WishlistBloc(
      getWishlistUseCase: sl<GetWishlistUseCase>(),
      addToWishlistUseCase: sl<AddToWishlistUseCase>(),
      removeFromWishlistUseCase: sl<RemoveFromWishlistUseCase>(),
      watchWishlistUseCase: sl<WatchWishlistUseCase>(),
      repository: sl<WishlistRepository>(),
    ),
  );

  // ─── Profile Feature ───
  sl.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(
      firestore: sl<FirebaseFirestore>(),
      auth: sl<FirebaseAuth>(),
    ),
  );
  
  // CRITICAL FIX: Changed to factory so each screen gets a new instance
  // Prevents "Cannot add events after close" error when navigating back
  sl.registerFactory<AddressBloc>(() => AddressBloc(addressRepository: sl<AddressRepository>()));
}
