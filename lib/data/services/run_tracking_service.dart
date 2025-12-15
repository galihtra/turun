import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turun/app/app_logger.dart';
import '../model/running/run_session_model.dart';

/// Service untuk tracking run dan territory conquest
/// 
/// Territory ownership ditentukan berdasarkan PACE TERCEPAT:
/// - Pace lebih rendah = lebih cepat = lebih baik
/// - User dengan pace terendah di territory tersebut adalah owner
class RunTrackingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Run tracking state
  RunSession? _currentSession;
  final List<LatLng> _recordedPoints = [];
  double _totalDistance = 0;
  int _elapsedSeconds = 0;
  DateTime? _startTime;
  DateTime? _pauseTime;
  Timer? _timer;
  bool _isPaused = false;

  // Speed tracking
  double _currentSpeed = 0;
  LatLng? _lastPosition;
  DateTime? _lastPositionTime;

  // Getters
  List<LatLng> get recordedPoints => List.unmodifiable(_recordedPoints);
  double get totalDistance => _totalDistance;
  int get elapsedSeconds => _elapsedSeconds;
  double get currentSpeed => _currentSpeed;
  
  /// Current pace in minutes per km
  double get currentPace {
    if (_totalDistance <= 0) return 0;
    final distanceKm = _totalDistance / 1000;
    final durationMinutes = _elapsedSeconds / 60;
    if (distanceKm <= 0) return 0;
    return durationMinutes / distanceKm;
  }

  /// Start a new run session
  Future<RunSession?> startRunSession({
    required String userId,
    required int territoryId,
    required LatLng startLocation,
  }) async {
    try {
      AppLogger.info(LogLabel.supabase, '🏃 Starting run session...');
      
      _startTime = DateTime.now();
      _recordedPoints.clear();
      _recordedPoints.add(startLocation);
      _totalDistance = 0;
      _elapsedSeconds = 0;
      _isPaused = false;
      _currentSpeed = 0;
      _lastPosition = startLocation;
      _lastPositionTime = _startTime;

      // Insert ke database
      final response = await _supabase
          .from('run_sessions')
          .insert({
            'user_id': userId,
            'territory_id': territoryId,
            'start_time': _startTime!.toIso8601String(),
            'status': 'active',
            'route_points': [
              {'lat': startLocation.latitude, 'lng': startLocation.longitude}
            ],
          })
          .select()
          .single();

      _currentSession = RunSession.fromJson(response);

      // Start timer
      _startTimer();

      // Start GPS tracking
      _startGpsTracking();

      AppLogger.success(LogLabel.supabase, '✅ Run session started: ${_currentSession!.id}');
      return _currentSession;
    } catch (e, stackTrace) {
      AppLogger.error(LogLabel.supabase, 'Failed to start run session', e, stackTrace);
      return null;
    }
  }

  /// Start internal timer
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        _elapsedSeconds++;
      }
    });
  }

  /// GPS tracking subscription
  StreamSubscription<Position>? _gpsSubscription;

  void _startGpsTracking() {
    _gpsSubscription?.cancel();
    
    _gpsSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5, // Update every 5 meters
      ),
    ).listen((Position position) {
      if (_isPaused || _currentSession == null) return;

      final newPoint = LatLng(position.latitude, position.longitude);
      
      // Calculate distance from last point
      if (_recordedPoints.isNotEmpty) {
        final lastPoint = _recordedPoints.last;
        final distance = Geolocator.distanceBetween(
          lastPoint.latitude,
          lastPoint.longitude,
          newPoint.latitude,
          newPoint.longitude,
        );
        
        // Only add if moved at least 3 meters (filter GPS noise)
        if (distance >= 3) {
          _totalDistance += distance;
          _recordedPoints.add(newPoint);
          
          // Calculate current speed
          final now = DateTime.now();
          if (_lastPositionTime != null) {
            final timeDiffSeconds = now.difference(_lastPositionTime!).inMilliseconds / 1000;
            if (timeDiffSeconds > 0) {
              _currentSpeed = distance / timeDiffSeconds; // m/s
            }
          }
          _lastPosition = newPoint;
          _lastPositionTime = now;
        }
      }
    });
  }

  /// Pause run session
  void pauseRunSession() {
    if (_currentSession == null || _isPaused) return;
    
    _isPaused = true;
    _pauseTime = DateTime.now();
    _currentSpeed = 0;
    
    AppLogger.info(LogLabel.general, '⏸️ Run paused');
  }

  /// Resume run session
  void resumeRunSession() {
    if (_currentSession == null || !_isPaused) return;
    
    _isPaused = false;
    _pauseTime = null;
    
    AppLogger.info(LogLabel.general, '▶️ Run resumed');
  }

  /// Complete run session
  Future<RunSession?> completeRunSession({
    required LatLng endLocation,
  }) async {
    if (_currentSession == null) return null;

    try {
      AppLogger.info(LogLabel.supabase, '🏁 Completing run session...');

      // Stop tracking
      _timer?.cancel();
      _gpsSubscription?.cancel();

      // Add final point
      if (_recordedPoints.isEmpty || _recordedPoints.last != endLocation) {
        _recordedPoints.add(endLocation);
      }

      // Calculate final pace
      final distanceKm = _totalDistance / 1000;
      final durationMinutes = _elapsedSeconds / 60;
      final averagePace = distanceKm > 0 ? durationMinutes / distanceKm : 0;

      // Calculate calories (rough estimate: 60 cal/km for running)
      final caloriesBurned = (distanceKm * 60).round();

      // Prepare route points for storage
      final routePointsJson = _recordedPoints
          .map((p) => {'lat': p.latitude, 'lng': p.longitude})
          .toList();

      // Update database
      final response = await _supabase
          .from('run_sessions')
          .update({
            'end_time': DateTime.now().toIso8601String(),
            'distance_meters': _totalDistance,
            'duration_seconds': _elapsedSeconds,
            'average_pace_min_per_km': averagePace,
            'max_speed': _currentSpeed,
            'calories_burned': caloriesBurned,
            'route_points': routePointsJson,
            'status': 'completed',
          })
          .eq('id', _currentSession!.id)
          .select()
          .single();

      final completedSession = RunSession.fromJson(response);
      
      AppLogger.success(
        LogLabel.supabase,
        '✅ Run completed! Distance: ${(distanceKm).toStringAsFixed(2)}km, Pace: ${averagePace.toStringAsFixed(2)} min/km',
      );

      // Reset state
      _currentSession = null;
      _recordedPoints.clear();

      return completedSession;
    } catch (e, stackTrace) {
      AppLogger.error(LogLabel.supabase, 'Failed to complete run session', e, stackTrace);
      return null;
    }
  }

  /// Cancel run session
  void cancelRunSession() {
    _timer?.cancel();
    _gpsSubscription?.cancel();
    
    if (_currentSession != null) {
      // Delete from database (fire and forget)
      _supabase
          .from('run_sessions')
          .delete()
          .eq('id', _currentSession!.id)
          .then((_) {
            AppLogger.info(LogLabel.supabase, '🗑️ Run session cancelled and deleted');
          });
    }

    _currentSession = null;
    _recordedPoints.clear();
    _totalDistance = 0;
    _elapsedSeconds = 0;
    _isPaused = false;
    _currentSpeed = 0;
  }

  // ==================== TERRITORY CONQUEST LOGIC ====================

  /// Get the best (fastest pace) run for a territory
  /// Returns null if no completed runs exist for this territory
  /// [excludeRunId] - Optional run ID to exclude from search (used when checking if new run can conquer)
  Future<RunSession?> getBestRunForTerritory({
    required int territoryId,
    String? excludeRunId,
  }) async {
    try {
      AppLogger.info(LogLabel.supabase, '🔍 Getting best run for territory $territoryId...');
      if (excludeRunId != null) {
        AppLogger.info(LogLabel.supabase, '   Excluding run ID: $excludeRunId');
      }

      // Query run with lowest pace (fastest) for this territory
      // average_pace_min_per_km: lower = faster = better
      var query = _supabase
          .from('run_sessions')
          .select()
          .eq('territory_id', territoryId)
          .eq('status', 'completed')
          .gt('average_pace_min_per_km', 0); // Exclude invalid pace

      // Exclude specific run ID if provided
      if (excludeRunId != null) {
        query = query.neq('id', excludeRunId);
      }

      final response = await query
          .order('average_pace_min_per_km', ascending: true) // Lowest pace first
          .limit(1)
          .maybeSingle();

      if (response == null) {
        AppLogger.info(LogLabel.supabase, '📭 No completed runs found for territory $territoryId');
        return null;
      }

      final bestRun = RunSession.fromJson(response);
      AppLogger.success(
        LogLabel.supabase,
        '🏆 Best run found: ${bestRun.formattedPace} by user ${bestRun.userId}',
      );

      return bestRun;
    } catch (e, stackTrace) {
      AppLogger.error(LogLabel.supabase, 'Failed to get best run for territory', e, stackTrace);
      return null;
    }
  }

  /// Check if new run can conquer the territory
  /// Returns true if:
  /// 1. Territory has no previous runs (unclaimed)
  /// 2. New run has faster pace than current best
  Future<bool> canConquerTerritory({
    required RunSession newRun,
    RunSession? currentBestRun,
  }) async {
    try {
      // Validate new run has valid pace
      if (newRun.averagePaceMinPerKm <= 0) {
        AppLogger.warning(LogLabel.general, '⚠️ New run has invalid pace: ${newRun.averagePaceMinPerKm}');
        return false;
      }

      // Case 1: No previous runs - territory is unclaimed
      if (currentBestRun == null) {
        AppLogger.info(LogLabel.general, '🆕 Territory is unclaimed! User can conquer.');
        return true;
      }

      // Case 2: Compare pace (lower = faster = better)
      final newPace = newRun.averagePaceMinPerKm;
      final currentBestPace = currentBestRun.averagePaceMinPerKm;

      AppLogger.info(
        LogLabel.general,
        '⚔️ Pace comparison: New ${newPace.toStringAsFixed(2)} vs Best ${currentBestPace.toStringAsFixed(2)}',
      );

      // New run must be STRICTLY faster to conquer
      if (newPace < currentBestPace) {
        AppLogger.success(
          LogLabel.general,
          '🏆 NEW CHAMPION! ${newPace.toStringAsFixed(2)} < ${currentBestPace.toStringAsFixed(2)}',
        );
        return true;
      }

      // Check if it's the same user improving their own record
      if (newRun.userId == currentBestRun.userId && newPace < currentBestPace) {
        AppLogger.info(LogLabel.general, '📈 User improved their own best time!');
        return true;
      }

      AppLogger.info(
        LogLabel.general,
        '❌ Not fast enough to conquer. Need pace < ${currentBestPace.toStringAsFixed(2)}',
      );
      return false;
    } catch (e, stackTrace) {
      AppLogger.error(LogLabel.general, 'Failed to check territory conquest', e, stackTrace);
      return false;
    }
  }

  /// Update territory ownership in database
  Future<bool> updateTerritoryOwnership({
    required int territoryId,
    required String newOwnerId,
    String? previousOwnerId,
  }) async {
    try {
      AppLogger.info(
        LogLabel.supabase,
        '👑 Updating territory $territoryId ownership to $newOwnerId',
      );

      // Get new owner's name and profile color for display
      String? ownerName;
      String? ownerColor;
      try {
        final userResponse = await _supabase
            .from('users')
            .select('full_name, username, profile_color')
            .eq('id', newOwnerId)
            .maybeSingle();

        if (userResponse != null) {
          ownerName = userResponse['full_name'] ?? userResponse['username'] ?? 'Unknown';
          ownerColor = userResponse['profile_color'] as String?;
        }
      } catch (e) {
        AppLogger.warning(LogLabel.supabase, 'Could not fetch owner info: $e');
      }

      // Update territory with owner info and color
      await _supabase
          .from('territories')
          .update({
            'owner_id': newOwnerId,
            'owner_name': ownerName,
            'owner_color': ownerColor,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', territoryId);

      // Update run_sessions to mark territory as conquered
      await _supabase
          .from('run_sessions')
          .update({
            'territory_conquered': true,
            'previous_owner_id': previousOwnerId,
          })
          .eq('territory_id', territoryId)
          .eq('user_id', newOwnerId)
          .eq('status', 'completed')
          .order('average_pace_min_per_km', ascending: true)
          .limit(1);

      AppLogger.success(
        LogLabel.supabase,
        '✅ Territory $territoryId now owned by ${ownerName ?? newOwnerId}',
      );

      return true;
    } catch (e, stackTrace) {
      AppLogger.error(LogLabel.supabase, 'Failed to update territory ownership', e, stackTrace);
      return false;
    }
  }

  /// Get leaderboard for a territory (sorted by pace, ascending)
  Future<List<RunSession>> getTerritoryLeaderboard({
    required int territoryId,
    int limit = 10,
  }) async {
    try {
      AppLogger.info(LogLabel.supabase, '📊 Getting leaderboard for territory $territoryId...');

      final response = await _supabase
          .from('run_sessions')
          .select('''
            *,
            users:user_id (
              full_name,
              username,
              avatar_url,
              profile_color
            )
          ''')
          .eq('territory_id', territoryId)
          .eq('status', 'completed')
          .gt('average_pace_min_per_km', 0)
          .order('average_pace_min_per_km', ascending: true)
          .limit(limit);

      final sessions = (response as List)
          .map((json) => RunSession.fromJson(json))
          .toList();

      AppLogger.success(
        LogLabel.supabase,
        '📊 Leaderboard loaded: ${sessions.length} entries',
      );

      return sessions;
    } catch (e, stackTrace) {
      AppLogger.error(LogLabel.supabase, 'Failed to get territory leaderboard', e, stackTrace);
      return [];
    }
  }

  /// Get user's best run for a territory
  Future<RunSession?> getUserBestRunForTerritory({
    required String userId,
    required int territoryId,
  }) async {
    try {
      final response = await _supabase
          .from('run_sessions')
          .select()
          .eq('territory_id', territoryId)
          .eq('user_id', userId)
          .eq('status', 'completed')
          .gt('average_pace_min_per_km', 0)
          .order('average_pace_min_per_km', ascending: true)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      return RunSession.fromJson(response);
    } catch (e, stackTrace) {
      AppLogger.error(LogLabel.supabase, 'Failed to get user best run', e, stackTrace);
      return null;
    }
  }

  /// Cleanup
  void dispose() {
    _timer?.cancel();
    _gpsSubscription?.cancel();
    _recordedPoints.clear();
  }
}