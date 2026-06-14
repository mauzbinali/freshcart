import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────
// USER MODEL
// ─────────────────────────────────────────────
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? avatarUrl;
  final DateTime createdAt;
  final List<String> wishlist;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = 'user',
    this.avatarUrl,
    required this.createdAt,
    this.wishlist = const [],
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'user',
      avatarUrl: map['avatarUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      wishlist: List<String>.from(map['wishlist'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'avatarUrl': avatarUrl,
        'createdAt': Timestamp.fromDate(createdAt),
        'wishlist': wishlist,
      };

  UserModel copyWith({
    String? name,
    String? phone,
    String? role,
    String? avatarUrl,
    List<String>? wishlist,
  }) =>
      UserModel(
        id: id,
        name: name ?? this.name,
        email: email,
        phone: phone ?? this.phone,
        role: role ?? this.role,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        createdAt: createdAt,
        wishlist: wishlist ?? this.wishlist,
      );
}

// ─────────────────────────────────────────────
// CATEGORY MODEL
// ─────────────────────────────────────────────
class CategoryModel {
  final String id;
  final String name;
  final String emoji;
  final String? imageUrl;
  final int sortOrder;

  CategoryModel({
    required this.id,
    required this.name,
    required this.emoji,
    this.imageUrl,
    this.sortOrder = 0,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) =>
      CategoryModel(
        id: id,
        name: map['name'] ?? '',
        emoji: map['emoji'] ?? '🛒',
        imageUrl: map['imageUrl'],
        sortOrder: map['sortOrder'] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'emoji': emoji,
        'imageUrl': imageUrl,
        'sortOrder': sortOrder,
      };
}

// ─────────────────────────────────────────────
// PRODUCT MODEL
// ─────────────────────────────────────────────
class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final String category;
  final int stock;
  final double rating;
  final int reviewCount;
  final String unit;
  final bool isFeatured;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    required this.category,
    required this.stock,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.unit = 'kg',
    this.isFeatured = false,
    required this.createdAt,
  });

  bool get isOnSale => originalPrice != null && originalPrice! > price;
  double get discountPercent =>
      isOnSale ? ((originalPrice! - price) / originalPrice! * 100) : 0;

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) =>
      ProductModel(
        id: id,
        name: map['name'] ?? '',
        description: map['description'] ?? '',
        price: (map['price'] ?? 0.0).toDouble(),
        originalPrice: map['originalPrice']?.toDouble(),
        imageUrl: map['imageUrl'] ?? '',
        category: map['category'] ?? '',
        stock: map['stock'] ?? 0,
        rating: (map['rating'] ?? 0.0).toDouble(),
        reviewCount: map['reviewCount'] ?? 0,
        unit: map['unit'] ?? 'kg',
        isFeatured: map['isFeatured'] ?? false,
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'price': price,
        'originalPrice': originalPrice,
        'imageUrl': imageUrl,
        'category': category,
        'stock': stock,
        'rating': rating,
        'reviewCount': reviewCount,
        'unit': unit,
        'isFeatured': isFeatured,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

// ─────────────────────────────────────────────
// CART ITEM MODEL
// ─────────────────────────────────────────────
class CartItem {
  final String productId;
  final String productName;
  final double price;
  int quantity;
  final String imageUrl;
  final String unit;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.unit,
  });

  double get subtotal => price * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        productId: productId,
        productName: productName,
        price: price,
        quantity: quantity ?? this.quantity,
        imageUrl: imageUrl,
        unit: unit,
      );

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productName': productName,
        'price': price,
        'quantity': quantity,
        'imageUrl': imageUrl,
        'unit': unit,
      };

  factory CartItem.fromProduct(ProductModel product, {int quantity = 1}) =>
      CartItem(
        productId: product.id,
        productName: product.name,
        price: product.price,
        quantity: quantity,
        imageUrl: product.imageUrl,
        unit: product.unit,
      );
}

// ─────────────────────────────────────────────
// ORDER ITEM MODEL
// ─────────────────────────────────────────────
class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String imageUrl;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  double get subtotal => price * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
        productId: map['productId'] ?? '',
        productName: map['productName'] ?? '',
        price: (map['price'] ?? 0.0).toDouble(),
        quantity: map['quantity'] ?? 1,
        imageUrl: map['imageUrl'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productName': productName,
        'price': price,
        'quantity': quantity,
        'imageUrl': imageUrl,
      };

  factory OrderItem.fromCartItem(CartItem item) => OrderItem(
        productId: item.productId,
        productName: item.productName,
        price: item.price,
        quantity: item.quantity,
        imageUrl: item.imageUrl,
      );
}

// ─────────────────────────────────────────────
// ORDER MODEL
// ─────────────────────────────────────────────
class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final String status;
  final String address;
  final String city;
  final String phone;
  final String? notes;
  final String paymentMethod;
  final String? couponCode;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.status,
    required this.address,
    required this.city,
    required this.phone,
    this.notes,
    required this.paymentMethod,
    this.couponCode,
    required this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) => OrderModel(
        id: id,
        userId: map['userId'] ?? '',
        items: (map['items'] as List<dynamic>? ?? [])
            .map((e) => OrderItem.fromMap(e))
            .toList(),
        subtotal: (map['subtotal'] ?? 0.0).toDouble(),
        deliveryFee: (map['deliveryFee'] ?? 0.0).toDouble(),
        discount: (map['discount'] ?? 0.0).toDouble(),
        total: (map['total'] ?? 0.0).toDouble(),
        status: map['status'] ?? 'pending',
        address: map['address'] ?? '',
        city: map['city'] ?? '',
        phone: map['phone'] ?? '',
        notes: map['notes'],
        paymentMethod: map['paymentMethod'] ?? 'cash',
        couponCode: map['couponCode'],
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'items': items.map((e) => e.toMap()).toList(),
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'discount': discount,
        'total': total,
        'status': status,
        'address': address,
        'city': city,
        'phone': phone,
        'notes': notes,
        'paymentMethod': paymentMethod,
        'couponCode': couponCode,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

// ─────────────────────────────────────────────
// REVIEW MODEL
// ─────────────────────────────────────────────
class ReviewModel {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) =>
      ReviewModel(
        id: id,
        productId: map['productId'] ?? '',
        userId: map['userId'] ?? '',
        userName: map['userName'] ?? '',
        userAvatar: map['userAvatar'],
        rating: (map['rating'] ?? 0.0).toDouble(),
        comment: map['comment'] ?? '',
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'userId': userId,
        'userName': userName,
        'userAvatar': userAvatar,
        'rating': rating,
        'comment': comment,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

// ─────────────────────────────────────────────
// COUPON MODEL
// ─────────────────────────────────────────────
class CouponModel {
  final String id;
  final String code;
  final double discountPercent;
  final double? maxDiscount;
  final double minOrderAmount;
  final bool isActive;
  final DateTime? expiresAt;

  CouponModel({
    required this.id,
    required this.code,
    required this.discountPercent,
    this.maxDiscount,
    this.minOrderAmount = 0,
    this.isActive = true,
    this.expiresAt,
  });

  factory CouponModel.fromMap(Map<String, dynamic> map, String id) =>
      CouponModel(
        id: id,
        code: map['code'] ?? '',
        discountPercent: (map['discountPercent'] ?? 0.0).toDouble(),
        maxDiscount: map['maxDiscount']?.toDouble(),
        minOrderAmount: (map['minOrderAmount'] ?? 0.0).toDouble(),
        isActive: map['isActive'] ?? true,
        expiresAt: (map['expiresAt'] as Timestamp?)?.toDate(),
      );

  Map<String, dynamic> toMap() => {
        'code': code.toUpperCase(),
        'discountPercent': discountPercent,
        'maxDiscount': maxDiscount,
        'minOrderAmount': minOrderAmount,
        'isActive': isActive,
        'expiresAt': expiresAt == null ? null : Timestamp.fromDate(expiresAt!),
      };
}

class AdminStats {
  final int totalProducts;
  final int totalOrders;
  final int totalUsers;
  final int pendingOrders;
  final double totalRevenue;

  const AdminStats({
    required this.totalProducts,
    required this.totalOrders,
    required this.totalUsers,
    required this.pendingOrders,
    required this.totalRevenue,
  });
}
