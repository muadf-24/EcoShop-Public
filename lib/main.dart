import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'core/theme/app_theme.dart';
import 'core/services/theme_service.dart';
import 'injection_container.dart';
import 'firebase_options.dart';
import 'core/network/notification_service.dart';
import 'core/services/payment_service.dart';
import 'core/services/sync_service.dart';
import 'core/router/app_router.dart';

import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/bloc/auth_event.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/checkout/presentation/bloc/checkout_bloc.dart';
import 'features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'features/wishlist/presentation/bloc/wishlist_event.dart';

void main() async {
  // 1. Core engine setup - MUST BE FIRST
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('🚀 [BOOT] Step 1: Flutter Ready');

  try {
    // 2. Initialize Firebase (Primary Gate) - Prevent double initialization
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Firebase initialization timeout - check web/index.html for SDK scripts');
        },
      );
    }
    debugPrint('✅ [BOOT] Step 2: Firebase Ready (${Firebase.apps.length} app(s))');

    // 2b. CRITICAL FIX: Configure Firestore for Web
    if (kIsWeb) {
      try {
        // Enable persistence for offline support
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
        debugPrint('✅ [BOOT] Step 2b: Firestore persistence enabled for Web');
        
        // Set auth persistence to LOCAL
        await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
        debugPrint('✅ [BOOT] Step 2c: Auth persistence set to LOCAL for Web');
      } catch (e) {
        debugPrint('⚠️ [BOOT] Firestore/Auth persistence setup failed (non-critical): $e');
      }
    }

    // 3. Initialize DI
    await initDependencies();
    debugPrint('✅ [BOOT] Step 3: DI Ready');

    // 4. Set Background Handler (Skip on Web - not supported)
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    }

    // 5. Final Boot - Attach UI
    runApp(const EcoShopApp());
    debugPrint('✅ [BOOT] Step 4: UI Attached');

    // 6. IMMEDIATE NAVIGATION TRIGGER
    // We fire the auth check which will cause the GoRouter redirect.
    // Since AuthBloc is now a singleton, the Router will hear this event.
    sl<AuthBloc>().add(AuthCheckRequested());
    debugPrint('🚀 [BOOT] Step 5: Auth Check Fired');

    // 7. Non-blocking Notification Setup (Post-Boot) - Fire and forget
    // This will NOT block navigation even if it fails
    scheduleMicrotask(() {
      sl<NotificationService>().initialize().catchError((e) {
        debugPrint('⚠️ [BOOT] Notification init failed (non-blocking): $e');
      });
      sl<PaymentService>().init().catchError((e) {
        debugPrint('⚠️ [BOOT] Payment service init failed: $e');
      });
      sl<SyncService>(); // Trigger sync engine
    });

  } catch (e) {
    debugPrint('❌ [FATAL] Boot Failed: $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Initialization Error: $e\n\nPlease run with --web-renderer html'),
          ),
        ),
      ),
    ));
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('📬 [BG] Message: ${message.messageId}');
}

class EcoShopApp extends StatelessWidget {
  const EcoShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<ProductBloc>(create: (_) => sl<ProductBloc>()),
        BlocProvider<CartBloc>(create: (_) => sl<CartBloc>()),
        BlocProvider<CheckoutBloc>(create: (_) => sl<CheckoutBloc>()),
        BlocProvider<WishlistBloc>(
          create: (_) => sl<WishlistBloc>()..add(WishlistLoadRequested()),
        ),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: sl<ThemeService>().themeModeNotifier,
        builder: (context, themeMode, _) {
          return MaterialApp.router(
            title: 'EcoShop',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: sl<AppRouter>().router,
          );
        },
      ),
    );
  }
}
