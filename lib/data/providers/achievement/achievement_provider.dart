import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../model/achievement/achievement_model.dart';

class AchievementProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<UserAchievement> _userAchievements = [];
  bool _isLoading = false;
  String? _error;

  List<UserAchievement> get userAchievements => _userAchievements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get unlocked achievements
  List<UserAchievement> get unlockedAchievements =>
      _userAchievements.where((ua) => ua.isUnlocked).toList();

  // Get locked achievements
  List<UserAchievement> get lockedAchievements =>
      _userAchievements.where((ua) => !ua.isUnlocked).toList();

  // Get total points
  int get totalPoints {
    return unlockedAchievements.fold(0, (sum, ua) {
      final achievement = ua.achievement;
      return sum + (achievement?.points ?? 0);
    });
  }

  // Get achievements by type
  List<UserAchievement> getAchievementsByType(AchievementType type) {
    return _userAchievements
        .where((ua) => ua.achievement?.type == type)
        .toList();
  }

  // Load user achievements
  Future<void> loadUserAchievements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Calculate current stats
      final stats = await _calculateUserStats(userId);

      // Initialize achievements with progress
      _userAchievements = Achievement.all.map((achievement) {
        final currentProgress = _getProgressForAchievement(achievement, stats);
        final isUnlocked = currentProgress >= achievement.targetValue;

        return UserAchievement(
          userId: userId,
          achievementId: achievement.id,
          currentProgress: currentProgress,
          isUnlocked: isUnlocked,
          unlockedAt: isUnlocked ? DateTime.now() : null,
        );
      }).toList();

      // Sort: unlocked first, then by tier
      _userAchievements.sort((a, b) {
        if (a.isUnlocked != b.isUnlocked) {
          return a.isUnlocked ? -1 : 1;
        }
        return (a.achievement?.tier.index ?? 0)
            .compareTo(b.achievement?.tier.index ?? 0);
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate user stats from database
  Future<Map<String, double>> _calculateUserStats(String userId) async {
    // Get all completed runs
    final runsResponse = await _supabase
        .from('run_sessions')
        .select()
        .eq('user_id', userId)
        .eq('status', 'completed')
        .order('created_at', ascending: false);

    final runs = runsResponse as List;

    // Calculate total distance
    double totalDistance = 0.0;
    for (var run in runs) {
      totalDistance += (run['distance_meters'] as num?)?.toDouble() ?? 0.0;
    }
    totalDistance = totalDistance / 1000; // Convert to km

    // Calculate total runs
    final totalRuns = runs.length.toDouble();

    // Calculate current streak
    final streak = _calculateStreak(runs);

    // Get territory conquests count
    final territoriesResponse = await _supabase
        .from('run_sessions')
        .select('territory_id')
        .eq('user_id', userId)
        .eq('territory_conquered', true);

    final territories = territoriesResponse as List;
    final uniqueTerritories = territories
        .map((t) => t['territory_id'])
        .toSet()
        .length
        .toDouble();

    // Get landmarks discovered (assuming there's a landmarks_discovered table)
    double landmarksDiscovered = 0.0;
    try {
      final landmarksResponse = await _supabase
          .from('user_landmarks')
          .select()
          .eq('user_id', userId);
      landmarksDiscovered = (landmarksResponse as List).length.toDouble();
    } catch (e) {
      // Table might not exist yet
      landmarksDiscovered = 0.0;
    }

    return {
      'totalDistance': totalDistance,
      'totalRuns': totalRuns,
      'currentStreak': streak.toDouble(),
      'territoriesConquered': uniqueTerritories,
      'landmarksDiscovered': landmarksDiscovered,
    };
  }

  // Calculate streak
  int _calculateStreak(List<dynamic> runs) {
    if (runs.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();
    currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day);

    for (int i = 0; i < runs.length; i++) {
      final runDate = DateTime.parse(runs[i]['start_time'] as String);
      final normalizedRunDate = DateTime(runDate.year, runDate.month, runDate.day);

      final difference = currentDate.difference(normalizedRunDate).inDays;

      if (difference == streak) {
        streak++;
      } else if (difference > streak) {
        break;
      }
    }

    return streak;
  }

  // Get progress value for specific achievement
  double _getProgressForAchievement(
      Achievement achievement, Map<String, double> stats) {
    switch (achievement.type) {
      case AchievementType.distance:
        return stats['totalDistance'] ?? 0.0;
      case AchievementType.streak:
        return stats['currentStreak'] ?? 0.0;
      case AchievementType.runs:
        return stats['totalRuns'] ?? 0.0;
      case AchievementType.territory:
        return stats['territoriesConquered'] ?? 0.0;
      case AchievementType.landmark:
        return stats['landmarksDiscovered'] ?? 0.0;
      case AchievementType.special:
        return 0.0;
    }
  }

  // Get recently unlocked achievements (last 5)
  List<UserAchievement> getRecentlyUnlocked({int limit = 5}) {
    final unlocked = unlockedAchievements;
    unlocked.sort((a, b) {
      if (a.unlockedAt == null || b.unlockedAt == null) return 0;
      return b.unlockedAt!.compareTo(a.unlockedAt!);
    });
    return unlocked.take(limit).toList();
  }

  // Get next achievements to unlock (closest to completion)
  List<UserAchievement> getNextToUnlock({int limit = 5}) {
    final locked = lockedAchievements;
    locked.sort((a, b) => b.progress.compareTo(a.progress));
    return locked.take(limit).toList();
  }
}
