import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:turun/app/app_logger.dart';

/// Service for showing persistent navigation notification during runs
/// Similar to Google Maps navigation notification
class NavigationNotificationService {
  static final NavigationNotificationService _instance = NavigationNotificationService._internal();
  factory NavigationNotificationService() => _instance;
  NavigationNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  static const String _channelId = 'turun_navigation';
  static const String _channelName = 'Navigation';
  static const String _channelDescription = 'Real-time navigation updates during your run';
  static const int _notificationId = 888; // Fixed ID for persistent notification
  
  bool _isInitialized = false;
  bool _isShowingNavigation = false;

  /// Initialize the navigation notification channel
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      if (Platform.isAndroid) {
        // Create a low-profile navigation channel (ongoing, silent updates)
        const channel = AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.low, // Low to avoid sound on every update
          playSound: false,
          enableVibration: false,
          showBadge: false,
        );

        await _localNotifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);
      }
      
      _isInitialized = true;
      AppLogger.success(LogLabel.general, '🗺️ Navigation notification service initialized');
    } catch (e, stackTrace) {
      AppLogger.error(LogLabel.general, 'Failed to initialize navigation notification', e, stackTrace);
    }
  }

  /// Start showing navigation notification
  Future<void> startNavigation({
    required String territoryName,
    required int totalCheckpoints,
  }) async {
    await initialize();
    _isShowingNavigation = true;
    
    await _updateNotification(
      title: '🏃 Running: $territoryName',
      body: 'Starting run... 0/$totalCheckpoints checkpoints',
      progress: 0,
      maxProgress: totalCheckpoints,
    );
    
    AppLogger.info(LogLabel.general, '🗺️ Navigation notification started for $territoryName');
  }

  /// Update navigation notification with current progress
  Future<void> updateProgress({
    required String territoryName,
    required int currentCheckpoint,
    required int totalCheckpoints,
    required double distanceKm,
    required int elapsedSeconds,
    required double paceMinPerKm,
    String? nextDirection,
  }) async {
    if (!_isShowingNavigation) return;
    
    // Format elapsed time
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    // Format pace
    final paceMin = paceMinPerKm.floor();
    final paceSec = ((paceMinPerKm - paceMin) * 60).round();
    final paceStr = paceMinPerKm > 0 && paceMinPerKm < 99 
        ? "$paceMin'${paceSec.toString().padLeft(2, '0')}\"/km"
        : "--'--\"/km";
    
    // Build body text similar to Google Maps
    final bodyLines = <String>[];
    
    // Main stats line
    bodyLines.add('📍 ${distanceKm.toStringAsFixed(2)} km · ⏱️ $timeStr · $paceStr');
    
    // Checkpoint progress
    bodyLines.add('🪙 $currentCheckpoint/$totalCheckpoints checkpoints');
    
    // Next direction if available
    if (nextDirection != null && nextDirection.isNotEmpty) {
      bodyLines.add('➡️ $nextDirection');
    }
    
    await _updateNotification(
      title: '🏃 $territoryName',
      body: bodyLines.join('\n'),
      progress: currentCheckpoint,
      maxProgress: totalCheckpoints,
    );
  }

  /// Update notification with finish status
  Future<void> showFinishing({
    required String territoryName,
    required double distanceKm,
    required int elapsedSeconds,
  }) async {
    if (!_isShowingNavigation) return;
    
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    await _updateNotification(
      title: '🏁 Almost there!',
      body: 'Head to finish line!\n📍 ${distanceKm.toStringAsFixed(2)} km · ⏱️ $timeStr',
      progress: 100,
      maxProgress: 100,
      isIndeterminate: true,
    );
  }

  /// Stop navigation notification
  Future<void> stopNavigation() async {
    _isShowingNavigation = false;
    await _localNotifications.cancel(_notificationId);
    AppLogger.info(LogLabel.general, '🗺️ Navigation notification stopped');
  }

  /// Internal method to update/show notification
  Future<void> _updateNotification({
    required String title,
    required String body,
    int progress = 0,
    int maxProgress = 100,
    bool isIndeterminate = false,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true, // Can't be swiped away
        autoCancel: false,
        playSound: false,
        enableVibration: false,
        showProgress: true,
        maxProgress: maxProgress,
        progress: progress,
        indeterminate: isIndeterminate,
        icon: '@drawable/ic_notification',
        // Using BigTextStyle for multi-line support
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
        ),
        // Action buttons
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction(
            'stop_run',
            '⏹️ Stop',
            showsUserInterface: true,
            cancelNotification: false,
          ),
        ],
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: false, // Don't show popup on every update
        presentBadge: false,
        presentSound: false,
      );

      await _localNotifications.show(
        _notificationId,
        title,
        body,
        NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        ),
      );
    } catch (e) {
      AppLogger.warning(LogLabel.general, 'Failed to update navigation notification: $e');
    }
  }
  
  /// Check if navigation notification is currently showing
  bool get isShowingNavigation => _isShowingNavigation;
}
