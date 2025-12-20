import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/territory/territory_model.dart';
import '../model/running/run_session_model.dart';

class TerritoryLeaderboardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all territories with owner information
  Future<List<Territory>> getAllTerritories() async {
    try {
      final response = await _supabase
          .from('territories')
          .select()
          .order('name', ascending: true);

      return (response as List)
          .map((territory) => Territory.fromJson(territory))
          .toList();
    } catch (e) {
      print('Error fetching territories: $e');
      rethrow;
    }
  }

  /// Search territories by name
  Future<List<Territory>> searchTerritories(String query) async {
    try {
      if (query.isEmpty) {
        return getAllTerritories();
      }

      final response = await _supabase
          .from('territories')
          .select()
          .ilike('name', '%$query%')
          .order('name', ascending: true);

      return (response as List)
          .map((territory) => Territory.fromJson(territory))
          .toList();
    } catch (e) {
      print('Error searching territories: $e');
      rethrow;
    }
  }

  /// Get leaderboard for a specific territory
  /// Returns top runs sorted by best average pace (fastest first)
  /// Only shows best run per user (no duplicates)
  Future<List<RunSession>> getTerritoryLeaderboard({
    required int territoryId,
    int limit = 50,
  }) async {
    try {
      // Fetch run sessions - get more than limit to filter later
      final runResponse = await _supabase
          .from('run_sessions')
          .select()
          .eq('territory_id', territoryId)
          .eq('status', 'completed')
          .gt('average_pace_min_per_km', 0) // Filter out pace = 0
          .order('average_pace_min_per_km', ascending: true)
          .limit(100); // Fetch more to ensure we have enough unique users

      final runs = runResponse as List;
      if (runs.isEmpty) return [];

      // Group by user_id and keep only the best (fastest pace) run per user
      final Map<String, Map<String, dynamic>> bestRunPerUser = {};

      for (final run in runs) {
        final userId = run['user_id'] as String;
        final pace = (run['average_pace_min_per_km'] as num?)?.toDouble() ?? 0;

        // Skip if pace is invalid
        if (pace <= 0 || pace.isInfinite || pace.isNaN) continue;

        // Keep only the best run for each user
        if (!bestRunPerUser.containsKey(userId)) {
          bestRunPerUser[userId] = run;
        } else {
          final currentBestPace = (bestRunPerUser[userId]!['average_pace_min_per_km'] as num?)?.toDouble() ?? double.infinity;
          if (pace < currentBestPace) {
            bestRunPerUser[userId] = run;
          }
        }
      }

      // Convert to list and sort by pace
      final uniqueRuns = bestRunPerUser.values.toList()
        ..sort((a, b) {
          final paceA = (a['average_pace_min_per_km'] as num?)?.toDouble() ?? double.infinity;
          final paceB = (b['average_pace_min_per_km'] as num?)?.toDouble() ?? double.infinity;
          return paceA.compareTo(paceB);
        });

      // Take only the requested limit
      final limitedRuns = uniqueRuns.take(limit).toList();

      // Fetch and combine user data for each run
      final List<RunSession> result = [];

      for (final run in limitedRuns) {
        final runData = Map<String, dynamic>.from(run);

        // Fetch user data for this run
        try {
          final userResponse = await _supabase
              .from('users')
              .select('id, full_name, username, avatar_url, profile_color')
              .eq('id', run['user_id'])
              .maybeSingle();

          if (userResponse != null) {
            runData['users'] = userResponse;
          }
        } catch (e) {
          print('Error fetching user for run ${run['id']}: $e');
          // Continue without user data
        }

        result.add(RunSession.fromJson(runData));
      }

      return result;
    } catch (e) {
      print('Error fetching territory leaderboard: $e');
      rethrow;
    }
  }

  /// Get user's best run for a specific territory
  Future<RunSession?> getUserBestRunForTerritory({
    required int territoryId,
    required String userId,
  }) async {
    try {
      // Fetch run session
      final runResponse = await _supabase
          .from('run_sessions')
          .select()
          .eq('territory_id', territoryId)
          .eq('user_id', userId)
          .eq('status', 'completed')
          .order('average_pace_min_per_km', ascending: true)
          .limit(1)
          .maybeSingle();

      if (runResponse == null) return null;

      final runData = Map<String, dynamic>.from(runResponse);

      // Fetch user data
      try {
        final userResponse = await _supabase
            .from('users')
            .select('id, full_name, username, avatar_url, profile_color')
            .eq('id', userId)
            .maybeSingle();

        if (userResponse != null) {
          runData['users'] = userResponse;
        }
      } catch (e) {
        print('Error fetching user data: $e');
        // Continue without user data
      }

      return RunSession.fromJson(runData);
    } catch (e) {
      print('Error fetching user best run: $e');
      rethrow;
    }
  }

  /// Get all runs for a specific user in a territory
  Future<List<RunSession>> getUserRunsInTerritory({
    required int territoryId,
    required String userId,
  }) async {
    try {
      // Fetch all run sessions for this user in this territory
      final runResponse = await _supabase
          .from('run_sessions')
          .select()
          .eq('territory_id', territoryId)
          .eq('user_id', userId)
          .eq('status', 'completed')
          .gt('average_pace_min_per_km', 0) // Filter out pace = 0
          .order('start_time', ascending: false); // Latest first

      final runs = runResponse as List;
      if (runs.isEmpty) return [];

      // Fetch user data once
      Map<String, dynamic>? userData;
      try {
        final userResponse = await _supabase
            .from('users')
            .select('id, full_name, username, avatar_url, profile_color')
            .eq('id', userId)
            .maybeSingle();

        userData = userResponse;
      } catch (e) {
        print('Error fetching user data: $e');
      }

      // Combine run data with user data
      return runs.map((run) {
        final runData = Map<String, dynamic>.from(run);
        if (userData != null) {
          runData['users'] = userData;
        }
        return RunSession.fromJson(runData);
      }).toList();
    } catch (e) {
      print('Error fetching user runs in territory: $e');
      rethrow;
    }
  }

  /// Get territory statistics
  Future<TerritoryStats?> getTerritoryStats(int territoryId) async {
    try {
      final response = await _supabase
          .from('run_sessions')
          .select('id, user_id')
          .eq('territory_id', territoryId)
          .eq('status', 'completed');

      final runs = response as List;
      final totalRuns = runs.length;
      final uniqueRunners = runs.map((r) => r['user_id']).toSet().length;

      return TerritoryStats(
        totalRuns: totalRuns,
        uniqueRunners: uniqueRunners,
      );
    } catch (e) {
      print('Error fetching territory stats: $e');
      return null;
    }
  }

  /// Get territories owned by current user
  Future<List<Territory>> getUserOwnedTerritories(String userId) async {
    try {
      final response = await _supabase
          .from('territories')
          .select()
          .eq('owner_id', userId)
          .order('name', ascending: true);

      return (response as List)
          .map((territory) => Territory.fromJson(territory))
          .toList();
    } catch (e) {
      print('Error fetching user territories: $e');
      rethrow;
    }
  }

  /// Get territories by difficulty
  Future<List<Territory>> getTerritoriesByDifficulty(String difficulty) async {
    try {
      final response = await _supabase
          .from('territories')
          .select()
          .eq('difficulty', difficulty)
          .order('name', ascending: true);

      return (response as List)
          .map((territory) => Territory.fromJson(territory))
          .toList();
    } catch (e) {
      print('Error fetching territories by difficulty: $e');
      rethrow;
    }
  }
}

/// Territory statistics model
class TerritoryStats {
  final int totalRuns;
  final int uniqueRunners;

  TerritoryStats({
    required this.totalRuns,
    required this.uniqueRunners,
  });
}
