import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/home_screen.dart';
import '../product/search_screen.dart';
import '../cart/cart_screen.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';
import '../../providers/providers.dart';

final currentTabProvider = StateProvider<int>((ref) => 0);

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  static const _screens = [
    HomeScreen(),
    SearchScreen(),
    CartScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(currentTabProvider);
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      body: IndexedStack(index: tab, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tab,
        onTap: (i) => ref.read(currentTabProvider.notifier).state = i,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          // FIX: Badge is from Flutter's Material lib (Flutter 3+), NOT the badges package
          BottomNavigationBarItem(
            icon: cartCount > 0
                ? Badge(label: Text('$cartCount'), child: const Icon(Icons.shopping_cart_outlined))
                : const Icon(Icons.shopping_cart_outlined),
            activeIcon: cartCount > 0
                ? Badge(label: Text('$cartCount'), child: const Icon(Icons.shopping_cart))
                : const Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
