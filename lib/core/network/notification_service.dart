import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  final FirebaseMessaging _fcm;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  NotificationService(this._fcm);

  /// Completely non-blocking and error-immune initialization
  /// ⚠️ Web-compatible: Skips notification setup entirely on Web platform
  Future<void> initialize() async {
    try {
      // 🚫 CRITICAL WEB FIX: Skip notifications entirely on Web
      if (kIsWeb) {
        debugPrint('⚠️ [NOTIFICATION] Skipped on Web platform (prevents MIME/SW errors)');
        return;
      }

      debugPrint('🚀 [NOTIFICATION] Starting silent initialization...');

      // 1. Initialize Local Notifications for foreground (Mobile Only)
      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      await _localNotifications.initialize(settings: initializationSettings);

      // 2. Request permissions with a strict timeout (Mobile only)
      try {
        await _fcm.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        ).timeout(const Duration(seconds: 3));
        debugPrint('✅ [NOTIFICATION] Permission request processed');
      } catch (e) {
        debugPrint('⚠️ [NOTIFICATION] Permission request skipped/failed: $e');
      }

      // 3. Token Fetching (Mobile only - Web already returned above)
      try {
        String? token = await _fcm.getToken().timeout(const Duration(seconds: 3));
        if (token != null) debugPrint('✅ [NOTIFICATION] Token Acquired: ${token.substring(0, 20)}...');
      } catch (e) {
        debugPrint('⚠️ [NOTIFICATION] Token fetch failed: $e');
      }

      // 4. Setup Listeners
      FirebaseMessaging.onMessage.listen((message) {
        debugPrint('📩 [NOTIFICATION] Foreground message received');
        _showLocalNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        debugPrint('App opened via notification: ${message.data}');
      });

    } catch (e) {
      debugPrint('⚠️ [NOTIFICATION] Global service initialization bypassed: $e');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'ecoshop_channel',
      'EcoShop Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const details = NotificationDetails(android: androidDetails);
    
    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
    );
  }

  Future<String?> getToken() async {
    try {
      return await _fcm.getToken().timeout(const Duration(seconds: 1));
    } catch (e) {
      return null;
    }
  }
}
