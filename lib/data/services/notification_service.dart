import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turun/app/app_logger.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const _logLabel = LogLabel.general;

  /// Generate opportunity notification for unclaimed territories
  Future<void> generateOpportunityNotifications() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Get all unclaimed territories
      final unclaimedTerritories = await _supabase
          .from('territories')
          .select('id, name, reward_points')
          .isFilter('owner_id', null)
          .limit(5); // Limit to 5 territories

      if (unclaimedTerritories.isEmpty) {
        AppLogger.info(_logLabel, 'No unclaimed territories found');
        return;
      }

      // Check if user already has opportunity notifications for these territories
      final existingNotifications = await _supabase
          .from('notifications')
          .select('territory_id')
          .eq('user_id', userId)
          .eq('type', 'opportunity')
          .eq('is_read', false);

      final existingTerritoryIds = (existingNotifications as List)
          .map((n) => n['territory_id'])
          .toList();

      // Create notifications for new unclaimed territories
      for (var territory in unclaimedTerritories) {
        final territoryId = territory['id'];

        // Skip if already has notification
        if (existingTerritoryIds.contains(territoryId)) continue;

        final territoryName = territory['name'] as String;
        final rewardPoints = territory['reward_points'] as int? ?? 100;

        await _supabase.from('notifications').insert({
          'user_id': userId,
          'title': '🛡️ OPPORTUNITY',
          'message':
              '$territoryName sector is currently unclaimed. Deploy there now for an easy capture!',
          'type': 'opportunity',
          'territory_id': territoryId,
          'territory_name': territoryName,
          'reward_points': rewardPoints,
        });

        AppLogger.success(_logLabel, 'Created opportunity notification for territory: $territoryName');
      }
    } catch (e) {
      AppLogger.error(_logLabel, 'Error generating opportunity notifications', e);
    }
  }

  /// Generate under attack notification
  Future<void> generateUnderAttackNotification({
    required String userId,
    required int territoryId,
    required String territoryName,
    required String attackerUsername,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': '⚠️ UNDER ATTACK',
        'message':
            'Someone is trying to capture $territoryName! Defend your territory before it\'s too late!',
        'type': 'underAttack',
        'territory_id': territoryId,
        'territory_name': territoryName,
        'rival_username': attackerUsername,
      });

      AppLogger.success(_logLabel, 'Created under attack notification for $territoryName');
    } catch (e) {
      AppLogger.error(_logLabel, 'Error creating under attack notification', e);
    }
  }

  /// Generate territory lost notification
  Future<void> generateTerritoryLostNotification({
    required String userId,
    required int territoryId,
    required String territoryName,
    required String newOwnerUsername,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': '❌ TERRITORY LOST',
        'message':
            '$territoryName has fallen to @$newOwnerUsername. Reclaim it now to restore your honor!',
        'type': 'territoryLost',
        'territory_id': territoryId,
        'territory_name': territoryName,
        'rival_username': newOwnerUsername,
      });

      AppLogger.success(_logLabel, 'Created territory lost notification for $territoryName');
    } catch (e) {
      AppLogger.error(_logLabel, 'Error creating territory lost notification', e);
    }
  }

  /// Generate rival activity notification (when someone passes you on leaderboard)
  Future<void> generateRivalActivityNotification({
    required String userId,
    required String rivalUsername,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': '👥 RIVAL ALERT',
        'message':
            '@$rivalUsername just overtook you on the Leaderboard! Don\'t get left behind.',
        'type': 'rivalActivity',
        'rival_username': rivalUsername,
      });

      AppLogger.success(_logLabel, 'Created rival activity notification');
    } catch (e) {
      AppLogger.error(_logLabel, 'Error creating rival activity notification', e);
    }
  }

  /// Generate mission complete notification
  Future<void> generateMissionCompleteNotification({
    required String userId,
    required String missionDescription,
    required int rewardPoints,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': '🏅 MISSION ACCOMPLISHED',
        'message': '$missionDescription. Claim your $rewardPoints pts reward now.',
        'type': 'missionComplete',
        'reward_points': rewardPoints,
      });

      AppLogger.success(_logLabel, 'Created mission complete notification');
    } catch (e) {
      AppLogger.error(_logLabel, 'Error creating mission complete notification', e);
    }
  }

  /// Generate level up notification
  Future<void> generateLevelUpNotification({
    required String userId,
    required int newLevel,
    required String levelName,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': '🆙 PROMOTION',
        'message':
            'Congratulations! You\'ve reached Level $newLevel ($levelName). Check out your new perks.',
        'type': 'levelUp',
        'new_level': newLevel,
      });

      AppLogger.success(_logLabel, 'Created level up notification');
    } catch (e) {
      AppLogger.error(_logLabel, 'Error creating level up notification', e);
    }
  }

  /// Generate inactive reminder notification
  Future<void> generateInactiveReminderNotification({
    required String userId,
    required int daysSinceLastRun,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': '💤 WAKE UP, SOLDIER',
        'message':
            'Your legs are getting rusty. Run for 15 mins today to stay combat-ready!',
        'type': 'inactiveReminder',
      });

      AppLogger.success(_logLabel, 'Created inactive reminder notification');
    } catch (e) {
      AppLogger.error(_logLabel, 'Error creating inactive reminder notification', e);
    }
  }

  /// Generate run completed with territory conquest notification
  /// User successfully claimed the territory with fastest pace
  Future<void> generateRunCompletedWithConquestNotification({
    required String userId,
    required int territoryId,
    required String territoryName,
    required String pace,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': '🏆 TERRITORY CLAIMED!',
        'message':
            'Congratulations! You have successfully conquered $territoryName with a pace of $pace! Keep defending your record!',
        'type': 'runCompletedConquest',
        'territory_id': territoryId,
        'territory_name': territoryName,
      });

      AppLogger.success(_logLabel, 'Created run completed with conquest notification for $territoryName');
    } catch (e) {
      AppLogger.error(_logLabel, 'Error creating run completed with conquest notification', e);
    }
  }

  /// Generate territory created notification (Initial creation of landmark)
  Future<void> generateTerritoryCreatedNotification({
    required String userId,
    required int territoryId,
    required String territoryName,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': '🏗️ TERRITORY CREATED!',
        'message':
            'Congratulations! Your new landmark "$territoryName" has been successfully registered as your Territory!',
        'type': 'territoryCreated',
        'territory_id': territoryId,
        'territory_name': territoryName,
      });

      AppLogger.success(_logLabel, 'Created territory created notification for $territoryName');
    } catch (e) {
      AppLogger.error(_logLabel, 'Error creating territory created notification', e);
    }
  }

  /// Generate run completed without territory conquest notification
  /// User ran in someone else's territory but didn't claim it
  Future<void> generateRunCompletedNoConquestNotification({
    required String userId,
    required int territoryId,
    required String territoryName,
    required String userPace,
    required String targetPace,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': '🏃 RUN COMPLETED!',
        'message':
            'Great job! You finished your run in $territoryName with a pace of $userPace. Beat the $targetPace record to claim this territory!',
        'type': 'runCompletedNoConquest',
        'territory_id': territoryId,
        'territory_name': territoryName,
      });

      AppLogger.success(_logLabel, 'Created run completed no conquest notification for $territoryName');
    } catch (e) {
      AppLogger.error(_logLabel, 'Error creating run completed no conquest notification', e);
    }
  }

  /// Delete old read notifications (cleanup)
  Future<void> cleanupOldNotifications() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Delete read notifications older than 30 days
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      await _supabase
          .from('notifications')
          .delete()
          .eq('user_id', userId)
          .eq('is_read', true)
          .lt('created_at', thirtyDaysAgo.toIso8601String());

      AppLogger.info(_logLabel, 'Cleaned up old notifications');
    } catch (e) {
      AppLogger.error(_logLabel, 'Error cleaning up notifications', e);
    }
  }
}
