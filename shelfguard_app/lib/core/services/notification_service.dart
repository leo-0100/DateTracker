import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Notification preference keys
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyNotifyOneDayBefore = 'notify_one_day_before';
  static const String _keyNotifyThreeDaysBefore = 'notify_three_days_before';
  static const String _keyNotifySevenDaysBefore = 'notify_seven_days_before';
  static const String _keyNotifyOnExpiry = 'notify_on_expiry';

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to specific product
    // For now, just log it
    print('Notification tapped: ${response.payload}');
  }

  Future<bool> requestPermissions() async {
    if (await Permission.notification.isGranted) {
      return true;
    }

    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // Notification preferences getters
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationsEnabled) ?? true;
  }

  Future<bool> isOneDayNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifyOneDayBefore) ?? true;
  }

  Future<bool> isThreeDaysNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifyThreeDaysBefore) ?? true;
  }

  Future<bool> isSevenDaysNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifySevenDaysBefore) ?? true;
  }

  Future<bool> isExpiryNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifyOnExpiry) ?? true;
  }

  // Notification preferences setters
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, enabled);

    if (!enabled) {
      await cancelAllNotifications();
    }
  }

  Future<void> setOneDayNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifyOneDayBefore, enabled);
  }

  Future<void> setThreeDaysNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifyThreeDaysBefore, enabled);
  }

  Future<void> setSevenDaysNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifySevenDaysBefore, enabled);
  }

  Future<void> setExpiryNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifyOnExpiry, enabled);
  }

  Future<void> scheduleProductExpiryNotifications({
    required String productId,
    required String productName,
    required DateTime expiryDate,
  }) async {
    if (!await areNotificationsEnabled()) return;

    final now = DateTime.now();

    // Cancel existing notifications for this product
    await cancelProductNotifications(productId);

    // Schedule 7 days before
    if (await isSevenDaysNotificationEnabled()) {
      final sevenDaysBefore = expiryDate.subtract(const Duration(days: 7));
      if (sevenDaysBefore.isAfter(now)) {
        await _scheduleNotification(
          id: _getNotificationId(productId, 7),
          title: 'Product Expiring Soon',
          body: '$productName will expire in 7 days',
          scheduledDate: sevenDaysBefore,
          payload: productId,
        );
      }
    }

    // Schedule 3 days before
    if (await isThreeDaysNotificationEnabled()) {
      final threeDaysBefore = expiryDate.subtract(const Duration(days: 3));
      if (threeDaysBefore.isAfter(now)) {
        await _scheduleNotification(
          id: _getNotificationId(productId, 3),
          title: 'Product Expiring Soon! ⚠️',
          body: '$productName will expire in 3 days',
          scheduledDate: threeDaysBefore,
          payload: productId,
        );
      }
    }

    // Schedule 1 day before
    if (await isOneDayNotificationEnabled()) {
      final oneDayBefore = expiryDate.subtract(const Duration(days: 1));
      if (oneDayBefore.isAfter(now)) {
        await _scheduleNotification(
          id: _getNotificationId(productId, 1),
          title: 'Product Expiring Tomorrow! 🚨',
          body: '$productName will expire tomorrow',
          scheduledDate: oneDayBefore,
          payload: productId,
        );
      }
    }

    // Schedule on expiry day
    if (await isExpiryNotificationEnabled()) {
      if (expiryDate.isAfter(now)) {
        await _scheduleNotification(
          id: _getNotificationId(productId, 0),
          title: 'Product Expired! ❌',
          body: '$productName has expired today',
          scheduledDate: expiryDate,
          payload: productId,
        );
      }
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'expiry_notifications',
      'Expiry Notifications',
      channelDescription: 'Notifications for product expiry dates',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!await areNotificationsEnabled()) return;

    const androidDetails = AndroidNotificationDetails(
      'instant_notifications',
      'Instant Notifications',
      channelDescription: 'Immediate notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> scheduleDailySummary() async {
    if (!await areNotificationsEnabled()) return;

    // Schedule daily summary at 9 AM
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 9, 0);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_summary',
      'Daily Summary',
      channelDescription: 'Daily product expiry summary',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      999999, // Special ID for daily summary
      'ShelfGuard Daily Summary',
      'Check your expiring products today',
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  int _getNotificationId(String productId, int daysBefore) {
    // Create a unique notification ID from product ID and days before
    // Use hash code to convert string to int, then combine with daysBefore
    final hashCode = productId.hashCode.abs();
    // Use different ranges for different notification types to avoid collisions
    return (hashCode % 100000) * 10 + daysBefore;
  }

  Future<void> cancelProductNotifications(String productId) async {
    // Cancel all notifications for a specific product
    await _notifications.cancel(_getNotificationId(productId, 0));
    await _notifications.cancel(_getNotificationId(productId, 1));
    await _notifications.cancel(_getNotificationId(productId, 3));
    await _notifications.cancel(_getNotificationId(productId, 7));
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
