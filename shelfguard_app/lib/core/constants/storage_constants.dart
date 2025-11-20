class StorageConstants {
  // Hive box names
  static const String authBox = 'auth_box';
  static const String productsBox = 'products_box';
  static const String settingsBox = 'settings_box';
  static const String syncQueueBox = 'sync_queue_box';

  // SharedPreferences keys
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String shopId = 'shop_id';
  static const String isLoggedIn = 'is_logged_in';
  static const String lastSyncTime = 'last_sync_time';

  // Notification preferences
  static const String notificationsEnabled = 'notifications_enabled';
  static const String notificationDays = 'notification_days'; // JSON array: [7, 3, 0]
  static const String notificationTime = 'notification_time'; // Format: "HH:mm"
}
