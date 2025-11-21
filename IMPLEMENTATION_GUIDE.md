# ShelfGuard - New Features Implementation Guide

## Overview
This guide documents the implementation of 5 major feature enhancements to the ShelfGuard app:

1. **Smart Notifications & Reminders**
2. **Barcode Database Integration** (Open Food Facts API)
3. **Analytics & Insights**
4. **Storage Location Management**
5. **Gamification System**

---

## 1. Smart Notifications & Reminders

### Files Created
- `lib/core/services/notification_service.dart`

### Features Implemented
- **Local push notifications** for product expiry alerts
- **Multiple notification intervals**: 1 day, 3 days, 7 days before expiry, and on expiry day
- **Customizable notification preferences** (users can enable/disable each interval)
- **Daily summary notifications** (optional, scheduled at 9 AM)
- **Permission handling** for Android and iOS

### Dependencies Added
```yaml
flutter_local_notifications: ^17.0.0
timezone: ^0.9.2
permission_handler: ^11.0.1
```

### Usage Example
```dart
final notificationService = NotificationService();

// Initialize
await notificationService.initialize();
await notificationService.requestPermissions();

// Schedule notifications for a product
await notificationService.scheduleProductExpiryNotifications(
  productId: 'product_123',
  productName: 'Fresh Milk',
  expiryDate: DateTime.now().add(Duration(days: 5)),
);

// Cancel notifications
await notificationService.cancelProductNotifications('product_123');
```

### Integration Points
- **Add/Edit Product**: Call `scheduleProductExpiryNotifications()` when saving a product
- **Delete Product**: Call `cancelProductNotifications()` when deleting a product
- **Settings Page**: Add UI controls for notification preferences using the service's getter/setter methods

### Android Setup Required
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

### iOS Setup Required
Update `ios/Runner/Info.plist`:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

---

## 2. Barcode Database Integration

### Files Created
- `lib/core/services/open_food_facts_service.dart`

### Features Implemented
- **Auto-fetch product information** from barcode using Open Food Facts API
- **Product name extraction** with fallback to English name
- **Category mapping** to app categories
- **Image URL extraction** for product thumbnails
- **Shelf life suggestions** based on product category
- **Search functionality** for manual product lookup

### API Used
- **Open Food Facts API**: https://world.openfoodfacts.org/api/v2
- No API key required (free, open database)
- Global product database with millions of products

### Usage Example
```dart
final service = OpenFoodFactsService();

// Fetch by barcode
final productInfo = await service.getProductByBarcode('3017620422003');

if (productInfo != null && productInfo.isValid) {
  print('Name: ${productInfo.name}');
  print('Category: ${productInfo.category}');
  print('Brand: ${productInfo.brand}');

  // Get suggested shelf life
  final shelfLife = OpenFoodFactsService.getTypicalShelfLifeDays(
    productInfo.category ?? 'Other',
  );
}
```

### Category Mapping
The service automatically maps Open Food Facts categories to app categories:
- Dairy, Meat, Fruits, Vegetables, Beverages, Snacks, Frozen, Bakery, Condiments, Grains, Other

### Integration Points
- **Scanner Page**: After scanning barcode, fetch product info and pre-fill form
- **Add Product Page**: Show loading indicator while fetching, auto-populate fields
- **Product Detail Page**: Display product image if available

---

## 3. Analytics & Insights

### Files Created
- `lib/features/analytics/domain/entities/waste_record.dart`
- `lib/features/analytics/domain/entities/user_stats.dart`
- `lib/features/analytics/domain/entities/achievement.dart`
- `lib/features/analytics/data/services/analytics_service.dart`
- `lib/features/analytics/presentation/pages/analytics_page.dart`

### Features Implemented

#### Waste Tracking
- Track products that were wasted with reasons (expired, spoiled, forgotten, too much, other)
- Calculate total waste cost
- Category-wise waste breakdown
- Monthly waste trends

#### User Statistics
- Total products added/wasted/saved
- Current and longest streaks (consecutive days without waste)
- Total waste cost vs savings cost
- Waste percentage and save percentage
- Monthly waste tracking
- Category-wise waste analytics

#### Visualizations
- **Pie Chart**: Waste by category
- **Bar Chart**: Monthly waste trend
- **Progress Bars**: Save percentage
- **Stat Cards**: Key metrics overview

### Dependencies Added
```yaml
fl_chart: ^0.66.0  # For charts and graphs
```

### Usage Example
```dart
final analyticsService = AnalyticsService();

// Track when adding a product
await analyticsService.incrementProductsAdded();

// Track when saving a product (consumed before expiry)
await analyticsService.incrementProductsSaved(savedCost: 5.99);

// Track waste when deleting expired product
final wasteRecord = WasteRecord(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  productName: 'Milk',
  category: 'Dairy',
  quantity: 1,
  reason: WasteReason.expired,
  estimatedCost: 3.99,
  wasteDate: DateTime.now(),
  notes: 'Forgot to check expiry',
);
await analyticsService.addWasteRecord(wasteRecord);

// Get stats
final stats = await analyticsService.getUserStats();
print('Waste percentage: ${stats.wastePercentage}%');
print('Current streak: ${stats.currentStreak} days');
```

### Integration Points
- **Add Product**: Call `incrementProductsAdded()`
- **Delete Product**: Show waste tracking dialog if expired
- **Scanner**: Call `incrementScans()` when barcode is scanned
- **Dashboard**: Display summary stats
- **Navigation**: Add route to Analytics Page

---

## 4. Storage Location Management

### Files Modified
- `lib/features/products/domain/entities/product.dart`

### Features Implemented
- **Storage location field** added to Product model
- **8 predefined locations**: Refrigerator, Freezer, Pantry, Cabinet, Counter, Garage, Cellar, Other
- **Location icons** for visual identification
- **Location-based filtering** in product list
- **Achievement** for organizing products in 5+ locations

### Product Model Changes
```dart
class Product extends Equatable {
  final String? storageLocation;  // NEW FIELD

  // Updated constructor, props, and copyWith
}
```

### Usage in Forms
The enhanced add_product_page includes a storage location picker with icons:
```dart
_storageLocationController.text = 'Refrigerator';
```

### Integration Points
- **Add/Edit Product**: Include storage location picker
- **Product List**: Add filter by location
- **Product Card**: Display location icon
- **Dashboard**: Show products grouped by location
- **Analytics**: Track which location has most waste

---

## 5. Gamification System

### Files Created
- `lib/features/analytics/domain/entities/achievement.dart` (already listed in Analytics)

### Features Implemented

#### Achievement Types
1. **Getting Started** (10 pts): Add first product
2. **Week Warrior** (50 pts): 7-day no-waste streak
3. **Monthly Master** (200 pts): 30-day no-waste streak
4. **Scanner Pro** (75 pts): Scan 50 products
5. **Scanner Expert** (150 pts): Scan 100 products
6. **Inventory Keeper** (100 pts): Track 50 products
7. **Inventory Master** (250 pts): Track 100 products
8. **Zero Waste Warrior** (300 pts): Save 100 products
9. **Early Bird** (150 pts): Use 50 products before expiry
10. **Super Organized** (75 pts): Use 5 different storage locations

#### Points System
- Points awarded when achievements are unlocked
- Total points displayed in analytics page
- Points tracked in UserStats

#### Streak Tracking
- Daily streak for no-waste days
- Longest streak recorded
- Automatic streak reset on waste
- Streak displayed with fire emoji 🔥

### Usage Example
```dart
// Achievements are automatically checked when stats are updated
await analyticsService.incrementProductsAdded();  // May unlock "Getting Started"
await analyticsService.incrementScans();          // May unlock scanner achievements

// Check storage location achievement
await analyticsService.checkStorageLocationAchievement(5);  // 5 unique locations

// Get all achievements
final achievements = await analyticsService.getAchievements();
final unlocked = achievements.where((a) => a.isUnlocked).toList();
```

### Integration Points
- **Analytics Page**: Display achievements with locked/unlocked states
- **Dashboard**: Show recent achievement unlocks
- **Settings**: Display total points earned
- **Product operations**: Automatically trigger achievement checks

---

## Complete Integration Checklist

### 1. Run Flutter Pub Get
```bash
cd shelfguard_app
flutter pub get
```

### 2. Update Main App Initialization
```dart
// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService().initialize();

  // Initialize database
  await DatabaseService.initialize();

  runApp(const MyApp());
}
```

### 3. Update App Router
Add analytics route in `lib/core/routing/app_router.dart`:
```dart
GoRoute(
  path: '/analytics',
  builder: (context, state) => const AnalyticsPage(),
),
```

### 4. Update Dashboard Navigation
Add analytics button to dashboard:
```dart
IconButton(
  icon: const Icon(Icons.analytics),
  onPressed: () => context.push('/analytics'),
)
```

### 5. Replace Add Product Page
Option 1: Replace the original file
```bash
mv lib/features/products/presentation/pages/add_product_page.dart \
   lib/features/products/presentation/pages/add_product_page_old.dart
mv lib/features/products/presentation/pages/add_product_page_enhanced.dart \
   lib/features/products/presentation/pages/add_product_page.dart
```

Option 2: Update imports in router to use enhanced version

### 6. Update Settings Page
Add notification preferences section:
```dart
// Notifications Section
SwitchListTile(
  title: const Text('Enable Notifications'),
  value: _notificationsEnabled,
  onChanged: (value) async {
    await NotificationService().setNotificationsEnabled(value);
    setState(() => _notificationsEnabled = value);
  },
),
```

### 7. Add Waste Tracking Dialog
When deleting an expired product, show dialog:
```dart
Future<void> _showWasteTrackingDialog(Product product) async {
  // Show dialog to collect waste information
  // Create WasteRecord and save via AnalyticsService
}
```

### 8. Update Product List Page
Add storage location filter:
```dart
DropdownButton<String>(
  items: ['All', 'Refrigerator', 'Freezer', 'Pantry', ...],
  onChanged: (location) {
    // Filter products by location
  },
)
```

---

## Testing the Features

### 1. Smart Notifications
- Add a product with expiry date 1 day from now
- Verify notification appears at scheduled time
- Check notification settings in app
- Test disabling specific notification intervals

### 2. Barcode Integration
- Scan a real product barcode (e.g., Coca-Cola: 5449000000996)
- Verify product info auto-populates
- Check category mapping works correctly
- Test with unknown barcode

### 3. Analytics
- Add several products
- Mark some as saved (consumed)
- Delete some as wasted
- View analytics page and verify charts render
- Check streak tracking works

### 4. Storage Locations
- Add products to different locations
- Verify location appears in product card
- Test location filtering
- Check "Super Organized" achievement unlocks

### 5. Gamification
- Complete actions that unlock achievements
- Verify points are awarded
- Check achievement display in analytics
- Test streak calculation

---

## Performance Considerations

### Notifications
- Maximum ~50 scheduled notifications per app (platform limit)
- Cancel old notifications when products are deleted/consumed
- Group notifications to avoid spam

### Analytics
- Store data locally using SharedPreferences
- Consider pagination for large waste record lists
- Cache stats to avoid repeated calculations

### API Calls
- Open Food Facts: Rate limit ~100 requests/minute
- Cache product info locally after first fetch
- Show loading states during API calls

---

## Future Enhancements

### Potential Additions
1. **Cloud Sync**: Backup analytics data to cloud
2. **Social Features**: Compare streaks with friends
3. **Receipt Scanning**: OCR for bulk product entry
4. **Smart Suggestions**: ML-based expiry predictions
5. **Shopping List**: Generate from consumed products
6. **Recipe Integration**: Suggest recipes for expiring items
7. **Export Reports**: PDF/CSV export of analytics
8. **Widgets**: Home screen widgets for urgent products

### Technical Debt
- Implement actual database persistence (currently using SharedPreferences for analytics)
- Add unit tests for services
- Add integration tests for flows
- Implement proper error handling and retry logic
- Add analytics event logging
- Implement backup/restore functionality

---

## Troubleshooting

### Notifications Not Appearing
- Check app has notification permissions
- Verify timezone is initialized
- Check notification settings in device
- Ensure exact alarm permission (Android 12+)

### Barcode API Not Working
- Check internet connection
- Verify API endpoint is accessible
- Check for SSL certificate issues
- Try with known working barcode

### Charts Not Rendering
- Ensure fl_chart package is installed
- Check data format for charts
- Verify chart widget has fixed height
- Check for null/empty data

### Achievements Not Unlocking
- Verify analytics service is initialized
- Check achievement unlock conditions
- Ensure stats are being updated
- Check SharedPreferences data

---

## Support & Documentation

- **Open Food Facts API**: https://openfoodfacts.github.io/openfoodfacts-server/api/
- **fl_chart Package**: https://pub.dev/packages/fl_chart
- **flutter_local_notifications**: https://pub.dev/packages/flutter_local_notifications

---

## Version History

### v2.0.0 (Current)
- Added Smart Notifications
- Added Barcode Database Integration
- Added Analytics & Insights
- Added Storage Location Management
- Added Gamification System

### v1.0.0 (Previous)
- Basic product tracking
- Expiry date management
- Simple dashboard
- Modern UI design

---

## Credits

- **Open Food Facts** for product database
- **fl_chart** for charting library
- **Material Design 3** for UI components
