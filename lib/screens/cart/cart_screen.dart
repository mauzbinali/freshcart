import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../widgets/widgets.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _couponCtrl = TextEditingController();
  bool _couponLoading = false;

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon() async {
    if (_couponCtrl.text.isEmpty) return;
    setState(() => _couponLoading = true);
    final coupon = await ref
        .read(firestoreServiceProvider)
        .validateCoupon(_couponCtrl.text);
    if (!mounted) return;
    setState(() => _couponLoading = false);
    if (coupon != null) {
      ref.read(appliedCouponProvider.notifier).state = coupon;
      AppUtils.showSnackBar(
          context, '${coupon.discountPercent.toInt()}% discount applied!');
    } else {
      AppUtils.showSnackBar(context, 'Invalid or expired coupon',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final subtotal = ref.watch(cartTotalProvider);
    final discount = ref.watch(discountAmountProvider);
    final coupon = ref.watch(appliedCouponProvider);
    final deliveryFee = subtotal >= AppConstants.freeDeliveryThreshold
        ? 0.0
        : AppConstants.deliveryFee;
    final total = subtotal - discount + deliveryFee;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart (${cart.length} items)'),
        actions: [
          if (cart.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text('Remove all items from your cart?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          ref.read(cartProvider.notifier).clear();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body: cart.isEmpty
          ? EmptyState(
              title: 'Your cart is empty',
              subtitle: 'Add some fresh groceries to get started',
              icon: Icons.shopping_cart_outlined,
              buttonText: 'Shop Now',
              onButton: () => context.go('/home'),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      ...cart.map((item) => _CartItemTile(item: item)),
                      const SizedBox(height: 16),

                      // Coupon
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Have a coupon?',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _couponCtrl,
                                      textCapitalization:
                                          TextCapitalization.characters,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter coupon code',
                                        prefixIcon:
                                            Icon(Icons.discount_outlined),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed:
                                        _couponLoading ? null : _applyCoupon,
                                    style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(80, 48)),
                                    child: _couponLoading
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white))
                                        : const Text('Apply'),
                                  ),
                                ],
                              ),
                              if (coupon != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle,
                                        color: Colors.green, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                        'Code "${coupon.code}" applied — ${coupon.discountPercent.toInt()}% off',
                                        style: const TextStyle(
                                            color: Colors.green, fontSize: 12)),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () => ref
                                          .read(appliedCouponProvider.notifier)
                                          .state = null,
                                      child: const Icon(Icons.close,
                                          size: 16, color: Colors.red),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10)
                    ],
                  ),
                  child: Column(
                    children: [
                      _PriceLine('Subtotal', subtotal),
                      _PriceLine('Delivery', deliveryFee,
                          note: subtotal >= AppConstants.freeDeliveryThreshold
                              ? 'Free'
                              : null),
                      if (discount > 0)
                        _PriceLine('Discount', -discount, color: Colors.green),
                      const Divider(height: 16),
                      _PriceLine('Total', total, bold: true),
                      const SizedBox(height: 12),
                      if (subtotal < AppConstants.freeDeliveryThreshold)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Add ${AppUtils.formatCurrency(AppConstants.freeDeliveryThreshold - subtotal)} more for free delivery',
                            style: TextStyle(
                                color: Colors.orange.shade700, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ElevatedButton(
                        onPressed: () => context.push('/home/checkout'),
                        child: Text(
                            'Checkout · ${AppUtils.formatCurrency(total)}'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final CartItem item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AppNetworkImage(item.imageUrl, width: 64, height: 64),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                      maxLines: 2),
                  const SizedBox(height: 2),
                  Text(AppUtils.formatCurrency(item.price),
                      style: const TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    _QtyBtn(
                        icon: Icons.remove,
                        onTap: () => ref
                            .read(cartProvider.notifier)
                            .updateQuantity(item.productId, item.quantity - 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('${item.quantity}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    _QtyBtn(
                        icon: Icons.add,
                        onTap: () => ref
                            .read(cartProvider.notifier)
                            .updateQuantity(item.productId, item.quantity + 1)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(AppUtils.formatCurrency(item.price * item.quantity),
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              icon:
                  const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: () =>
                  ref.read(cartProvider.notifier).removeItem(item.productId),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  final String label;
  final double amount;
  final bool bold;
  final Color? color;
  final String? note;

  const _PriceLine(this.label, this.amount,
      {this.bold = false, this.color, this.note});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  fontSize: bold ? 16 : 14,
                  color: bold ? null : Colors.grey.shade600)),
          const Spacer(),
          if (note != null)
            Text(note!,
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.w600)),
          if (note == null)
            Text(
              amount < 0
                  ? '-${AppUtils.formatCurrency(-amount)}'
                  : AppUtils.formatCurrency(amount),
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                fontSize: bold ? 16 : 14,
                color: color ?? (bold ? AppTheme.primaryGreen : null),
              ),
            ),
        ],
      ),
    );
  }
}
