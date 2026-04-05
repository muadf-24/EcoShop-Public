# EcoShop - Next-Gen Eco-Friendly E-Commerce

EcoShop is a premium, multi-platform e-commerce solution built with Flutter and Firebase. It focuses on sustainability, performance, and a seamless user experience across Mobile and Web.

## ✨ Features

- **Real-time Discovery**: Advanced product filtering, search, and categorization.
- **Dynamic Cart & Checkout**: Seamless shopping flow with promo code support and Stripe integration.
- **Advanced Profiles**: User avatar management, saved address reuse, and order history.
- **Offline-First Sync**: Automatic data reconciliation between local storage (Hive) and Firestore.
- **Premium UX**: Smooth animations (`flutter_animate`), shimmer effects, and dark mode support.
- **Cross-Platform**: Tailored experiences for Android, iOS, and Web.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (v3.10+)
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) (Clean Architecture)
- **Backend**: [Firebase](https://firebase.google.com) (Auth, Firestore, Storage, Messaging)
- **Local Storage**: [Hive](https://pub.dev/packages/hive) & [Shared Preferences](https://pub.dev/packages/shared_preferences)
- **Dependency Injection**: [GetIt](https://pub.dev/packages/get_it)
- **Payments**: [flutter_stripe](https://pub.dev/packages/flutter_stripe)
- **Animations**: [flutter_animate](https://pub.dev/packages/flutter_animate) & [Lottie](https://pub.dev/packages/lottie)

## 🏗️ Architecture

The project follows **Clean Architecture** principles, separated into four layers:

1.  **Core**: Reusable services, themes, widgets, and utilities.
2.  **Data**: Repository implementations, data sources (Remote/Local), and models.
3.  **Domain**: Enitities, Repository interfaces, and UseCases.
4.  **Presentation**: BLoCs, Screens, and Widgets.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- Firebase Account (with `google-services.json` and `GoogleService-Info.plist`)
- Stripe Account (for real payments)

### Installation

1.  Clone the repository:
    ```bash
    git clone https://github.com/your-username/ecoshop.git
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Initialize Firebase:
    ```bash
    flutterfire configure
    ```
4.  Run the app:
    ```bash
    flutter run
    ```

## 🧪 Testing

To run the full test suite:
```bash
flutter test
```

---

Built with ❤️ for a greener planet.
