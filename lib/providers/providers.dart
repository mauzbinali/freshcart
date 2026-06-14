import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

// ─────────────────────────────────────────────
// SERVICES
// ─────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

// ─────────────────────────────────────────────
// THEME
// ─────────────────────────────────────────────
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? false;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', state == ThemeMode.dark);
  }

  bool get isDark => state == ThemeMode.dark;
}

// ─────────────────────────────────────────────
// AUTH
// ─────────────────────────────────────────────
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authAsync = ref.watch(authStateProvider);
  return authAsync.when(
    data: (user) {
      if (user == null) return const Stream.empty();
      return ref.watch(firestoreServiceProvider).userStream(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider).valueOrNull?.isAdmin ?? false;
});

// ─────────────────────────────────────────────
// CATEGORIES
// ─────────────────────────────────────────────
final categoriesProvider = StreamProvider<List<CategoryModel>>((ref) {
  return ref.watch(firestoreServiceProvider).categoriesStream();
});

// ─────────────────────────────────────────────
// PRODUCTS
// ─────────────────────────────────────────────
final allProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  return ref.watch(firestoreServiceProvider).productsStream();
});

final featuredProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  return ref.watch(firestoreServiceProvider).productsStream(featured: true);
});

final categoryProductsProvider =
    StreamProvider.family<List<ProductModel>, String>((ref, category) {
  return ref.watch(firestoreServiceProvider).productsStream(category: category);
});

final productProvider = FutureProvider.family<ProductModel?, String>((ref, id) {
  return ref.watch(firestoreServiceProvider).getProduct(id);
});

// ─────────────────────────────────────────────
// SEARCH
// ─────────────────────────────────────────────
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider =
    FutureProvider.family<List<ProductModel>, String>((ref, query) {
  if (query.isEmpty) return Future.value([]);
  return ref.watch(firestoreServiceProvider).searchProducts(query);
});

// ─────────────────────────────────────────────
// CART
// ─────────────────────────────────────────────
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(ProductModel product) {
    final index = state.indexWhere((i) => i.productId == product.id);
    if (index >= 0) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index)
            state[i].copyWith(quantity: state[i].quantity + 1)
          else
            state[i]
      ];
    } else {
      state = [...state, CartItem.fromProduct(product)];
    }
  }

  void removeItem(String productId) {
    state = state.where((i) => i.productId != productId).toList();
  }

  void updateQuantity(String productId, int qty) {
    if (qty <= 0) {
      removeItem(productId);
      return;
    }
    state = [
      for (final item in state)
        if (item.productId == productId) item.copyWith(quantity: qty) else item
    ];
  }

  void clear() => state = [];

  bool contains(String productId) => state.any((i) => i.productId == productId);

  int quantityOf(String productId) {
    final found = state.where((i) => i.productId == productId);
    return found.isEmpty ? 0 : found.first.quantity;
  }
}

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).fold(0.0, (sum, item) => sum + item.subtotal);
});

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold(0, (sum, item) => sum + item.quantity);
});

// ─────────────────────────────────────────────
// COUPON
// ─────────────────────────────────────────────
final appliedCouponProvider = StateProvider<CouponModel?>((ref) => null);

final discountAmountProvider = Provider<double>((ref) {
  final coupon = ref.watch(appliedCouponProvider);
  final subtotal = ref.watch(cartTotalProvider);
  if (coupon == null) return 0.0;
  double discount = subtotal * coupon.discountPercent / 100;
  if (coupon.maxDiscount != null && discount > coupon.maxDiscount!) {
    discount = coupon.maxDiscount!;
  }
  return discount;
});

// ─────────────────────────────────────────────
// ORDERS
// ─────────────────────────────────────────────
final userOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final authAsync = ref.watch(authStateProvider);
  return authAsync.when(
    data: (user) {
      if (user == null) return const Stream.empty();
      return ref.watch(firestoreServiceProvider).userOrdersStream(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

final allOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  return ref.watch(firestoreServiceProvider).allOrdersStream();
});

final adminStatsProvider = StreamProvider<AdminStats>((ref) {
  return ref.watch(firestoreServiceProvider).adminStatsStream();
});

// ─────────────────────────────────────────────
// REVIEWS
// ─────────────────────────────────────────────
final productReviewsProvider =
    StreamProvider.family<List<ReviewModel>, String>((ref, productId) {
  return ref.watch(firestoreServiceProvider).productReviewsStream(productId);
});

final allReviewsProvider = StreamProvider<List<ReviewModel>>((ref) {
  return ref.watch(firestoreServiceProvider).allReviewsStream();
});

// ─────────────────────────────────────────────
// WISHLIST
// ─────────────────────────────────────────────
final wishlistProductsProvider =
    FutureProvider<List<ProductModel>>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null || user.wishlist.isEmpty) return [];
  final service = ref.watch(firestoreServiceProvider);
  final futures = user.wishlist.map((id) => service.getProduct(id));
  final products = await Future.wait(futures);
  return products.whereType<ProductModel>().toList();
});

final couponsProvider = StreamProvider<List<CouponModel>>((ref) {
  return ref.watch(firestoreServiceProvider).couponsStream();
});

final usersProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(firestoreServiceProvider).usersStream();
});
