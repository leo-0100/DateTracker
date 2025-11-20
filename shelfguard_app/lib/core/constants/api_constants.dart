class ApiConstants {
  // Base URL - Update this with your actual backend URL
  static const String baseUrl = 'http://localhost:3000/api/v1';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // Shop endpoints
  static const String shops = '/shops';
  static const String shopSettings = '/shops/settings';
  static const String customFields = '/shops/custom-fields';

  // Product endpoints
  static const String products = '/products';
  static const String searchProducts = '/products/search';
  static const String bulkImport = '/products/bulk-import';
  static const String exportProducts = '/products/export';

  // Notification endpoints
  static const String notifications = '/notifications';
  static const String notificationSettings = '/notifications/settings';

  // Timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
}
