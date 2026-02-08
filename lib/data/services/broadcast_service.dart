import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turun/app/app_logger.dart';
import 'package:turun/data/model/broadcast/broadcast_model.dart';

/// Service for fetching and managing broadcast announcements
class BroadcastService {
  static final BroadcastService _instance = BroadcastService._internal();
  factory BroadcastService() => _instance;
  BroadcastService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  static const _logLabel = LogLabel.general;

  /// Fetch active broadcasts for the current user
  /// Returns broadcasts that are:
  /// - Active (is_active = true)
  /// - Started (start_date <= now)
  /// - Not expired (end_date is null or end_date > now)
  /// - Not dismissed by the user
  Future<List<BroadcastModel>> fetchActiveBroadcasts() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning(_logLabel, 'Cannot fetch broadcasts: User not authenticated');
        return [];
      }

      // Fetch broadcasts with RLS applied
      final response = await _supabase
          .from('broadcasts')
          .select()
          .eq('is_active', true)
          .lte('start_date', DateTime.now().toIso8601String())
          .order('priority', ascending: false)
          .order('created_at', ascending: false);

      final broadcasts = (response as List)
          .map((json) => BroadcastModel.fromJson(json))
          .where((b) => b.isScheduledToShow)
          .toList();

      // Fetch user interactions to filter out dismissed broadcasts
      final interactions = await _supabase
          .from('broadcast_user_interactions')
          .select()
          .eq('user_id', userId)
          .not('dismissed_at', 'is', null);

      final dismissedIds = (interactions as List)
          .map((i) => i['broadcast_id'] as String)
          .toSet();

      // Filter out dismissed broadcasts
      final activeBroadcasts = broadcasts
          .where((b) => !dismissedIds.contains(b.id))
          .toList();

      AppLogger.success(_logLabel, 'Fetched ${activeBroadcasts.length} active broadcasts');
      return activeBroadcasts;
    } catch (e, stackTrace) {
      AppLogger.error(_logLabel, 'Failed to fetch broadcasts', e, stackTrace);
      return [];
    }
  }

  /// Record that the user has viewed a broadcast
  Future<void> recordView(String broadcastId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.rpc('increment_broadcast_view', params: {
        'broadcast_uuid': broadcastId,
        'user_uuid': userId,
      });

      AppLogger.info(_logLabel, 'Recorded view for broadcast: $broadcastId');
    } catch (e, stackTrace) {
      AppLogger.error(_logLabel, 'Failed to record broadcast view', e, stackTrace);
    }
  }

  /// Record that the user clicked on the broadcast action
  Future<void> recordClick(String broadcastId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.rpc('record_broadcast_click', params: {
        'broadcast_uuid': broadcastId,
        'user_uuid': userId,
      });

      AppLogger.info(_logLabel, 'Recorded click for broadcast: $broadcastId');
    } catch (e, stackTrace) {
      AppLogger.error(_logLabel, 'Failed to record broadcast click', e, stackTrace);
    }
  }

  /// Record that the user dismissed a broadcast
  Future<void> recordDismiss(String broadcastId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.rpc('record_broadcast_dismiss', params: {
        'broadcast_uuid': broadcastId,
        'user_uuid': userId,
      });

      AppLogger.info(_logLabel, 'Recorded dismiss for broadcast: $broadcastId');
    } catch (e, stackTrace) {
      AppLogger.error(_logLabel, 'Failed to record broadcast dismiss', e, stackTrace);
    }
  }

  /// Get a single broadcast by ID
  Future<BroadcastModel?> getBroadcast(String id) async {
    try {
      final response = await _supabase
          .from('broadcasts')
          .select()
          .eq('id', id)
          .single();

      return BroadcastModel.fromJson(response);
    } catch (e, stackTrace) {
      AppLogger.error(_logLabel, 'Failed to get broadcast', e, stackTrace);
      return null;
    }
  }
}
