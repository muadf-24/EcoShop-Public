import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../../features/authentication/presentation/bloc/auth_state.dart';
import '../../../features/authentication/presentation/screens/splash_screen.dart';
import '../../../features/authentication/presentation/screens/login_screen.dart';
import '../../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../../features/home/presentation/screens/main_screen.dart';
import '../../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../../features/profile/presentation/screens/address_management_screen.dart';
import '../../../features/profile/presentation/screens/payment_methods_screen.dart';
import '../../../features/profile/presentation/screens/notifications_screen.dart';
import '../../../features/profile/presentation/screens/help_support_screen.dart';
import '../../../features/wishlist/presentation/screens/wishlist_screen.dart';
import '../../../features/checkout/presentation/screens/order_history_screen.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => SplashScreen(
          onComplete: () => context.go('/onboarding'),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => OnboardingScreen(
          onComplete: () => context.go('/login'),
        ),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const MainScreen(),
        routes: [
          GoRoute(
            path: 'edit-profile',
            name: 'edit-profile',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: 'wishlist',
            name: 'wishlist',
            builder: (context, state) => const WishlistScreen(),
          ),
          GoRoute(
            path: 'orders',
            name: 'orders',
            builder: (context, state) => const OrderHistoryScreen(),
          ),
          GoRoute(
            path: 'addresses',
            name: 'addresses',
            builder: (context, state) => const AddressManagementScreen(),
          ),
          GoRoute(
            path: 'payment-methods',
            name: 'payment-methods',
            builder: (context, state) => const PaymentMethodsScreen(),
          ),
          GoRoute(
            path: 'notifications',
            name: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: 'help-support',
            name: 'help-support',
            builder: (context, state) => const HelpSupportScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final authState = authBloc.state;
      final path = state.matchedLocation;

      debugPrint('🧭 [ROUTER] Redirect Check: Path=$path, State=${authState.runtimeType}');

      // CRITICAL FIX: Simplified logic to stop infinite loops

      // 1. Loading: Stay on current page
      if (authState is AuthLoading || authState is AuthInitial) {
        debugPrint('🧭 [ROUTER] Loading/Initial state - staying on current page');
        return null;
      }

      // 2. Unauthenticated or Error: Go to /login (unless already on auth pages)
      if (authState is AuthUnauthenticated || authState is AuthError) {
        if (path == '/login' || path == '/register' || path == '/forgot-password') {
          debugPrint('🧭 [ROUTER] Already on auth page - staying');
          return null;
        }
        debugPrint('🧭 [ROUTER] Not authenticated - redirecting to /login');
        return '/login';
      }

      // 3. Authenticated: Go to home
      if (authState is AuthAuthenticated) {
        if (path == '/login' || path == '/register' || path == '/splash' || path == '/onboarding') {
          debugPrint('🧭 [ROUTER] Authenticated - redirecting to /');
          return '/';
        }
        debugPrint('🧭 [ROUTER] Already authenticated - staying at $path');
        return null;
      }

      return null;
    },
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  late final dynamic _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen(
      (dynamic _) {
        debugPrint('🔄 [ROUTER] Refreshing due to Bloc state change');
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
