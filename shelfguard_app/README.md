# ShelfGuard Flutter App

Cross-platform Flutter application for tracking product expiry dates with barcode scanning and push notifications.

## Features

- 📱 **Cross-platform** - Android and Web support
- 📷 **Barcode/QR Scanning** - Quick product entry
- 🔔 **Push Notifications** - Automated expiry alerts
- 💾 **Offline-first** - Works without internet
- 🎨 **Custom Fields** - Flexible product data schema
- 📊 **Dashboard** - Quick overview and statistics
- 🔍 **Advanced Filtering** - Search and sort products
- 📤 **Export/Import** - CSV and Excel support
- 🌙 **Dark Mode** - System-based theme switching
- 🔒 **Secure** - JWT authentication

## Tech Stack

- **Framework:** Flutter 3.16+
- **State Management:** flutter_bloc
- **Navigation:** go_router
- **Local Storage:** Hive
- **Networking:** Dio + Retrofit
- **Notifications:** Firebase Cloud Messaging
- **Barcode Scanning:** mobile_scanner
- **Dependency Injection:** get_it + injectable

## Prerequisites

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)
- VS Code or Android Studio

## Installation

### 1. Install Flutter

Follow the official Flutter installation guide:
https://flutter.dev/docs/get-started/install

### 2. Clone the repository

```bash
git clone <repository-url>
cd shelfguard_app
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Configure Firebase

1. Create a Firebase project at https://console.firebase.google.com
2. Add Android app to your Firebase project
3. Download `google-services.json` and place it in `android/app/`
4. Add Web app to your Firebase project
5. Copy Firebase config and update `web/index.html`

### 5. Update API endpoint

Edit `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'http://your-backend-url/api/v1';
```

### 6. Generate code

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Running the App

### Android

```bash
flutter run -d android
```

### Web

```bash
flutter run -d chrome
```

### Build for Production

Android APK:
```bash
flutter build apk --release
```

Android App Bundle:
```bash
flutter build appbundle --release
```

Web:
```bash
flutter build web --release
```

## Project Structure

```
shelfguard_app/
├── lib/
│   ├── core/                    # Core functionality
│   │   ├── constants/           # App constants
│   │   ├── di/                  # Dependency injection
│   │   ├── network/             # API client
│   │   ├── routing/             # Navigation
│   │   ├── storage/             # Local storage
│   │   └── theme/               # App themes
│   ├── features/                # Feature modules
│   │   ├── auth/                # Authentication
│   │   │   ├── data/            # Data layer
│   │   │   ├── domain/          # Business logic
│   │   │   └── presentation/    # UI layer
│   │   ├── dashboard/           # Dashboard feature
│   │   ├── products/            # Product management
│   │   ├── settings/            # App settings
│   │   └── notifications/       # Notifications
│   ├── shared/                  # Shared widgets
│   └── main.dart                # App entry point
├── test/                        # Unit tests
├── integration_test/            # Integration tests
├── assets/                      # Images, fonts, etc.
└── pubspec.yaml                 # Dependencies
```

## Architecture

This app follows **Clean Architecture** principles:

- **Presentation Layer**: UI components, BLoCs, and pages
- **Domain Layer**: Entities, use cases, and repository interfaces
- **Data Layer**: Models, data sources, and repository implementations

### State Management

We use **BLoC (Business Logic Component)** pattern:
- Separates business logic from UI
- Reactive state updates
- Easy to test

## Key Features Implementation

### 1. Barcode Scanning

```dart
import 'package:mobile_scanner/mobile_scanner.dart';

// Scan barcode
final result = await Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => ScanProductPage()),
);
```

### 2. Offline-first Storage

Products are cached locally using Hive:
- Automatic sync when online
- Queue for offline changes
- Conflict resolution

### 3. Push Notifications

Firebase Cloud Messaging integration:
- Background notifications
- Foreground handling
- Custom notification actions

### 4. Custom Fields

Dynamic form generation based on shop configuration:
- Text, number, date, boolean, select
- Validation support
- Stored as JSON

## Testing

### Run unit tests

```bash
flutter test
```

### Run integration tests

```bash
flutter test integration_test
```

### Run tests with coverage

```bash
flutter test --coverage
```

## Configuration

### API Endpoint

Update in `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'https://api.yourbackend.com/api/v1';
```

### Notification Settings

Default notification days can be configured in:
`lib/core/constants/app_constants.dart`

```dart
static const List<int> defaultNotificationDays = [7, 3, 0];
```

## Building for Production

### Android

1. Update `android/app/build.gradle` with signing config
2. Build:
   ```bash
   flutter build appbundle --release
   ```
3. Upload to Google Play Console

### Web

1. Build:
   ```bash
   flutter build web --release
   ```
2. Deploy the `build/web` directory to your hosting service

## Troubleshooting

### Common Issues

**Issue: Build fails with "google-services.json not found"**
- Solution: Download from Firebase Console and place in `android/app/`

**Issue: Barcode scanner not working**
- Solution: Ensure camera permissions are granted

**Issue: Network error**
- Solution: Check API endpoint in `api_constants.dart`

## Performance Tips

- Use `const` constructors where possible
- Implement lazy loading for product lists
- Optimize images before including in assets
- Use `flutter build apk --split-per-abi` for smaller APKs

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write tests
5. Submit a pull request

## License

MIT

## Support

For issues and questions, please open an issue on GitHub.
