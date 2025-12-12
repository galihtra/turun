import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turun/app/app_logger.dart';
import '../model/running/run_session_model.dart';

class RunTrackingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  StreamSubscription<Position>? _positionStream;
  Timer? _updateTimer;

  RunSession? _activeSession;
  final List<LatLng> _recordedPoints = [];
  final List<double> _speeds = [];

  Position? _lastPosition;
  DateTime? _lastUpdateTime;

  double _totalDistance = 0;
  int _elapsedSeconds = 0;
  double _currentSpeed = 0;

  RunSession? get activeSession => _activeSession;
  List<LatLng> get recordedPoints => List.unmodifiable(_recordedPoints);
  double get totalDistance => _totalDistance;
  int get elapsedSeconds => _elapsedSeconds;
  double get currentSpeed => _currentSpeed;
  double get currentPace => _currentSpeed > 0 ? 60 / (_currentSpeed * 3.6) : 0;
  bool get isRunning => _activeSession?.status == RunSessionStatus.active;

  // Start a new run session
  Future<RunSession?> startRunSession({
    required String userId,
    required int territoryId,
    required LatLng startLocation,
  }) async {
    try {
      // Reset tracking data
      _recordedPoints.clear();
      _speeds.clear();
      _totalDistance = 0;
      _elapsedSeconds = 0;
      _lastPosition = null;
      _lastUpdateTime = null;

      // Create new session
      _activeSession = RunSession(
        userId: userId,
        territoryId: territoryId,
        startTime: DateTime.now(),
        distanceMeters: 0,
        durationSeconds: 0,
        averagePaceMinPerKm: 0,
        maxSpeed: 0,
        caloriesBurned: 0,
        routePoints: [],
        status: RunSessionStatus.active,
      );

      _recordedPoints.add(startLocation);

      // Start GPS tracking
      _startGpsTracking();

      // Start timer
      _startTimer();

      AppLogger.success(
        LogLabel.general,
        'Run session started for territory $territoryId',
      );

      return _activeSession;
    } catch (e, stackTrace) {
      AppLogger.error(
        LogLabel.general,
        'Failed to start run session',
        e,
        stackTrace,
      );
      return null;
    }
  }

  // Start GPS tracking with high accuracy
  void _startGpsTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5, // Update every 5 meters
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _handleNewPosition(position);
      },
      onError: (error) {
        AppLogger.error(LogLabel.general, 'GPS tracking error', error);
      },
    );
  }

  // Handle new GPS position
  void _handleNewPosition(Position position) {
    final newPoint = LatLng(position.latitude, position.longitude);

    // Calculate distance from last point
    if (_lastPosition != null) {
      final distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      // Only add point if moved more than 3 meters (filter noise)
      if (distance > 3) {
        _recordedPoints.add(newPoint);
        _totalDistance += distance;

        // Calculate speed
        if (_lastUpdateTime != null) {
          final timeDiff = DateTime.now().difference(_lastUpdateTime!).inSeconds;
          if (timeDiff > 0) {
            _currentSpeed = distance / timeDiff; // m/s
            _speeds.add(_currentSpeed);
          }
        }

        _lastPosition = position;
        _lastUpdateTime = DateTime.now();
      }
    } else {
      _lastPosition = position;
      _lastUpdateTime = DateTime.now();
      _recordedPoints.add(newPoint);
    }
  }

  // Start elapsed time timer
  void _startTimer() {
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_activeSession?.status == RunSessionStatus.active) {
        _elapsedSeconds++;
      }
    });
  }

  // Pause run session
  void pauseRunSession() {
    if (_activeSession == null) return;

    _activeSession = _activeSession!.copyWith(
      status: RunSessionStatus.paused,
    );

    AppLogger.info(LogLabel.general, 'Run session paused');
  }

  // Resume run session
  void resumeRunSession() {
    if (_activeSession == null) return;

    _activeSession = _activeSession!.copyWith(
      status: RunSessionStatus.active,
    );

    AppLogger.info(LogLabel.general, 'Run session resumed');
  }

  // Complete run session and save to database
  Future<RunSession?> completeRunSession({
    required LatLng endLocation,
    double userWeightKg = 70.0,
  }) async {
    if (_activeSession == null) return null;

    try {
      // Stop tracking
      _stopTracking();

      // Add final point
      _recordedPoints.add(endLocation);

      // Calculate final metrics
      final averagePace = RunSession.calculatePace(_totalDistance, _elapsedSeconds);
      final maxSpeed = _speeds.isNotEmpty
          ? _speeds.reduce((a, b) => a > b ? a : b)
          : 0.0;
      final calories = RunSession.estimateCalories(
        _totalDistance / 1000,
        _elapsedSeconds ~/ 60,
        userWeightKg,
      );

      // Update session
      _activeSession = _activeSession!.copyWith(
        endTime: DateTime.now(),
        distanceMeters: _totalDistance,
        durationSeconds: _elapsedSeconds,
        averagePaceMinPerKm: averagePace,
        maxSpeed: maxSpeed,
        caloriesBurned: calories,
        routePoints: List.from(_recordedPoints),
        status: RunSessionStatus.completed,
      );

      // Save to database
      await _saveRunSessionToDatabase(_activeSession!);

      AppLogger.success(
        LogLabel.general,
        'Run session completed: ${_activeSession!.formattedDistance}, ${_activeSession!.formattedPace}',
      );

      return _activeSession;
    } catch (e, stackTrace) {
      AppLogger.error(
        LogLabel.general,
        'Failed to complete run session',
        e,
        stackTrace,
      );
      return null;
    }
  }

  // Cancel run session
  void cancelRunSession() {
    if (_activeSession == null) return;

    _stopTracking();

    _activeSession = _activeSession!.copyWith(
      status: RunSessionStatus.cancelled,
    );

    AppLogger.info(LogLabel.general, 'Run session cancelled');

    _activeSession = null;
  }

  // Stop all tracking
  void _stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  // Save run session to Supabase
  Future<void> _saveRunSessionToDatabase(RunSession session) async {
    try {
      final response = await _supabase
          .from('run_sessions')
          .insert(session.toJson())
          .select()
          .single();

      _activeSession = _activeSession!.copyWith(
        id: response['id'] as String,
      );

      AppLogger.success(
        LogLabel.supabase,
        'Run session saved to database',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        LogLabel.supabase,
        'Failed to save run session',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  // Get user's run history for a territory
  Future<List<RunSession>> getUserRunsForTerritory({
    required String userId,
    required int territoryId,
  }) async {
    try {
      final response = await _supabase
          .from('run_sessions')
          .select()
          .eq('user_id', userId)
          .eq('territory_id', territoryId)
          .eq('status', 'completed')
          .order('start_time', ascending: false);

      return (response as List)
          .map((json) => RunSession.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        LogLabel.supabase,
        'Failed to fetch user runs',
        e,
        stackTrace,
      );
      return [];
    }
  }

  // Get best run for a territory (fastest pace)
  Future<RunSession?> getBestRunForTerritory({
    required int territoryId,
  }) async {
    try {
      final response = await _supabase
          .from('run_sessions')
          .select()
          .eq('territory_id', territoryId)
          .eq('status', 'completed')
          .order('average_pace_min_per_km', ascending: true)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      return RunSession.fromJson(response);
    } catch (e, stackTrace) {
      AppLogger.error(
        LogLabel.supabase,
        'Failed to fetch best run',
        e,
        stackTrace,
      );
      return null;
    }
  }

  // Get leaderboard for a territory (top 10 fastest paces)
  Future<List<RunSession>> getTerritoryLeaderboard({
    required int territoryId,
    int limit = 10,
  }) async {
    try {
      final response = await _supabase
          .from('run_sessions')
          .select()
          .eq('territory_id', territoryId)
          .eq('status', 'completed')
          .order('average_pace_min_per_km', ascending: true)
          .limit(limit);

      return (response as List)
          .map((json) => RunSession.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        LogLabel.supabase,
        'Failed to fetch leaderboard',
        e,
        stackTrace,
      );
      return [];
    }
  }

  // Check if user can conquer territory
  Future<bool> canConquerTerritory({
    required RunSession newRun,
    required RunSession? currentBestRun,
  }) async {
    // If no one owns the territory, user can conquer it
    if (currentBestRun == null) return true;

    // If current owner, can't conquer own territory
    if (currentBestRun.userId == newRun.userId) return false;

    // Compare paces (lower is better)
    return newRun.averagePaceMinPerKm < currentBestRun.averagePaceMinPerKm;
  }

  // Update territory ownership
  Future<void> updateTerritoryOwnership({
    required int territoryId,
    required String newOwnerId,
    required String? previousOwnerId,
  }) async {
    try {
      await _supabase.from('territories').update({
        'owner_id': newOwnerId,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', territoryId);

      AppLogger.success(
        LogLabel.supabase,
        'Territory $territoryId ownership updated',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        LogLabel.supabase,
        'Failed to update territory ownership',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  // Dispose resources
  void dispose() {
    _stopTracking();
    _activeSession = null;
    _recordedPoints.clear();
    _speeds.clear();
  }
}
