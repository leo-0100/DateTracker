import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../../features/products/domain/entities/product.dart';

/// Notification service for expiry alerts
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone database
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for iOS
    await _requestPermissions();

    _initialized = true;
    print('[Notifications] Service initialized');
  }

  /// Request notification permissions
  Future<bool> _requestPermissions() async {
    final androidPermission = await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    final iosPermission = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    return (androidPermission ?? true) && (iosPermission ?? true);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('[Notifications] Notification tapped: ${response.payload}');
    // TODO: Navigate to product detail page
  }

  /// Schedule notification for product expiry
  Future<void> scheduleExpiryNotification({
    required Product product,
    required int daysBeforeExpiry,
  }) async {
    if (!_initialized) await initialize();

    final expiryDate = product.expiryDate;
    final notificationDate = expiryDate.subtract(Duration(days: daysBeforeExpiry));

    // Don't schedule if date is in the past
    if (notificationDate.isBefore(DateTime.now())) {
      return;
    }

    final scheduledDate = tz.TZDateTime.from(
      notificationDate.copyWith(hour: 9, minute: 0, second: 0),
      tz.local,
    );

    final notificationId = product.id.hashCode + daysBeforeExpiry;

    await _notifications.zonedSchedule(
      notificationId,
      _getNotificationTitle(daysBeforeExpiry),
      _getNotificationBody(product, daysBeforeExpiry),
      scheduledDate,
      _getNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: product.id,
    );

    print(
        '[Notifications] Scheduled for ${product.name} on ${scheduledDate.toString()}');
  }

  /// Schedule multiple notifications for a product (3 days, 1 day, expiry day)
  Future<void> scheduleAllNotificationsForProduct(Product product) async {
    final daysUntilExpiry = product.daysToExpiry;

    // Schedule 3 days before
    if (daysUntilExpiry >= 3) {
      await scheduleExpiryNotification(product: product, daysBeforeExpiry: 3);
    }

    // Schedule 1 day before
    if (daysUntilExpiry >= 1) {
      await scheduleExpiryNotification(product: product, daysBeforeExpiry: 1);
    }

    // Schedule on expiry day
    if (daysUntilExpiry >= 0) {
      await scheduleExpiryNotification(product: product, daysBeforeExpiry: 0);
    }
  }

  /// Cancel all notifications for a product
  Future<void> cancelNotificationsForProduct(String productId) async {
    final baseId = productId.hashCode;
    await _notifications.cancel(baseId + 3); // 3 days before
    await _notifications.cancel(baseId + 1); // 1 day before
    await _notifications.cancel(baseId + 0); // expiry day
    print('[Notifications] Cancelled notifications for product $productId');
  }

  /// Send immediate notification
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      _getNotificationDetails(),
      payload: payload,
    );
  }

  /// Schedule daily summary notification
  Future<void> scheduleDailySummary() async {
    if (!_initialized) await initialize();

    // Schedule for 9 AM every day
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 9, 0);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notifications.zonedSchedule(
      0, // Daily summary ID
      '📦 Daily Product Summary',
      'Tap to see products expiring soon',
      tzScheduledDate,
      _getNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );

    print('[Notifications] Daily summary scheduled for 9 AM');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('[Notifications] All notifications cancelled');
  }

  /// Get notification details (style, sound, etc.)
  NotificationDetails _getNotificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      'expiry_alerts',
      'Expiry Alerts',
      channelDescription: 'Notifications for products about to expire',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  /// Get notification title based on days
  String _getNotificationTitle(int daysBeforeExpiry) {
    if (daysBeforeExpiry == 0) {
      return '⚠️ Product Expires Today!';
    } else if (daysBeforeExpiry == 1) {
      return '⏰ Product Expires Tomorrow';
    } else {
      return '📅 Product Expiring Soon';
    }
  }

  /// Get notification body
  String _getNotificationBody(Product product, int daysBeforeExpiry) {
    if (daysBeforeExpiry == 0) {
      return '${product.name} expires today. Use it or lose it!';
    } else if (daysBeforeExpiry == 1) {
      return '${product.name} expires tomorrow. Plan to use it!';
    } else {
      return '${product.name} expires in $daysBeforeExpiry days';
    }
  }

  /// Check pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
