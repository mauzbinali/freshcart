import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/app_utils.dart';

// ─── PRODUCT CARD ───────────────────────────
class ProductCard extends ConsumerWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final inCart = cart.any((i) => i.productId == product.id);

    return GestureDetector(
      onTap: onTap ?? () => context.push('/home/product/${product.id}'),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _shimmerBox(height: 120),
                    errorWidget: (_, __, ___) => Container(
                      height: 120,
                      color: Colors.green.shade50,
                      child: const Center(
                          child: Icon(Icons.image_not_supported,
                              color: Colors.grey)),
                    ),
                  ),
                ),
                if (product.isOnSale)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${product.discountPercent.toInt()}% OFF',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _WishlistButton(productId: product.id),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text('per ${product.unit}',
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 13),
                      Text(' ${product.rating.toStringAsFixed(1)}',
                          style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(AppUtils.formatCurrency(product.price),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.primaryGreen,
                          )),
                      if (product.isOnSale) ...[
                        const SizedBox(width: 4),
                        Text(
                          AppUtils.formatCurrency(product.originalPrice!),
                          style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontSize: 11),
                        ),
                      ],
                      const Spacer(),
                      _AddToCartButton(product: product, inCart: inCart),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddToCartButton extends ConsumerWidget {
  final ProductModel product;
  final bool inCart;
  const _AddToCartButton({required this.product, required this.inCart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(cartProvider.notifier).addItem(product);
        AppUtils.showToast('Added to cart');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: inCart ? AppTheme.primaryGreen : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.add,
            size: 18, color: inCart ? Colors.white : Colors.grey.shade700),
      ),
    );
  }
}

class _WishlistButton extends ConsumerWidget {
  final String productId;
  const _WishlistButton({required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final isWishlisted = user?.wishlist.contains(productId) ?? false;
    return GestureDetector(
      onTap: () {
        final uid = user?.id;
        if (uid == null) return;
        ref.read(firestoreServiceProvider).toggleWishlist(uid, productId);
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Icon(
          isWishlisted ? Icons.favorite : Icons.favorite_border,
          size: 16,
          color: isWishlisted ? Colors.red : Colors.grey,
        ),
      ),
    );
  }
}

// ─── SHIMMER LOADING ────────────────────────
Widget _shimmerBox({double? height, double? width}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      height: height,
      width: width,
      color: Colors.white,
    ),
  );
}

class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Card(
        child: Column(
          children: [
            Container(
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                )),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(height: 10, width: 60, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 14, width: 80, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── STAR RATING ────────────────────────────
class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  const StarRating({super.key, required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return Icon(Icons.star, color: Colors.amber, size: size);
        } else if (i < rating) {
          return Icon(Icons.star_half, color: Colors.amber, size: size);
        }
        return Icon(Icons.star_border, color: Colors.amber, size: size);
      }),
    );
  }
}

// ─── INTERACTIVE STAR PICKER ────────────────
class StarRatingPicker extends StatefulWidget {
  final double initial;
  final ValueChanged<double> onChanged;
  const StarRatingPicker(
      {super.key, this.initial = 0, required this.onChanged});

  @override
  State<StarRatingPicker> createState() => _StarRatingPickerState();
}

class _StarRatingPickerState extends State<StarRatingPicker> {
  late double _rating;
  @override
  void initState() {
    super.initState();
    _rating = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return GestureDetector(
          onTap: () {
            setState(() => _rating = (i + 1).toDouble());
            widget.onChanged(_rating);
          },
          child: Icon(
            i < _rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 32,
          ),
        );
      }),
    );
  }
}

// ─── SECTION HEADER ─────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionHeader(
      {super.key, required this.title, this.actionText, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          if (actionText != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionText!,
                  style: const TextStyle(color: AppTheme.primaryGreen)),
            ),
        ],
      ),
    );
  }
}

// ─── CART BADGE ─────────────────────────────
class CartBadge extends ConsumerWidget {
  const CartBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartItemCountProvider);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () => context.push('/home/cart'),
        ),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              width: 17,
              height: 17,
              decoration: const BoxDecoration(
                  color: Colors.red, shape: BoxShape.circle),
              child: Center(
                child: Text('$count',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── NETWORK IMAGE WITH FALLBACK ─────────────
class AppNetworkImage extends StatelessWidget {
  final String url;
  final double? width, height;
  final BoxFit fit;

  const AppNetworkImage(this.url,
      {super.key, this.width, this.height, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.green.shade50,
        child: Icon(Icons.image_not_supported, color: Colors.grey.shade400),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => _shimmerBox(height: height, width: width),
      errorWidget: (_, __, ___) => Container(
        width: width,
        height: height,
        color: Colors.green.shade50,
        child: Icon(Icons.image_not_supported, color: Colors.grey.shade400),
      ),
    );
  }
}

// ─── EMPTY STATE ────────────────────────────
class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onButton;

  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.buttonText,
    this.onButton,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle,
                style: TextStyle(color: Colors.grey.shade500),
                textAlign: TextAlign.center),
            if (buttonText != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButton,
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── ORDER STATUS CHIP ───────────────────────
class OrderStatusChip extends StatelessWidget {
  final String status;
  const OrderStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppUtils.getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppUtils.getStatusIcon(status), size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            AppUtils.statusLabel(status),
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
