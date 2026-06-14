import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _paymentMethod = 'cash';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill from user profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider).value;
      if (user != null) {
        _nameCtrl.text = user.name;
        _phoneCtrl.text = user.phone;
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final user = ref.read(currentUserProvider).value;
    final cart = ref.read(cartProvider);
    final subtotal = ref.read(cartTotalProvider);
    final discount = ref.read(discountAmountProvider);
    final coupon = ref.read(appliedCouponProvider);
    final deliveryFee = subtotal >= AppConstants.freeDeliveryThreshold
        ? 0.0
        : AppConstants.deliveryFee;
    final total = subtotal - discount + deliveryFee;

    try {
      final order = OrderModel(
        id: '',
        userId: user!.id,
        items: cart.map((i) => OrderItem.fromCartItem(i)).toList(),
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        discount: discount,
        total: total,
        status: 'pending',
        address: _addressCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        paymentMethod: _paymentMethod,
        couponCode: coupon?.code,
        createdAt: DateTime.now(),
      );

      final orderId =
          await ref.read(firestoreServiceProvider).createOrder(order);
      ref.read(cartProvider.notifier).clear();
      ref.read(appliedCouponProvider.notifier).state = null;

      if (mounted) context.go('/home/order-success/$orderId');
    } catch (e) {
      if (!mounted) return;
      AppUtils.showSnackBar(context, 'Failed to place order: $e',
          isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = ref.watch(cartTotalProvider);
    final discount = ref.watch(discountAmountProvider);
    final deliveryFee = subtotal >= AppConstants.freeDeliveryThreshold
        ? 0.0
        : AppConstants.deliveryFee;
    final total = subtotal - discount + deliveryFee;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle('Delivery Information'),
            const SizedBox(height: 12),
            _buildField(_nameCtrl, 'Full Name', Icons.person_outlined,
                validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 12),
            _buildField(_phoneCtrl, 'Phone Number', Icons.phone_outlined,
                type: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 12),
            _buildField(
                _addressCtrl, 'Street Address', Icons.home_outlined,
                validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 12),
            _buildField(_cityCtrl, 'City', Icons.location_city_outlined,
                validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Order Notes (Optional)',
                prefixIcon: Icon(Icons.note_outlined),
              ),
            ),
            const SizedBox(height: 20),

            _sectionTitle('Payment Method'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _PaymentOption(
                  label: 'Cash on Delivery',
                  icon: Icons.payments_outlined,
                  value: 'cash',
                  groupValue: _paymentMethod,
                  onChanged: (v) => setState(() => _paymentMethod = v!),
                )),
                const SizedBox(width: 8),
                Expanded(
                    child: _PaymentOption(
                  label: 'Online Payment',
                  icon: Icons.credit_card,
                  value: 'online',
                  groupValue: _paymentMethod,
                  onChanged: (v) => setState(() => _paymentMethod = v!),
                )),
              ],
            ),
            const SizedBox(height: 20),

            // Order summary
            _sectionTitle('Order Summary'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _SummaryRow('Subtotal',
                        AppUtils.formatCurrency(subtotal)),
                    _SummaryRow('Delivery',
                        deliveryFee == 0 ? 'Free' : AppUtils.formatCurrency(deliveryFee)),
                    if (discount > 0)
                      _SummaryRow('Discount',
                          '-${AppUtils.formatCurrency(discount)}',
                          valueColor: Colors.green),
                    const Divider(),
                    _SummaryRow('Total',
                        AppUtils.formatCurrency(total),
                        bold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _loading ? null : _placeOrder,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text('Place Order · ${AppUtils.formatCurrency(total)}'),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title,
      style:
          const TextStyle(fontSize: 15, fontWeight: FontWeight.bold));

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: type,
        decoration:
            InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        validator: validator,
      );
}

class _PaymentOption extends StatelessWidget {
  final String label, value, groupValue;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _PaymentOption({
    required this.label,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? Colors.green.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? Colors.green.shade400
                : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selected
                    ? Colors.green
                    : Colors.grey,
                size: 28),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: selected ? Colors.green : Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  final Color? valueColor;
  const _SummaryRow(this.label, this.value,
      {this.bold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(
                  color: bold ? null : Colors.grey.shade600,
                  fontWeight: bold ? FontWeight.bold : null)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                  color: valueColor ??
                      (bold ? Colors.green.shade700 : null))),
        ],
      ),
    );
  }
}
