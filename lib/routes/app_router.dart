import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/main_screen.dart';
import '../screens/product/product_detail_screen.dart';
import '../screens/product/category_screen.dart';
import '../screens/product/search_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/checkout/order_success_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/orders/order_detail_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/wishlist_screen.dart';
import '../screens/admin/admin_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      if (isLoading) return null; // wait for auth to resolve

      final isLoggedIn = authState.value != null;
      final loc = state.matchedLocation;

      final publicRoutes = {
        '/login',
        '/register',
        '/forgot-password',
        '/splash'
      };
      final isPublic = publicRoutes.contains(loc);

      if (!isLoggedIn && !isPublic) return '/login';
      if (isLoggedIn && (loc == '/login' || loc == '/register')) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const MainScreen(),
        routes: [
          GoRoute(
            path: 'product/:id',
            builder: (_, state) =>
                ProductDetailScreen(productId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'category/:name',
            builder: (_, state) =>
                CategoryScreen(category: state.pathParameters['name']!),
          ),
          GoRoute(
            path: 'search',
            builder: (_, __) => const SearchScreen(),
          ),
          GoRoute(
            path: 'cart',
            builder: (_, __) => const CartScreen(),
          ),
          GoRoute(
            path: 'checkout',
            builder: (_, __) => const CheckoutScreen(),
          ),
          GoRoute(
            path: 'order-success/:id',
            builder: (_, state) =>
                OrderSuccessScreen(orderId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'orders',
            builder: (_, __) => const OrdersScreen(),
          ),
          GoRoute(
            path: 'order/:id',
            builder: (_, state) =>
                OrderDetailScreen(orderId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'profile',
            builder: (_, __) => const ProfileScreen(),
          ),
          GoRoute(
            path: 'edit-profile',
            builder: (_, __) => const EditProfileScreen(),
          ),
          GoRoute(
            path: 'wishlist',
            builder: (_, __) => const WishlistScreen(),
          ),
          GoRoute(
            path: 'admin',
            builder: (_, __) => const AdminScreen(),
          ),
        ],
      ),
    ],
  );
});
