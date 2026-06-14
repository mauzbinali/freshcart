class AppConstants {
  // Firestore collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String categoriesCollection = 'categories';
  static const String reviewsCollection = 'reviews';
  static const String couponsCollection = 'coupons';

  // Storage paths
  static const String productImagesPath = 'product_images';
  static const String userAvatarsPath = 'user_avatars';
  static const String categoryImagesPath = 'category_images';

  // Delivery fee
  static const double deliveryFee = 2.99;
  static const double freeDeliveryThreshold = 30.0;

  // Pagination
  static const int productsPerPage = 20;
  static const int ordersPerPage = 10;

  // Banner images (use network URLs or local assets)
  static const List<Map<String, String>> banners = [
    {
      'title': 'Fresh Vegetables',
      'subtitle': 'Up to 30% off this week',
      'tag': 'New Arrivals',
      'emoji': '🥦',
      'color': '0xFF2E7D32',
    },
    {
      'title': 'Summer Fruits Sale',
      'subtitle': 'Buy 2 get 1 free',
      'tag': 'Hot Deal',
      'emoji': '🍉',
      'color': '0xFFAD1457',
    },
    {
      'title': 'Grocery Discounts',
      'subtitle': 'Save on daily essentials',
      'tag': 'Special Offer',
      'emoji': '🛒',
      'color': '0xFF1565C0',
    },
  ];
}
