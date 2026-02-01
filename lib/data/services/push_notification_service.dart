import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turun/app/app_logger.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  AppLogger.info(LogLabel.general, 'Handling background message: ${message.messageId}');
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final SupabaseClient _supabase = Supabase.instance.client;
  
  static const _logLabel = LogLabel.general;

  /// Initialize push notification service
  Future<void> initialize() async {
    try {
      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Request permission
      await _requestPermission();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get and save FCM token
      await _getAndSaveToken();

      // Listen for token refresh
      _messaging.onTokenRefresh.listen(_saveTokenToSupabase);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps when app is in background/terminated
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check if app was opened from notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      AppLogger.success(_logLabel, 'Push notification service initialized');
    } catch (e, stackTrace) {
      AppLogger.error(_logLabel, 'Failed to initialize push notifications', e, stackTrace);
    }
  }

  /// Request notification permission
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    AppLogger.info(_logLabel, 'Notification permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      AppLogger.success(_logLabel, 'User granted notification permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      AppLogger.info(_logLabel, 'User granted provisional notification permission');
    } else {
      AppLogger.warning(_logLabel, 'User declined notification permission');
    }
  }

  /// Initialize local notifications for foreground display
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'turun_notifications',
        'TuRun Notifications',
        description: 'Notifications for territory attacks, achievements, and more',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Create run completed channel with sound
      const runCompletedChannel = AndroidNotificationChannel(
        'turun_run_completed',
        'Run Completed',
        description: 'Notifications when you complete a run',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(runCompletedChannel);
    }
  }

  /// Get FCM token and save to Supabase
  Future<void> _getAndSaveToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenToSupabase(token);
        AppLogger.info(_logLabel, 'FCM Token obtained: ${token.substring(0, 20)}...');
      }
    } catch (e) {
      AppLogger.error(_logLabel, 'Failed to get FCM token', e);
    }
  }

  /// Save FCM token to user's profile in Supabase
  Future<void> _saveTokenToSupabase(String token) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning(_logLabel, 'Cannot save FCM token: User not authenticated');
        return;
      }

      await _supabase
          .from('users')
          .update({'fcm_token': token})
          .eq('id', userId);

      AppLogger.success(_logLabel, 'FCM token saved to Supabase');
    } catch (e) {
      AppLogger.error(_logLabel, 'Failed to save FCM token', e);
    }
  }

  /// Handle foreground messages by showing local notification
  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.info(_logLabel, 'Received foreground message: ${message.notification?.title}');

    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'turun_notifications',
            'TuRun Notifications',
            channelDescription: 'Notifications for territory attacks, achievements, and more',
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@drawable/ic_notification',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Handle notification tap when app is in background/terminated
  void _handleNotificationTap(RemoteMessage message) {
    AppLogger.info(_logLabel, 'Notification tapped: ${message.data}');
    
    // For example: if message.data['type'] == 'underAttack', navigate to territory
  }

  /// Handle local notification tap
  void _onNotificationTap(NotificationResponse response) {
    AppLogger.info(_logLabel, 'Local notification tapped: ${response.payload}');
    if (response.payload != null) {
      // ignore: unused_local_variable
      final data = jsonDecode(response.payload!);
    }
  }

  /// Show local notification (can be called from NotificationProvider)
  Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'turun_notifications',
          'TuRun Notifications',
          channelDescription: 'Notifications for territory attacks, achievements, and more',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: data != null ? jsonEncode(data) : null,
    );
  }

  /// Show run completed notification with sound
  /// Used when user finishes a run to notify them of the result
  Future<void> showRunCompletedNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'turun_run_completed',
          'Run Completed',
          channelDescription: 'Notifications when you complete a run',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: data != null ? jsonEncode(data) : null,
    );

    AppLogger.info(_logLabel, 'Run completed notification shown: $title');
  }

  /// Delete FCM token (call on logout)
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      AppLogger.info(_logLabel, 'FCM token deleted');
    } catch (e) {
      AppLogger.error(_logLabel, 'Failed to delete FCM token', e);
    }
  }
}
