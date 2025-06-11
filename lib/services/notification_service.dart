import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings);
  }

  static Future<void> checkAndSendNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final lastNotification = prefs.getString('last_notification_date');
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';

    if (lastNotification != todayStr) {
      // Check if user has committed today (simplified check)
      final hasCommitted = await _checkIfCommittedToday();
      
      if (!hasCommitted) {
        await showNotification(
          'GitHub Streak Reminder',
          'Jangan lupa commit hari ini untuk mempertahankan streak! 🔥',
        );
      }
      
      await prefs.setString('last_notification_date', todayStr);
    }
  }

  static Future<bool> _checkIfCommittedToday() async {
    // This would typically check the actual commit status
    // For now, return false to always show notification
    return false;
  }

  static Future<void> showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'streak_channel',
      'Streak Notifications',
      channelDescription: 'Notifications for GitHub commit streaks',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      0,
      title,
      body,
      details,
    );
  }
}