import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

// ─── CATEGORY SCREEN ────────────────────────
class CategoryScreen extends ConsumerWidget {
  final String category;
  const CategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(categoryProductsProvider(category));
    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: products.when(
        loading: () => GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 6,
          itemBuilder: (_, __) => const ProductCardShimmer(),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (products) => products.isEmpty
            ? EmptyState(
                title: 'No products in $category',
                subtitle: 'Check back soon for new items',
                icon: Icons.category_outlined,
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
