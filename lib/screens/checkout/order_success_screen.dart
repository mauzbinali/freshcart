import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';

class OrderSuccessScreen extends StatefulWidget {
  final String orderId;
  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _scale = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: FadeTransition(
                opacity: _fade,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _scale,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.green.shade200, width: 3),
                        ),
                        child: const Icon(Icons.check_circle,
                            size: 64, color: AppTheme.primaryGreen),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Order Placed!',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your order has been confirmed.\nWe\'ll notify you when it\'s on the way.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 15,
                          height: 1.5),
                    ),
                    const SizedBox(height: 24),

                    // Order number badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.receipt_outlined,
                              size: 16, color: AppTheme.primaryGreen),
                          const SizedBox(width: 6),
                          Text(
                            'Order #${AppUtils.shortId(widget.orderId)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryGreen),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Estimated delivery
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.delivery_dining,
                              color: AppTheme.primaryGreen, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Estimated Delivery',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text(
                                  AppUtils.formatDate(DateTime.now()
                                      .add(const Duration(days: 1))),
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    ElevatedButton.icon(
                      onPressed: () => context.go('/home'),
                      icon: const Icon(Icons.storefront),
                      label: const Text('Continue Shopping'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/home/orders'),
                      icon: const Icon(Icons.track_changes),
                      label: const Text('Track My Order'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
