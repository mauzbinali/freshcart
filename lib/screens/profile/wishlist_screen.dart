import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(wishlistProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Wishlist')),
      body: wishlistAsync.when(
        loading: () => GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 4,
          itemBuilder: (_, __) => const ProductCardShimmer(),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (products) => products.isEmpty
            ? EmptyState(
                title: 'No items in wishlist',
                subtitle: 'Tap the ❤️ on any product to save it here',
                icon: Icons.favorite_outline,
                buttonText: 'Browse Products',
                onButton: () => context.go('/home'),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: products.length,
                itemBuilder: (_, i) => ProductCard(product: products[i]),
              ),
      ),
    );
  }
}
