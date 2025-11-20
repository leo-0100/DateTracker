class AppConstants {
  // App info
  static const String appName = 'ShelfGuard';
  static const String appVersion = '1.0.0';

  // Default notification thresholds (days before expiry)
  static const List<int> defaultNotificationDays = [7, 3, 0];

  // Expiry categories
  static const int criticalExpiryDays = 3;
  static const int warningExpiryDays = 7;

  // Pagination
  static const int productsPerPage = 20;

  // Barcode types supported
  static const List<String> supportedBarcodeTypes = [
    'EAN_8',
    'EAN_13',
    'UPC_A',
    'UPC_E',
    'CODE_128',
    'QR_CODE',
  ];

  // Custom field types
  static const String fieldTypeText = 'text';
  static const String fieldTypeNumber = 'number';
  static const String fieldTypeDate = 'date';
  static const String fieldTypeBoolean = 'boolean';
  static const String fieldTypeSelect = 'select';

  // Product statuses
  static const String statusActive = 'active';
  static const String statusDisposed = 'disposed';
  static const String statusSold = 'sold';
  static const String statusExpired = 'expired';

  // Date formats
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
}
