/**
 * seed.js — Run this ONCE to populate Firestore with demo data
 *
 * Setup:
 *   1. npm install firebase-admin
 *   2. Download your Firebase service account key from:
 *      Firebase Console → Project Settings → Service accounts → Generate new private key
 *   3. Save it as serviceAccountKey.json next to this file
 *   4. node seed.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// ─── CATEGORIES ──────────────────────────────────────────────
const categories = [
  { id: 'fruits',    name: 'Fruits',       emoji: '🍎', sortOrder: 1 },
  { id: 'veggies',   name: 'Vegetables',   emoji: '🥦', sortOrder: 2 },
  { id: 'dairy',     name: 'Dairy',        emoji: '🥛', sortOrder: 3 },
  { id: 'beverages', name: 'Beverages',    emoji: '🧃', sortOrder: 4 },
  { id: 'snacks',    name: 'Snacks',       emoji: '🍫', sortOrder: 5 },
  { id: 'frozen',    name: 'Frozen Food',  emoji: '🧊', sortOrder: 6 },
  { id: 'bakery',    name: 'Bakery',       emoji: '🍞', sortOrder: 7 },
  { id: 'meat',      name: 'Meat & Fish',  emoji: '🥩', sortOrder: 8 },
];

// ─── PRODUCTS ────────────────────────────────────────────────
// Replace imageUrl values with real Firebase Storage URLs or any CDN image
const products = [
  // Fruits
  { name: 'Organic Red Apples', category: 'Fruits', price: 2.49, originalPrice: 2.99, unit: 'kg',  stock: 50, rating: 4.8, reviewCount: 124, isFeatured: true,  description: 'Fresh, crispy organic red apples sourced directly from farms. Rich in fiber and vitamin C.',       imageUrl: 'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?w=400' },
  { name: 'Sweet Bananas',       category: 'Fruits', price: 0.99, unit: 'bunch', stock: 80, rating: 4.6, reviewCount: 89,  isFeatured: false, description: 'Sweet and creamy bananas, perfect for snacking or smoothies.',                                        imageUrl: 'https://images.unsplash.com/photo-1481349518771-20055b2a7b24?w=400' },
  { name: 'Alphonso Mangoes',    category: 'Fruits', price: 4.99, unit: 'kg',  stock: 30, rating: 4.9, reviewCount: 201, isFeatured: true,  description: 'Premium Alphonso mangoes — the king of fruits. Exceptionally sweet and aromatic.',                    imageUrl: 'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=400' },
  { name: 'Fresh Strawberries',  category: 'Fruits', price: 3.49, unit: 'box', stock: 40, rating: 4.7, reviewCount: 156, isFeatured: true,  description: 'Plump, juicy strawberries picked at peak ripeness.',                                                   imageUrl: 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=400' },

  // Vegetables
  { name: 'Broccoli',            category: 'Vegetables', price: 1.29, unit: '500g', stock: 60, rating: 4.5, reviewCount: 73,  isFeatured: false, description: 'Fresh green broccoli, rich in vitamins and minerals.',                                              imageUrl: 'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?w=400' },
  { name: 'Baby Spinach',        category: 'Vegetables', price: 2.19, unit: 'bag',  stock: 45, rating: 4.6, reviewCount: 98,  isFeatured: false, description: 'Tender baby spinach leaves, washed and ready to eat.',                                             imageUrl: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400' },
  { name: 'Roma Tomatoes',       category: 'Vegetables', price: 1.99, unit: 'kg',   stock: 70, rating: 4.4, reviewCount: 61,  isFeatured: true,  description: 'Firm and flavourful Roma tomatoes, great for salads and cooking.',                                  imageUrl: 'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=400' },

  // Dairy
  { name: 'Fresh Whole Milk',    category: 'Dairy', price: 1.89, unit: 'L',    stock: 100, rating: 4.7, reviewCount: 212, isFeatured: true,  description: 'Pure, pasteurised whole milk from grass-fed cows.',                                                    imageUrl: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400' },
  { name: 'Greek Yogurt',        category: 'Dairy', price: 2.49, unit: '500g', stock: 60,  rating: 4.8, reviewCount: 178, isFeatured: false, description: 'Thick and creamy Greek-style yogurt, high in protein.',                                                imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400' },
  { name: 'Cheddar Cheese',      category: 'Dairy', price: 3.99, unit: '200g', stock: 40,  rating: 4.6, reviewCount: 94,  isFeatured: false, description: 'Mature cheddar cheese with a rich, sharp flavour.',                                                    imageUrl: 'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=400' },

  // Beverages
  { name: 'Orange Juice',        category: 'Beverages', price: 2.99, unit: 'L',    stock: 55, rating: 4.5, reviewCount: 134, isFeatured: true,  description: 'Freshly squeezed orange juice, no added sugar.',                                                     imageUrl: 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=400' },
  { name: 'Sparkling Water',     category: 'Beverages', price: 0.79, unit: '750ml', stock: 90, rating: 4.3, reviewCount: 67,  isFeatured: false, description: 'Refreshing naturally sparkling mineral water.',                                                      imageUrl: 'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=400' },

  // Snacks
  { name: 'Mixed Nuts',          category: 'Snacks', price: 5.99, originalPrice: 7.49, unit: '300g', stock: 35, rating: 4.7, reviewCount: 88,  isFeatured: true,  description: 'Premium roasted mixed nuts — almonds, cashews, walnuts and more.',                imageUrl: 'https://images.unsplash.com/photo-1508747703725-719777637510?w=400' },
  { name: 'Dark Chocolate',      category: 'Snacks', price: 2.49, unit: '100g', stock: 50, rating: 4.8, reviewCount: 203, isFeatured: false, description: '70% cacao dark chocolate bar with a rich, intense flavour.',                                            imageUrl: 'https://images.unsplash.com/photo-1548907040-4d42b8e2d8b2?w=400' },

  // Bakery
  { name: 'Sourdough Bread',     category: 'Bakery', price: 3.49, unit: 'loaf', stock: 25, rating: 4.9, reviewCount: 145, isFeatured: true,  description: 'Artisan sourdough bread baked fresh daily. Crispy crust, chewy interior.',                             imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400' },
];

// ─── COUPONS ─────────────────────────────────────────────────
const coupons = [
  { code: 'WELCOME10', discountPercent: 10, minOrderAmount: 10, maxDiscount: 5,  isActive: true },
  { code: 'SAVE20',    discountPercent: 20, minOrderAmount: 25, maxDiscount: 10, isActive: true },
  { code: 'FREESHIP',  discountPercent: 100, minOrderAmount: 0, maxDiscount: 2.99, isActive: true },
];

async function seed() {
  console.log('🌱 Seeding Firestore...\n');

  const batch = db.batch();
  const now = admin.firestore.FieldValue.serverTimestamp();

  // Categories
  for (const cat of categories) {
    const ref = db.collection('categories').doc(cat.id);
    batch.set(ref, cat);
  }
  console.log(`✅ ${categories.length} categories queued`);

  // Products
  for (const prod of products) {
    const ref = db.collection('products').doc();
    batch.set(ref, { ...prod, createdAt: now });
  }
  console.log(`✅ ${products.length} products queued`);

  // Coupons
  for (const coupon of coupons) {
    const ref = db.collection('coupons').doc();
    batch.set(ref, coupon);
  }
  console.log(`✅ ${coupons.length} coupons queued`);

  await batch.commit();
  console.log('\n🎉 Firestore seeded successfully!');
  process.exit(0);
}

seed().catch((err) => {
  console.error('❌ Seed failed:', err);
  process.exit(1);
});
