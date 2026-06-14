import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../core/utils/app_utils.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/widgets.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch from userOrders stream (already loaded)
    final ordersAsync = ref.watch(userOrdersProvider);

    return ordersAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (orders) {
        final order = orders.where((o) => o.id == orderId).firstOrNull;
        if (order == null) {
          return const Scaffold(body: Center(child: Text('Order not found')));
        }
        return _OrderDetailView(order: order);
      },
    );
  }
}

class _OrderDetailView extends StatelessWidget {
  final OrderModel order;
  const _OrderDetailView({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${AppUtils.shortId(order.id)}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppUtils.getStatusColor(order.status)
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppUtils.getStatusColor(order.status)
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(AppUtils.getStatusIcon(order.status),
                      color: AppUtils.getStatusColor(order.status), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppUtils.statusLabel(order.status),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppUtils.getStatusColor(order.status)),
                        ),
                        Text(
                          AppUtils.formatDateTime(order.createdAt),
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  OrderStatusChip(status: order.status),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Items
            const Text('Items Ordered',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              child: Column(
                children:
                    order.items.map((item) => _ItemTile(item: item)).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Delivery info
            const Text('Delivery Address',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(Icons.person_outlined, order.address),
                    _InfoRow(Icons.phone_outlined, order.phone),
                    _InfoRow(Icons.location_on_outlined,
                        '${order.address}, ${order.city}'),
                    if (order.notes != null && order.notes!.isNotEmpty)
                      _InfoRow(Icons.note_outlined, order.notes!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Payment summary
            const Text('Payment Summary',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _PriceLine(
                        'Subtotal', AppUtils.formatCurrency(order.subtotal)),
                    _PriceLine(
                        'Delivery',
                        order.deliveryFee == 0
                            ? 'Free'
                            : AppUtils.formatCurrency(order.deliveryFee)),
                    if (order.discount > 0)
                      _PriceLine('Discount',
                          '-${AppUtils.formatCurrency(order.discount)}',
                          valueColor: Colors.green),
                    const Divider(height: 12),
                    _PriceLine('Total', AppUtils.formatCurrency(order.total),
                        bold: true),
                    const SizedBox(height: 6),
                    _PriceLine(
                        'Payment',
                        order.paymentMethod == 'cash'
                            ? 'Cash on Delivery'
                            : 'Online Payment'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final OrderItem item;
  const _ItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AppNetworkImage(item.imageUrl, width: 48, height: 48),
      ),
      title: Text(item.productName,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(
          '${AppUtils.formatCurrency(item.price)} × ${item.quantity}',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
      trailing: Text(AppUtils.formatCurrency(item.subtotal),
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  final String label, value;
  final bool bold;
  final Color? valueColor;
  const _PriceLine(this.label, this.value,
      {this.bold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(
                  color: bold ? null : Colors.grey.shade600,
                  fontWeight: bold ? FontWeight.bold : null,
                  fontSize: bold ? 15 : 14)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                  color: valueColor ?? (bold ? AppTheme.primaryGreen : null),
                  fontSize: bold ? 15 : 14)),
        ],
      ),
    );
  }
}
