import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../widgets/widgets.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  int _qty = 1;
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productProvider(widget.productId));

    return productAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (product) {
        if (product == null) {
          return const Scaffold(body: Center(child: Text('Product not found')));
        }
        return _buildScreen(product);
      },
    );
  }

  Widget _buildScreen(ProductModel product) {
    final cartItem = ref
        .watch(cartProvider)
        .where((i) => i.productId == product.id)
        .firstOrNull;
    final user = ref.watch(currentUserProvider).value;
    final isWishlisted = user?.wishlist.contains(product.id) ?? false;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image + AppBar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted ? Colors.red : null),
                onPressed: () {
                  if (user != null) {
                    ref
                        .read(firestoreServiceProvider)
                        .toggleWishlist(user.id, product.id);
                  }
                },
              ),
              const CartBadge(),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: product.imageUrl.isNotEmpty
                  ? AppNetworkImage(product.imageUrl,
                      width: double.infinity, height: 280)
                  : Container(
                      color: Colors.green.shade50,
                      child:
                          const Icon(Icons.image, size: 80, color: Colors.grey),
                    ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(product.name,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(AppUtils.formatCurrency(product.price),
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGreen)),
                          if (product.isOnSale)
                            Text(
                                AppUtils.formatCurrency(product.originalPrice!),
                                style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                    fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('per ${product.unit}',
                      style: TextStyle(color: Colors.grey.shade500)),
                  const SizedBox(height: 8),

                  // Rating
                  Row(
                    children: [
                      StarRating(rating: product.rating),
                      const SizedBox(width: 6),
                      Text(
                          '${product.rating.toStringAsFixed(1)} (${product.reviewCount} reviews)',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Stock
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: product.stock > 0
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.stock > 0
                          ? '✓ In Stock (${product.stock} left)'
                          : '✗ Out of Stock',
                      style: TextStyle(
                          color: product.stock > 0
                              ? AppTheme.primaryGreen
                              : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quantity selector
                  Row(
                    children: [
                      const Text('Quantity',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      _QtyButton(
                          icon: Icons.remove,
                          onTap: () {
                            if (_qty > 1) setState(() => _qty--);
                          }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('$_qty',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      _QtyButton(
                          icon: Icons.add, onTap: () => setState(() => _qty++)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),

                  // Tabs
                  TabBar(
                    controller: _tabCtrl,
                    labelColor: AppTheme.primaryGreen,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppTheme.primaryGreen,
                    tabs: const [
                      Tab(text: 'Description'),
                      Tab(text: 'Reviews'),
                    ],
                  ),
                  SizedBox(
                    height: 200,
                    child: TabBarView(
                      controller: _tabCtrl,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(product.description,
                              style: TextStyle(
                                  color: Colors.grey.shade700,
                                  height: 1.6,
                                  fontSize: 14)),
                        ),
                        _ReviewsTab(productId: product.id),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: product.stock == 0
                ? null
                : () {
                    for (int i = 0; i < _qty; i++) {
                      ref.read(cartProvider.notifier).addItem(product);
                    }
                    AppUtils.showToast('$_qty × ${product.name} added to cart');
                    context.push('/home/cart');
                  },
            icon: const Icon(Icons.shopping_cart),
            label: Text(cartItem != null
                ? 'Update Cart (${cartItem.quantity + _qty})'
                : 'Add to Cart · ${AppUtils.formatCurrency(product.price * _qty)}'),
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

class _ReviewsTab extends ConsumerStatefulWidget {
  final String productId;
  const _ReviewsTab({required this.productId});

  @override
  ConsumerState<_ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends ConsumerState<_ReviewsTab> {
  bool _showForm = false;
  final _commentCtrl = TextEditingController();
  double _rating = 5;

  Future<void> _submitReview() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null || _commentCtrl.text.isEmpty) return;
    final review = ReviewModel(
      id: '',
      productId: widget.productId,
      userId: user.id,
      userName: user.name,
      userAvatar: user.avatarUrl,
      rating: _rating,
      comment: _commentCtrl.text,
      createdAt: DateTime.now(),
    );
    await ref.read(firestoreServiceProvider).addReview(review);
    _commentCtrl.clear();
    setState(() => _showForm = false);
    AppUtils.showToast('Review submitted!');
  }

  @override
  Widget build(BuildContext context) {
    final reviews = ref.watch(productReviewsProvider(widget.productId));
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Customer Reviews',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              TextButton.icon(
                onPressed: () => setState(() => _showForm = !_showForm),
                icon: const Icon(Icons.edit, size: 14),
                label:
                    const Text('Write Review', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          if (_showForm) ...[
            StarRatingPicker(
                initial: _rating,
                onChanged: (v) => setState(() => _rating = v)),
            const SizedBox(height: 8),
            TextField(
              controller: _commentCtrl,
              maxLines: 2,
              decoration:
                  const InputDecoration(hintText: 'Share your experience...'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
                onPressed: _submitReview, child: const Text('Submit')),
          ],
          reviews.when(
            data: (list) => list.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No reviews yet. Be the first!'))
                : Column(
                    children: list.map((r) => _ReviewTile(review: r)).toList()),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ReviewModel review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.green.shade100,
            child: Text(AppUtils.firstInitial(review.userName),
                style: const TextStyle(color: AppTheme.primaryGreen)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(review.userName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const Spacer(),
                    StarRating(rating: review.rating, size: 12),
                  ],
                ),
                const SizedBox(height: 2),
                Text(review.comment,
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                Text(AppUtils.formatDate(review.createdAt),
                    style:
                        TextStyle(color: Colors.grey.shade400, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
