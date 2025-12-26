import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turun/app/app_logger.dart';
import 'package:turun/app/finite_state.dart';
import 'package:turun/data/model/notification/notification_model.dart';
import 'package:turun/data/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final NotificationService _notificationService = NotificationService();
  static const _logLabel = LogLabel.provider;

  List<NotificationModel> _notifications = [];
  MyState _state = MyState.initial;
  String? _errorMessage;

  List<NotificationModel> get notifications => _notifications;
  MyState get state => _state;
  String? get errorMessage => _errorMessage;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Filter notifications by type
  List<NotificationModel> getNotificationsByType(NotificationType? type) {
    if (type == null) return _notifications;
    return _notifications.where((n) => n.type == type).toList();
  }

  // Fetch notifications for current user
  Future<void> fetchNotifications({bool generateOpportunities = true}) async {
    try {
      _state = MyState.loading;
      notifyListeners();

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Generate opportunity notifications for unclaimed territories
      if (generateOpportunities) {
        await _notificationService.generateOpportunityNotifications();
      }

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      AppLogger.info(_logLabel, 'Fetched ${(response as List).length} notifications from Supabase');

      _notifications = (response as List)
          .map((json) {
            try {
              return NotificationModel.fromJson(json);
            } catch (e) {
              AppLogger.error(_logLabel, 'Error parsing notification', e);
              AppLogger.debug(_logLabel, 'JSON: $json');
              rethrow;
            }
          })
          .toList();

      AppLogger.success(_logLabel, 'Successfully parsed ${_notifications.length} notifications');

      _state = MyState.loaded;
      _errorMessage = null;
    } catch (e, stackTrace) {
      AppLogger.error(_logLabel, 'Error fetching notifications', e, stackTrace);
      _state = MyState.failed;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Mark single notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);

      // Update local state
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId);

      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Delete all read notifications
  Future<void> clearReadNotifications() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('notifications')
          .delete()
          .eq('user_id', userId)
          .eq('is_read', true);

      _notifications.removeWhere((n) => n.isRead);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Listen to real-time notifications
  void subscribeToNotifications() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _supabase
        .channel('notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final newNotification = NotificationModel.fromJson(payload.newRecord);

            // Check if notification already exists to prevent duplicates
            final exists = _notifications.any((n) => n.id == newNotification.id);
            if (!exists) {
              _notifications.insert(0, newNotification);
              notifyListeners();
              AppLogger.info(_logLabel, 'Added new real-time notification: ${newNotification.title}');
            } else {
              AppLogger.debug(_logLabel, 'Skipped duplicate notification: ${newNotification.id}');
            }
          },
        )
        .subscribe();
  }

  // Unsubscribe from real-time updates
  void unsubscribeFromNotifications() {
    _supabase.removeChannel(_supabase.channel('notifications'));
  }

  @override
  void dispose() {
    unsubscribeFromNotifications();
    super.dispose();
  }
}
