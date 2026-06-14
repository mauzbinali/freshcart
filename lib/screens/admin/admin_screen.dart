import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

const _orderStatuses = [
  'pending',
  'processing',
  'shipped',
  'delivered',
  'cancelled',
];

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);

    if (!isAdmin) {
      return const Scaffold(
        body: Center(child: Text('Admin access required')),
      );
    }

    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Portal'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.dashboard_outlined), text: 'Dashboard'),
              Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Products'),
              Tab(icon: Icon(Icons.category_outlined), text: 'Categories'),
              Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Orders'),
              Tab(icon: Icon(Icons.discount_outlined), text: 'Coupons'),
              Tab(icon: Icon(Icons.people_outline), text: 'Users'),
              Tab(icon: Icon(Icons.rate_review_outlined), text: 'Reviews'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _DashboardTab(),
            _ProductsTab(),
            _CategoriesTab(),
            _OrdersTab(),
            _CouponsTab(),
            _UsersTab(),
            _ReviewsTab(),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatsProvider);
    final orders = ref.watch(allOrdersProvider);

    return stats.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (s) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton.icon(
            onPressed: () => _confirmSeedDemoData(context, ref),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Seed Demo Store Data'),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.35,
            children: [
              _StatCard('Revenue', AppUtils.formatCurrency(s.totalRevenue),
                  Icons.payments_outlined, Colors.green),
              _StatCard('Orders', '${s.totalOrders}',
                  Icons.receipt_long_outlined, Colors.blue),
              _StatCard('Pending', '${s.pendingOrders}',
                  Icons.pending_actions_outlined, Colors.orange),
              _StatCard('Products', '${s.totalProducts}',
                  Icons.inventory_2_outlined, Colors.purple),
              _StatCard('Users', '${s.totalUsers}', Icons.people_outline,
                  Colors.teal),
            ],
          ),
          const SizedBox(height: 18),
          const Text('Recent Orders',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          orders.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Failed to load orders: $e'),
            data: (list) => Column(
              children: list
                  .take(5)
                  .map((o) => _OrderAdminTile(order: o, compact: true))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

void _confirmSeedDemoData(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Seed demo data?'),
      content: const Text(
        'This will add or update 10 categories, 50 products, 5 coupons, 12 orders, and 30 reviews in Firebase.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final user = ref.read(currentUserProvider).valueOrNull;
            if (user == null) {
              AppUtils.showSnackBar(context, 'Login required', isError: true);
              return;
            }
            Navigator.pop(context);
            AppUtils.showToast('Seeding demo data...');
            await ref.read(firestoreServiceProvider).seedDemoStoreData(user);
            AppUtils.showToast('Demo store data added');
          },
          child: const Text('Seed Now'),
        ),
      ],
    ),
  );
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const Spacer(),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

class _ProductsTab extends ConsumerWidget {
  const _ProductsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(allProductsProvider);

    return Scaffold(
      body: products.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) => list.isEmpty
            ? const EmptyState(
                title: 'No products',
                subtitle: 'Add your first product to show it in the store',
                icon: Icons.inventory_2_outlined,
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _ProductAdminTile(product: list[i]),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Product'),
      ),
    );
  }
}

class _ProductAdminTile extends ConsumerWidget {
  final ProductModel product;
  const _ProductAdminTile({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AppNetworkImage(product.imageUrl, width: 52, height: 52),
        ),
        title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${product.category} | ${AppUtils.formatCurrency(product.price)} | stock ${product.stock}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              _showProductForm(context, ref, product: product);
            } else {
              await ref
                  .read(firestoreServiceProvider)
                  .deleteProduct(product.id);
              AppUtils.showToast('Product deleted');
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}

void _showProductForm(
  BuildContext context,
  WidgetRef ref, {
  ProductModel? product,
}) {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController(text: product?.name ?? '');
  final desc = TextEditingController(text: product?.description ?? '');
  final price = TextEditingController(text: product?.price.toString() ?? '');
  final original =
      TextEditingController(text: product?.originalPrice?.toString() ?? '');
  final image = TextEditingController(text: product?.imageUrl ?? '');
  final category = TextEditingController(text: product?.category ?? '');
  final stock = TextEditingController(text: product?.stock.toString() ?? '');
  final unit = TextEditingController(text: product?.unit ?? 'kg');
  bool featured = product?.isFeatured ?? false;
  File? pickedImage;

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(product == null ? 'Add Product' : 'Edit Product'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AdminField(name, 'Name', required: true),
                _AdminField(desc, 'Description', maxLines: 3, required: true),
                _AdminField(price, 'Price',
                    keyboardType: TextInputType.number, required: true),
                _AdminField(original, 'Original price',
                    keyboardType: TextInputType.number),
                Row(
                  children: [
                    Expanded(
                      child: _AdminField(image, 'Image URL'),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      tooltip: 'Pick image',
                      onPressed: () async {
                        final picked = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 80,
                        );
                        if (picked == null) return;
                        setState(() => pickedImage = File(picked.path));
                      },
                      icon: const Icon(Icons.photo_library_outlined),
                    ),
                  ],
                ),
                if (pickedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        pickedImage!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                _AdminField(category, 'Category', required: true),
                _AdminField(stock, 'Stock',
                    keyboardType: TextInputType.number, required: true),
                _AdminField(unit, 'Unit', required: true),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: featured,
                  title: const Text('Featured product'),
                  onChanged: (v) => setState(() => featured = v),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              var imageUrl = image.text.trim();
              if (pickedImage != null) {
                imageUrl = await ref.read(firestoreServiceProvider).uploadImage(
                      pickedImage!,
                      '${AppConstants.productImagesPath}/${DateTime.now().millisecondsSinceEpoch}.jpg',
                    );
                if (!context.mounted) return;
              }
              if (imageUrl.isEmpty) {
                AppUtils.showSnackBar(
                    context, 'Add an image URL or pick an image',
                    isError: true);
                return;
              }
              final item = ProductModel(
                id: product?.id ?? '',
                name: name.text.trim(),
                description: desc.text.trim(),
                price: double.tryParse(price.text.trim()) ?? 0,
                originalPrice: original.text.trim().isEmpty
                    ? null
                    : double.tryParse(original.text.trim()),
                imageUrl: imageUrl,
                category: category.text.trim(),
                stock: int.tryParse(stock.text.trim()) ?? 0,
                unit: unit.text.trim(),
                isFeatured: featured,
                rating: product?.rating ?? 0,
                reviewCount: product?.reviewCount ?? 0,
                createdAt: product?.createdAt ?? DateTime.now(),
              );
              await ref.read(firestoreServiceProvider).upsertProduct(item);
              if (!context.mounted) return;
              if (context.mounted) Navigator.pop(context);
              AppUtils.showToast('Product saved');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

class _CategoriesTab extends ConsumerWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      body: categories.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => Card(
            child: ListTile(
              leading:
                  Text(list[i].emoji, style: const TextStyle(fontSize: 28)),
              title: Text(list[i].name),
              subtitle: Text('Sort order ${list[i].sortOrder}'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    _showCategoryForm(context, ref, category: list[i]);
                  } else {
                    await ref
                        .read(firestoreServiceProvider)
                        .deleteCategory(list[i].id);
                    AppUtils.showToast('Category deleted');
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Category'),
      ),
    );
  }
}

void _showCategoryForm(
  BuildContext context,
  WidgetRef ref, {
  CategoryModel? category,
}) {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController(text: category?.name ?? '');
  final emoji = TextEditingController(text: category?.emoji ?? '');
  final image = TextEditingController(text: category?.imageUrl ?? '');
  final sort =
      TextEditingController(text: category?.sortOrder.toString() ?? '0');

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(category == null ? 'Add Category' : 'Edit Category'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AdminField(name, 'Name', required: true),
              _AdminField(emoji, 'Emoji', required: true),
              _AdminField(image, 'Image URL'),
              _AdminField(sort, 'Sort order',
                  keyboardType: TextInputType.number),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            await ref.read(firestoreServiceProvider).upsertCategory(
                  CategoryModel(
                    id: category?.id ?? '',
                    name: name.text.trim(),
                    emoji: emoji.text.trim(),
                    imageUrl:
                        image.text.trim().isEmpty ? null : image.text.trim(),
                    sortOrder: int.tryParse(sort.text.trim()) ?? 0,
                  ),
                );
            if (context.mounted) Navigator.pop(context);
            AppUtils.showToast('Category saved');
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

class _OrdersTab extends ConsumerWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(allOrdersProvider);

    return orders.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (list) => list.isEmpty
          ? const EmptyState(
              title: 'No orders',
              subtitle: 'Customer orders will appear here',
              icon: Icons.receipt_long_outlined,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _OrderAdminTile(order: list[i]),
            ),
    );
  }
}

class _OrderAdminTile extends ConsumerWidget {
  final OrderModel order;
  final bool compact;

  const _OrderAdminTile({required this.order, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('#${_shortId(order.id)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                OrderStatusChip(status: order.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${order.items.length} items | ${AppUtils.formatCurrency(order.total)}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (!compact) ...[
              const SizedBox(height: 4),
              Text('${order.address}, ${order.city}',
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _orderStatuses.contains(order.status)
                    ? order.status
                    : 'pending',
                decoration: const InputDecoration(labelText: 'Order status'),
                items: _orderStatuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) async {
                  if (value == null) return;
                  await ref
                      .read(firestoreServiceProvider)
                      .updateOrderStatus(order.id, value);
                  AppUtils.showToast('Order status updated');
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CouponsTab extends ConsumerWidget {
  const _CouponsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupons = ref.watch(couponsProvider);

    return Scaffold(
      body: coupons.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => Card(
            child: ListTile(
              leading: Icon(Icons.discount_outlined,
                  color:
                      list[i].isActive ? AppTheme.primaryGreen : Colors.grey),
              title: Text(list[i].code),
              subtitle: Text(
                  '${list[i].discountPercent.toStringAsFixed(0)}% off | min ${AppUtils.formatCurrency(list[i].minOrderAmount)}'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    _showCouponForm(context, ref, coupon: list[i]);
                  } else {
                    await ref
                        .read(firestoreServiceProvider)
                        .deleteCoupon(list[i].id);
                    AppUtils.showToast('Coupon deleted');
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCouponForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Coupon'),
      ),
    );
  }
}

void _showCouponForm(
  BuildContext context,
  WidgetRef ref, {
  CouponModel? coupon,
}) {
  final formKey = GlobalKey<FormState>();
  final code = TextEditingController(text: coupon?.code ?? '');
  final discount =
      TextEditingController(text: coupon?.discountPercent.toString() ?? '');
  final max =
      TextEditingController(text: coupon?.maxDiscount?.toString() ?? '');
  final min =
      TextEditingController(text: coupon?.minOrderAmount.toString() ?? '0');
  bool active = coupon?.isActive ?? true;

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(coupon == null ? 'Add Coupon' : 'Edit Coupon'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AdminField(code, 'Code', required: true),
                _AdminField(discount, 'Discount percent',
                    keyboardType: TextInputType.number, required: true),
                _AdminField(max, 'Max discount',
                    keyboardType: TextInputType.number),
                _AdminField(min, 'Minimum order',
                    keyboardType: TextInputType.number),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: active,
                  title: const Text('Active'),
                  onChanged: (v) => setState(() => active = v),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await ref.read(firestoreServiceProvider).upsertCoupon(
                    CouponModel(
                      id: coupon?.id ?? '',
                      code: code.text.trim().toUpperCase(),
                      discountPercent:
                          double.tryParse(discount.text.trim()) ?? 0,
                      maxDiscount: max.text.trim().isEmpty
                          ? null
                          : double.tryParse(max.text.trim()),
                      minOrderAmount: double.tryParse(min.text.trim()) ?? 0,
                      isActive: active,
                    ),
                  );
              if (context.mounted) Navigator.pop(context);
              AppUtils.showToast('Coupon saved');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

class _UsersTab extends ConsumerWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);

    return users.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (list) => ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: list[i].isAdmin
                  ? AppTheme.primaryGreen
                  : Colors.grey.shade300,
              child: Text(
                list[i].name.isEmpty ? 'U' : list[i].name[0].toUpperCase(),
                style: TextStyle(
                    color: list[i].isAdmin ? Colors.white : Colors.black87),
              ),
            ),
            title: Text(list[i].name.isEmpty ? 'Unnamed user' : list[i].name),
            subtitle: Text('${list[i].email} | ${list[i].role}'),
            trailing: Switch(
              value: list[i].isAdmin,
              onChanged: (value) async {
                await ref.read(firestoreServiceProvider).updateUser(
                  list[i].id,
                  {'role': value ? 'admin' : 'user'},
                );
                AppUtils.showToast(value ? 'Admin enabled' : 'Admin removed');
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewsTab extends ConsumerWidget {
  const _ReviewsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(allReviewsProvider);

    return reviews.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (list) => list.isEmpty
          ? const EmptyState(
              title: 'No reviews',
              subtitle: 'Customer product reviews will appear here',
              icon: Icons.rate_review_outlined,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => Card(
                child: ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: Text(
                    list[i].comment,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${list[i].userName} | ${list[i].rating.toStringAsFixed(1)} stars',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      await ref
                          .read(firestoreServiceProvider)
                          .deleteReview(list[i].id);
                      AppUtils.showToast('Review deleted');
                    },
                  ),
                ),
              ),
            ),
    );
  }
}

class _AdminField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final bool required;
  final TextInputType? keyboardType;

  const _AdminField(
    this.controller,
    this.label, {
    this.maxLines = 1,
    this.required = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
        validator: required
            ? (value) =>
                value == null || value.trim().isEmpty ? 'Required' : null
            : null,
      ),
    );
  }
}

String _shortId(String id) {
  if (id.length <= 8) return id.toUpperCase();
  return id.substring(0, 8).toUpperCase();
}
