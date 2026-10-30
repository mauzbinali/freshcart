# 🛒 FreshCart – Flutter Grocery Shopping App

**FreshCart** is a feature-rich online grocery shopping application built using **Flutter and Firebase**. It provides a complete grocery shopping experience, allowing customers to browse products, manage their shopping carts, place orders, track deliveries, and manage their accounts.

The application also includes a dedicated **Admin Portal** for managing products and store operations.

## ✨ Features

### 🛍️ Customer Application
- **User Authentication:** Secure registration and login using Firebase Authentication.
- **Product Browsing:** Explore grocery products with organized categories.
- **Product Details:** View product information and images.
- **Shopping Cart:** Add, remove, and update product quantities.
- **Checkout:** Complete the shopping process and place orders.
- **Order Tracking:** Track order progress and status.
- **Wishlist:** Save favorite products for later.
- **Product Reviews:** Submit and view product reviews.
- **Coupons & Discounts:** Apply promotional coupons.
- **Dark Mode:** Switch between light and dark themes.
- **Responsive UI:** Modern and user-friendly interface.

### 🔐 Admin Portal
- Manage grocery products and store data.
- Upload and manage product images.
- Manage product information.
- Support store management operations through Firebase.

### 🎨 UI & User Experience
- Modern Material Design interface.
- Smooth navigation and transitions.
- Shimmer loading effects.
- Cached network images.
- Interactive UI components.
- Notification and feedback overlays.

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application development |
| Dart | Programming language |
| Firebase Authentication | User authentication |
| Cloud Firestore | Database |
| Firebase Storage | Image and file storage |
| Riverpod | State management |
| GoRouter | Navigation and routing |
| Shared Preferences | Local preferences |
| Cached Network Image | Image caching |
| Shimmer | Loading animations |
| Image Picker | Image selection |
| Overlay Support | Notifications and overlays |

## 📁 Project Structure

```text
freshcart/
│
├── android/
├── ios/
├── lib/
│
├── test/
│
├── assets/
│   ├── images/
│   └── lottie/
│
├── firebase.json
├── firestore.rules
├── storage.rules
├── seed.js
├── pubspec.yaml
└── README.md
```

## 🚀 Getting Started

Follow these steps to run FreshCart locally.

### 1. Clone the Repository

```bash
git clone https://github.com/mauzbinali/freshcart.git
```

### 2. Open the Project

```bash
cd freshcart
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Configure Firebase

FreshCart uses Firebase services. Configure your own Firebase project before running the application.

1. Create a project in the [Firebase Console](https://console.firebase.google.com/).
2. Configure Firebase for your Android/iOS application.
3. Enable Firebase Authentication.
4. Set up Cloud Firestore.
5. Configure Firebase Storage.
6. Add the appropriate Firebase configuration files.

You can also use the FlutterFire CLI to configure Firebase:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

### 5. Run the Application

```bash
flutter run
```

## 📦 Dependencies

Some of the main packages used in this project:

- `firebase_core`
- `firebase_auth`
- `cloud_firestore`
- `firebase_storage`
- `flutter_riverpod`
- `go_router`
- `cached_network_image`
- `flutter_carousel_widget`
- `shimmer`
- `overlay_support`
- `image_picker`
- `shared_preferences`
- `intl`
- `uuid`

## 🔥 Firebase Services

FreshCart integrates Firebase to support its backend functionality:

- **Firebase Authentication:** Handles user authentication.
- **Cloud Firestore:** Stores application data.
- **Firebase Storage:** Handles product images and uploaded files.

## 🎯 Project Goals

FreshCart was developed to demonstrate practical Flutter development skills and the implementation of a complete grocery shopping workflow.

The project focuses on:
- Building real-world mobile application features.
- Implementing Firebase backend integration.
- Managing application state using Riverpod.
- Structuring navigation using GoRouter.
- Creating reusable and responsive UI components.
- Developing customer-facing and administrative functionality.

## 👨‍💻 Developer

**Mauz Bin Ali**

Flutter Developer | Mobile App Developer

- GitHub: [@mauzbinali](https://github.com/mauzbinali)
- LinkedIn: [Mauz Bin Ali](https://linkedin.com/in/muaz-bin-ali)

---

⭐ If you find this project useful, consider giving it a star!
