import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/models.dart';
import '../core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ─── USERS ───
  Future<UserModel?> getUser(String uid) async {
    final doc =
        await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Stream<UserModel?> userStream(String uid) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) =>
            doc.exists ? UserModel.fromMap(doc.data()!, doc.id) : null);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) =>
      _db.collection(AppConstants.usersCollection).doc(uid).update(data);

  Stream<List<UserModel>> usersStream() {
    return _db
        .collection(AppConstants.usersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> toggleWishlist(String uid, String productId) async {
    final ref = _db.collection(AppConstants.usersCollection).doc(uid);
    final doc = await ref.get();
    final wishlist = List<String>.from(doc.data()?['wishlist'] ?? []);
    if (wishlist.contains(productId)) {
      wishlist.remove(productId);
    } else {
      wishlist.add(productId);
    }
    await ref.update({'wishlist': wishlist});
  }

  // ─── CATEGORIES ───
  Stream<List<CategoryModel>> categoriesStream() {
    return _db
        .collection(AppConstants.categoriesCollection)
        .orderBy('sortOrder')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CategoryModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<void> upsertCategory(CategoryModel category) async {
    final data = category.toMap();
    if (category.id.isEmpty) {
      await _db.collection(AppConstants.categoriesCollection).add(data);
    } else {
      await _db
          .collection(AppConstants.categoriesCollection)
          .doc(category.id)
          .set(data, SetOptions(merge: true));
    }
  }

  Future<void> deleteCategory(String id) =>
      _db.collection(AppConstants.categoriesCollection).doc(id).delete();

  // ─── PRODUCTS ───
  Stream<List<ProductModel>> productsStream(
      {String? category, bool? featured}) {
    Query<Map<String, dynamic>> q =
        _db.collection(AppConstants.productsCollection);
    if (category != null) q = q.where('category', isEqualTo: category);
    if (featured == true) q = q.where('isFeatured', isEqualTo: true);
    return q.snapshots().map((snap) {
      final products =
          snap.docs.map((d) => ProductModel.fromMap(d.data(), d.id)).toList();
      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return products;
    });
  }

  Future<ProductModel?> getProduct(String id) async {
    final doc =
        await _db.collection(AppConstants.productsCollection).doc(id).get();
    if (!doc.exists) return null;
    return ProductModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> upsertProduct(ProductModel product) async {
    final data = product.toMap();
    if (product.id.isEmpty) {
      await _db.collection(AppConstants.productsCollection).add(data);
    } else {
      await _db
          .collection(AppConstants.productsCollection)
          .doc(product.id)
          .set(data, SetOptions(merge: true));
    }
  }

  Future<void> deleteProduct(String id) =>
      _db.collection(AppConstants.productsCollection).doc(id).delete();

  Future<List<ProductModel>> searchProducts(String query) async {
    final snap = await _db.collection(AppConstants.productsCollection).get();
    final q = query.toLowerCase();
    return snap.docs
        .map((d) => ProductModel.fromMap(d.data(), d.id))
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q))
        .toList();
  }

  // ─── ORDERS ───
  Future<String> createOrder(OrderModel order) async {
    final ref =
        await _db.collection(AppConstants.ordersCollection).add(order.toMap());
    return ref.id;
  }

  Stream<List<OrderModel>> userOrdersStream(String userId) {
    return _db
        .collection(AppConstants.ordersCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      final orders =
          snap.docs.map((d) => OrderModel.fromMap(d.data(), d.id)).toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  Stream<List<OrderModel>> allOrdersStream() {
    return _db
        .collection(AppConstants.ordersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => OrderModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> updateOrderStatus(String orderId, String status) {
    return _db
        .collection(AppConstants.ordersCollection)
        .doc(orderId)
        .update({'status': status});
  }

  Future<OrderModel?> getOrder(String id) async {
    final doc =
        await _db.collection(AppConstants.ordersCollection).doc(id).get();
    if (!doc.exists) return null;
    return OrderModel.fromMap(doc.data()!, doc.id);
  }

  // ─── REVIEWS ───
  Stream<List<ReviewModel>> productReviewsStream(String productId) {
    return _db
        .collection(AppConstants.reviewsCollection)
        .where('productId', isEqualTo: productId)
        .snapshots()
        .map((snap) {
      final reviews =
          snap.docs.map((d) => ReviewModel.fromMap(d.data(), d.id)).toList();
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    });
  }

  Stream<List<ReviewModel>> allReviewsStream() {
    return _db
        .collection(AppConstants.reviewsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ReviewModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> deleteReview(String id) =>
      _db.collection(AppConstants.reviewsCollection).doc(id).delete();

  Future<void> addReview(ReviewModel review) async {
    final ref = _db.collection(AppConstants.reviewsCollection).doc();
    await ref.set({...review.toMap(), 'productId': review.productId});
    // Update product rating
    final reviews = await _db
        .collection(AppConstants.reviewsCollection)
        .where('productId', isEqualTo: review.productId)
        .get();
    final ratings = reviews.docs
        .map((d) => (d.data()['rating'] as num).toDouble())
        .toList();
    final avg = ratings.isEmpty
        ? 0.0
        : ratings.reduce((a, b) => a + b) / ratings.length;
    await _db
        .collection(AppConstants.productsCollection)
        .doc(review.productId)
        .update({
      'rating': avg,
      'reviewCount': ratings.length,
    });
  }

  // ─── COUPONS ───
  Future<CouponModel?> validateCoupon(String code) async {
    final snap = await _db
        .collection(AppConstants.couponsCollection)
        .where('code', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final coupon =
        CouponModel.fromMap(snap.docs.first.data(), snap.docs.first.id);
    if (!coupon.isActive) return null;
    if (coupon.expiresAt != null &&
        coupon.expiresAt!.isBefore(DateTime.now())) {
      return null;
    }
    return coupon;
  }

  Stream<List<CouponModel>> couponsStream() {
    return _db
        .collection(AppConstants.couponsCollection)
        .orderBy('code')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => CouponModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> upsertCoupon(CouponModel coupon) async {
    final data = coupon.toMap();
    if (coupon.id.isEmpty) {
      await _db.collection(AppConstants.couponsCollection).add(data);
    } else {
      await _db
          .collection(AppConstants.couponsCollection)
          .doc(coupon.id)
          .set(data, SetOptions(merge: true));
    }
  }

  Future<void> deleteCoupon(String id) =>
      _db.collection(AppConstants.couponsCollection).doc(id).delete();

  Future<void> seedDemoStoreData(UserModel user) async {
    final batch = _db.batch();
    final now = Timestamp.fromDate(DateTime.now());

    final categories = [
      {'id': 'fruits', 'name': 'Fruits', 'emoji': '🍎', 'sortOrder': 1},
      {'id': 'vegetables', 'name': 'Vegetables', 'emoji': '🥦', 'sortOrder': 2},
      {'id': 'dairy', 'name': 'Dairy', 'emoji': '🥛', 'sortOrder': 3},
      {'id': 'bakery', 'name': 'Bakery', 'emoji': '🍞', 'sortOrder': 4},
      {'id': 'meat', 'name': 'Meat & Fish', 'emoji': '🥩', 'sortOrder': 5},
      {'id': 'beverages', 'name': 'Beverages', 'emoji': '🧃', 'sortOrder': 6},
      {'id': 'snacks', 'name': 'Snacks', 'emoji': '🍫', 'sortOrder': 7},
      {'id': 'pantry', 'name': 'Pantry', 'emoji': '🏺', 'sortOrder': 8},
      {'id': 'frozen', 'name': 'Frozen', 'emoji': '🧊', 'sortOrder': 9},
      {'id': 'household', 'name': 'Household', 'emoji': '🧽', 'sortOrder': 10},
    ];

    final products = _demoProducts(now);
    final orders = _demoOrders(user.id, products);
    final reviews = _demoReviews(user, products);
    final coupons = [
      {
        'code': 'WELCOME10',
        'discountPercent': 10.0,
        'minOrderAmount': 10.0,
        'maxDiscount': 5.0,
        'isActive': true,
      },
      {
        'code': 'SAVE20',
        'discountPercent': 20.0,
        'minOrderAmount': 25.0,
        'maxDiscount': 12.0,
        'isActive': true,
      },
      {
        'code': 'FRESH15',
        'discountPercent': 15.0,
        'minOrderAmount': 35.0,
        'maxDiscount': 15.0,
        'isActive': true,
      },
      {
        'code': 'BIGBASKET',
        'discountPercent': 25.0,
        'minOrderAmount': 60.0,
        'maxDiscount': 20.0,
        'isActive': true,
      },
      {
        'code': 'FREESHIP',
        'discountPercent': 100.0,
        'minOrderAmount': 0.0,
        'maxDiscount': AppConstants.deliveryFee,
        'isActive': true,
      },
    ];

    for (final category in categories) {
      final id = category['id']! as String;
      final ref = _db.collection(AppConstants.categoriesCollection).doc(id);
      batch.set(ref, {...category}..remove('id'), SetOptions(merge: true));
    }

    for (var i = 0; i < products.length; i++) {
      final ref = _db
          .collection(AppConstants.productsCollection)
          .doc('demo-product-${(i + 1).toString().padLeft(2, '0')}');
      batch.set(ref, products[i], SetOptions(merge: true));
    }

    for (final coupon in coupons) {
      final ref = _db
          .collection(AppConstants.couponsCollection)
          .doc((coupon['code']! as String).toLowerCase());
      batch.set(ref, coupon, SetOptions(merge: true));
    }

    for (var i = 0; i < orders.length; i++) {
      final ref = _db
          .collection(AppConstants.ordersCollection)
          .doc('demo-order-${(i + 1).toString().padLeft(2, '0')}');
      batch.set(ref, orders[i], SetOptions(merge: true));
    }

    for (var i = 0; i < reviews.length; i++) {
      final ref = _db
          .collection(AppConstants.reviewsCollection)
          .doc('demo-review-${(i + 1).toString().padLeft(2, '0')}');
      batch.set(ref, reviews[i], SetOptions(merge: true));
    }

    await batch.commit();
  }

  Stream<AdminStats> adminStatsStream() {
    return allOrdersStream().asyncMap((orders) async {
      final products =
          await _db.collection(AppConstants.productsCollection).count().get();
      final users =
          await _db.collection(AppConstants.usersCollection).count().get();
      final revenue = orders
          .where((o) => o.status.toLowerCase() != 'cancelled')
          .fold(0.0, (total, order) => total + order.total);
      final pending =
          orders.where((o) => o.status.toLowerCase() == 'pending').length;
      return AdminStats(
        totalProducts: products.count ?? 0,
        totalOrders: orders.length,
        totalUsers: users.count ?? 0,
        pendingOrders: pending,
        totalRevenue: revenue,
      );
    });
  }

  // ─── STORAGE ───
  Future<String> uploadImage(File file, String path) async {
    final ref = _storage.ref().child(path);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}

List<Map<String, dynamic>> _demoProducts(Timestamp createdAt) {
  Map<String, dynamic> product(
    String name,
    String category,
    double price,
    String unit,
    int stock,
    String imageUrl, {
    double? originalPrice,
    bool featured = false,
    double rating = 4.5,
    int reviewCount = 24,
  }) {
    return {
      'name': name,
      'description':
          'Fresh quality $name selected for daily grocery shopping and fast home delivery.',
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'category': category,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
      'unit': unit,
      'isFeatured': featured,
      'createdAt': createdAt,
    };
  }

  const img = 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600';
  return [
    product('Red Apples', 'Fruits', 2.49, 'kg', 80, img,
        originalPrice: 2.99, featured: true, rating: 4.8, reviewCount: 128),
    product('Bananas', 'Fruits', 1.19, 'dozen', 120, img,
        featured: true, rating: 4.7, reviewCount: 93),
    product('Fresh Mangoes', 'Fruits', 4.99, 'kg', 45, img,
        originalPrice: 5.99, featured: true, rating: 4.9, reviewCount: 210),
    product('Seedless Grapes', 'Fruits', 3.79, '500g', 55, img),
    product('Oranges', 'Fruits', 2.29, 'kg', 70, img),
    product('Strawberries', 'Fruits', 3.49, 'box', 38, img, featured: true),
    product('Watermelon', 'Fruits', 5.49, 'piece', 25, img),
    product('Pineapple', 'Fruits', 3.99, 'piece', 32, img),
    product('Broccoli', 'Vegetables', 1.59, '500g', 64, img),
    product('Spinach', 'Vegetables', 1.99, 'bag', 48, img),
    product('Roma Tomatoes', 'Vegetables', 2.19, 'kg', 90, img, featured: true),
    product('Potatoes', 'Vegetables', 1.49, 'kg', 110, img),
    product('Carrots', 'Vegetables', 1.29, 'kg', 85, img),
    product('Cucumbers', 'Vegetables', 0.89, 'piece', 76, img),
    product('Green Bell Peppers', 'Vegetables', 2.69, 'kg', 52, img),
    product('Red Onions', 'Vegetables', 1.39, 'kg', 100, img),
    product('Whole Milk', 'Dairy', 1.89, 'L', 95, img,
        featured: true, rating: 4.8),
    product('Greek Yogurt', 'Dairy', 2.79, '500g', 60, img),
    product('Cheddar Cheese', 'Dairy', 3.99, '200g', 45, img),
    product('Butter', 'Dairy', 2.49, '250g', 58, img),
    product('Fresh Cream', 'Dairy', 2.19, '200ml', 40, img),
    product('Cage Free Eggs', 'Dairy', 3.29, '12 pcs', 75, img, featured: true),
    product('Sourdough Bread', 'Bakery', 3.49, 'loaf', 30, img,
        featured: true, rating: 4.9),
    product('Whole Wheat Bread', 'Bakery', 2.49, 'loaf', 44, img),
    product('Croissants', 'Bakery', 4.49, '6 pcs', 24, img),
    product('Burger Buns', 'Bakery', 2.29, 'pack', 36, img),
    product('Chocolate Muffins', 'Bakery', 3.99, '4 pcs', 28, img),
    product('Chicken Breast', 'Meat & Fish', 5.99, 'kg', 42, img,
        featured: true),
    product('Ground Beef', 'Meat & Fish', 6.49, 'kg', 35, img),
    product('Salmon Fillet', 'Meat & Fish', 9.99, '500g', 22, img,
        originalPrice: 11.99, featured: true),
    product('Fresh Prawns', 'Meat & Fish', 8.49, '500g', 20, img),
    product('Tuna Steaks', 'Meat & Fish', 7.49, '500g', 18, img),
    product('Orange Juice', 'Beverages', 2.99, 'L', 62, img, featured: true),
    product('Apple Juice', 'Beverages', 2.79, 'L', 50, img),
    product('Sparkling Water', 'Beverages', 0.89, '750ml', 100, img),
    product('Green Tea', 'Beverages', 3.49, '20 bags', 44, img),
    product('Cold Brew Coffee', 'Beverages', 3.99, '500ml', 36, img),
    product('Mixed Nuts', 'Snacks', 5.99, '300g', 34, img,
        originalPrice: 7.49, featured: true),
    product('Dark Chocolate', 'Snacks', 2.49, '100g', 70, img),
    product('Potato Chips', 'Snacks', 1.89, 'bag', 80, img),
    product('Granola Bars', 'Snacks', 3.29, '6 pcs', 55, img),
    product('Popcorn', 'Snacks', 1.49, 'pack', 65, img),
    product('Basmati Rice', 'Pantry', 6.99, '5kg', 40, img, featured: true),
    product('Olive Oil', 'Pantry', 7.99, '750ml', 38, img),
    product('Pasta', 'Pantry', 1.99, '500g', 78, img),
    product('Tomato Sauce', 'Pantry', 2.29, 'jar', 68, img),
    product('Honey', 'Pantry', 4.99, '500g', 32, img),
    product('Frozen Peas', 'Frozen', 1.79, '500g', 54, img),
    product('Frozen Pizza', 'Frozen', 4.99, 'piece', 26, img),
    product('Dish Soap', 'Household', 2.49, '500ml', 48, img),
  ];
}

List<Map<String, dynamic>> _demoOrders(
  String userId,
  List<Map<String, dynamic>> products,
) {
  final statuses = [
    'pending',
    'processing',
    'shipped',
    'delivered',
    'delivered',
    'cancelled',
    'pending',
    'processing',
    'delivered',
    'shipped',
    'delivered',
    'pending',
  ];

  Map<String, dynamic> item(int index, int quantity) {
    final product = products[index];
    return {
      'productId': 'demo-product-${(index + 1).toString().padLeft(2, '0')}',
      'productName': product['name'],
      'price': product['price'],
      'quantity': quantity,
      'imageUrl': product['imageUrl'],
    };
  }

  Map<String, dynamic> order(int index, List<Map<String, dynamic>> items) {
    final subtotal = items.fold<double>(0.0, (total, line) {
      final price = (line['price'] as num).toDouble();
      final quantity = line['quantity'] as int;
      return total + price * quantity;
    });
    final deliveryFee =
        subtotal >= AppConstants.freeDeliveryThreshold ? 0.0 : 2.99;
    final discount = index % 3 == 0 ? subtotal * 0.1 : 0.0;
    final total = subtotal - discount + deliveryFee;
    return {
      'userId': userId,
      'items': items,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'total': total,
      'status': statuses[index],
      'address': '${120 + index} Market Street',
      'city': index.isEven ? 'Lahore' : 'Karachi',
      'phone': '0300123456${index % 10}',
      'notes': index.isEven ? 'Please call before delivery' : null,
      'paymentMethod': index % 4 == 0 ? 'online' : 'cash',
      'couponCode': discount > 0 ? 'WELCOME10' : null,
      'createdAt': Timestamp.fromDate(
        DateTime.now().subtract(Duration(days: index + 1)),
      ),
    };
  }

  return [
    order(0, [item(0, 2), item(16, 1), item(42, 1)]),
    order(1, [item(10, 3), item(22, 1), item(32, 2)]),
    order(2, [item(27, 1), item(33, 2), item(39, 3)]),
    order(3, [item(2, 1), item(17, 2), item(43, 1)]),
    order(4, [item(5, 2), item(23, 1), item(37, 1)]),
    order(5, [item(29, 1), item(45, 2)]),
    order(6, [item(11, 4), item(18, 1), item(35, 1)]),
    order(7, [item(28, 2), item(40, 2), item(48, 1)]),
    order(8, [item(6, 1), item(21, 1), item(44, 2)]),
    order(9, [item(30, 1), item(36, 3), item(49, 1)]),
    order(10, [item(14, 2), item(19, 2), item(46, 1)]),
    order(11, [item(1, 2), item(24, 1), item(41, 2)]),
  ];
}

List<Map<String, dynamic>> _demoReviews(
  UserModel user,
  List<Map<String, dynamic>> products,
) {
  final comments = [
    'Very fresh and delivered quickly.',
    'Good quality for the price.',
    'Packaging was clean and secure.',
    'Will order this again.',
    'Tasted great and looked fresh.',
    'Perfect for weekly groceries.',
    'Nice deal compared with local stores.',
    'Good stock and fast checkout experience.',
    'Family liked it a lot.',
    'FreshCart quality is solid.',
  ];

  return List.generate(30, (index) {
    final productIndex = index % products.length;
    return {
      'productId':
          'demo-product-${(productIndex + 1).toString().padLeft(2, '0')}',
      'userId': user.id,
      'userName': user.name.isEmpty ? 'Admin User' : user.name,
      'userAvatar': user.avatarUrl,
      'rating': 4.0 + (index % 2) * 0.5,
      'comment': comments[index % comments.length],
      'createdAt': Timestamp.fromDate(
        DateTime.now().subtract(Duration(hours: index + 3)),
      ),
    };
  });
}
