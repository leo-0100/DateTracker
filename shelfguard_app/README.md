# ShelfGuard - Product Expiry Tracker

A beautiful, modern Flutter application for tracking product expiry dates and preventing food waste.

## Features

### ✨ Modern UI/UX
- **Material Design 3** with beautiful animations and transitions
- **Dark/Light theme** support (system-based)
- **Smooth page transitions** with fade and slide effects
- **Custom widgets** for consistent design across the app
- **Responsive layouts** that work on all screen sizes

### 🔐 Authentication
- Beautiful login and signup pages with validation
- Animated form fields with focus states
- Password visibility toggle
- Form validation with helpful error messages
- Demo mode for easy testing

### 📊 Dashboard
- **Statistics cards** showing:
  - Total products
  - Expired products
  - Critical products (≤3 days)
  - Expiring soon (≤7 days)
- **Urgent products** section highlighting items needing attention
- Pull-to-refresh functionality
- Quick navigation to product details

### 📦 Product Management
- **Product List** with:
  - Search functionality
  - Filter by status (All, Expired, Critical, Expiring Soon, Safe)
  - Sort by name or expiry date
  - Visual status indicators with color coding
  - Swipe actions and long-press menus
- **Product Details** with:
  - Status banner with color coding
  - Complete product information
  - Edit and delete actions
  - Share functionality (coming soon)
- **Add/Edit Product** with:
  - Form validation
  - Category picker
  - Date picker for expiry dates
  - Barcode input with scanner option
  - Notes field

### 📱 Barcode Scanner
- Beautiful scanner UI with animated scan line
- Custom overlay with corner brackets
- Manual barcode entry option
- Camera flash toggle

### ⚙️ Settings
- User profile display
- Notification controls
- Dark mode toggle
- Biometric authentication
- Data export/import
- Cache management
- Privacy policy and terms
- About page

## Tech Stack

- **Flutter** 3.16+
- **Dart** 3.0+
- **State Management**: BLoC/Cubit pattern with flutter_bloc
- **Navigation**: GoRouter for declarative routing
- **Dependency Injection**: GetIt + Injectable
- **Local Storage**: Hive + SharedPreferences
- **Networking**: Dio
- **UI Components**:
  - google_fonts for typography
  - intl for date formatting
  - Custom widgets for consistency

## Project Structure

```
lib/
├── core/
│   ├── theme/           # App theme configuration
│   └── routing/         # Navigation setup
├── features/
│   ├── auth/            # Authentication
│   │   ├── domain/
│   │   │   └── entities/
│   │   └── presentation/
│   │       ├── bloc/
│   │       └── pages/
│   ├── dashboard/       # Dashboard
│   │   └── presentation/
│   ├── products/        # Product management
│   │   ├── domain/
│   │   │   └── entities/
│   │   └── presentation/
│   │       └── pages/
│   └── settings/        # Settings
│       └── presentation/
├── shared/
│   └── widgets/         # Reusable components
└── main.dart            # App entry point
```

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code with Flutter extension

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd DateTracker/shelfguard_app
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## Key Features Implemented

### Custom Widgets
- **CustomButton**: Versatile button with loading states and icon support
- **CustomTextField**: Enhanced text field with focus animations
- **StatCard**: Beautiful statistics card for dashboard
- **ProductCard**: Product display card with status indicators
- **EmptyState**: Consistent empty state UI
- **LoadingOverlay**: Loading indicator with message support

### Animations & Transitions
- Page transitions with slide and fade effects
- Form field focus animations
- Login/Signup page entrance animations
- Scanner animation with moving scan line
- Smooth navigation between screens

### Color Coding System
- **Green**: Safe products (>7 days)
- **Orange**: Expiring soon (≤7 days)
- **Red**: Critical (≤3 days) or Expired

### Navigation Flow
```
Login → Dashboard → Products/Scan/Settings
         ↓
    Product List → Product Detail → Edit
         ↓
    Add Product ← Scan Barcode
```

## Demo Mode

The app includes demo mode for easy testing:
- Use any email and password to login
- Mock products are displayed in the dashboard and product list
- All features are functional with simulated data

## Future Enhancements

- [ ] Backend integration with API
- [ ] Real barcode scanning with camera
- [ ] Push notifications for expiring products
- [ ] Data export/import functionality
- [ ] Multiple user accounts
- [ ] Cloud sync
- [ ] Shopping list integration
- [ ] Recipe suggestions based on expiring products
- [ ] Waste tracking analytics
- [ ] Multi-language support

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

## Contact

For questions or feedback, please open an issue on GitHub.

---

**Built with ❤️ using Flutter**
