import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turun/app/app_logger.dart';

import '../../model/territory/territory_model.dart';
import '../../model/running/run_session_model.dart';

/// Provider for Landmark running mode
/// Handles free running without territory boundaries
class LandmarkProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Landmark run tracking
  final List<LatLng> _routePoints = [];
  bool _isRecording = false;
  LatLng? _startPoint;
  DateTime? _startTime;
  Timer? _timer;
  int _elapsedSeconds = 0;
  double _totalDistance = 0.0;
  LatLng? _lastPosition;

  // GPS tracking
  StreamSubscription<Position>? _gpsStream;

  // Active run session
  RunSession? _activeRunSession;
  bool _isRunning = false;
  bool _runCompleted = false;

  // Map visualization
  final Set<Polyline> _routePolylines = {};
  final Set<Marker> _markers = {};

  // All user-created territories (for display on global map)
  List<Territory> _userTerritories = [];
  bool _isLoadingTerritories = false;
  final Set<Polygon> _territoryPolygons = {};

  // Constants
  static const double minDistanceMeters = 500.0; // Minimum 500m for valid landmark
  static const int gpsDistanceFilter = 3; // 3 meters for high accuracy

  // Getters
  List<LatLng> get routePoints => List.unmodifiable(_routePoints);
  bool get isRecording => _isRecording;
  LatLng? get startPoint => _startPoint;
  bool get isRunning => _isRunning;
  int get elapsedSeconds => _elapsedSeconds;
  double get totalDistance => _totalDistance;
  RunSession? get activeRunSession => _activeRunSession;
  bool get runCompleted => _runCompleted;
  Set<Polyline> get routePolylines => _routePolylines;
  Set<Marker> get markers => _markers;
  List<Territory> get userTerritories => _userTerritories;
  bool get isLoadingTerritories => _isLoadingTerritories;
  Set<Polygon> get territoryPolygons => _territoryPolygons;

  /// Current pace (min/km)
  double get currentPace {
    if (_totalDistance <= 0) return 0.0;
    final distanceKm = _totalDistance / 1000;
    final durationMin = _elapsedSeconds / 60;
    return distanceKm > 0 ? durationMin / distanceKm : 0.0;
  }

  /// Check if distance is valid for creating landmark
  bool get isDistanceValid => _totalDistance >= minDistanceMeters;

  /// Formatted distance for display
  String get formattedDistance {
    if (_totalDistance < 1000) {
      return '${_totalDistance.toStringAsFixed(0)} m';
    }
    return '${(_totalDistance / 1000).toStringAsFixed(2)} km';
  }

  /// Formatted duration for display
  String get formattedDuration {
    final hours = _elapsedSeconds ~/ 3600;
    final minutes = (_elapsedSeconds % 3600) ~/ 60;
    final seconds = _elapsedSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    }
    return '${minutes}m ${seconds}s';
  }

  // ==================== LANDMARK RUN METHODS ====================

  /// Start a new landmark run
  Future<bool> startLandmarkRun(LatLng currentLocation) async {
    if (_isRunning) {
      AppLogger.warning(LogLabel.general, 'Landmark run already in progress');
      return false;
    }

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Fetch user profile
      final userProfile = await _supabase
          .from('users')
          .select('full_name, username, avatar_url, profile_color')
          .eq('id', userId)
          .single();

      final now = DateTime.now();

      // Initialize tracking
      _startPoint = currentLocation;
      _startTime = now;
      _routePoints.clear();
      _routePoints.add(currentLocation);
      _lastPosition = currentLocation;
      _elapsedSeconds = 0;
      _totalDistance = 0.0;
      _isRecording = true;
      _isRunning = true;
      _runCompleted = false;

      // Create run session in database (temporary, will be converted to landmark if valid)
      final runSessionData = {
        'user_id': userId,
        'territory_id': -1, // Special value for landmark runs
        'status': RunSessionStatus.active.name,
        'start_time': now.toIso8601String(),
        'route_points': [
          {
            'lat': currentLocation.latitude,
            'lng': currentLocation.longitude,
          }
        ],
        'distance_meters': 0.0,
        'duration_seconds': 0,
        'average_pace_min_per_km': 0.0,
        'max_speed': 0.0,
        'calories_burned': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final response = await _supabase
          .from('run_sessions')
          .insert(runSessionData)
          .select()
          .single();

      _activeRunSession = RunSession(
        id: response['id'],
        userId: userId,
        territoryId: -1,
        userName: userProfile['full_name'] ?? 'Unknown',
        userUsername: userProfile['username'] ?? 'unknown',
        userAvatarUrl: userProfile['avatar_url'],
        userProfileColor: userProfile['profile_color'],
        status: RunSessionStatus.active,
        startTime: now,
        createdAt: now,
        updatedAt: now,
        routePoints: [currentLocation],
      );

      // Start tracking
      _startTimer();
      _startGpsTracking();
      _createStartMarker();

      AppLogger.success(LogLabel.general, 'Landmark run started');
      notifyListeners();
      return true;
    } catch (e) {
      AppLogger.error(LogLabel.general, 'Failed to start landmark run: $e');
      _clearData();
      return false;
    }
  }

  /// Start timer for tracking duration
  void _startTimer() {
    _timer?.cancel();
    _elapsedSeconds = 0;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRecording) {
        _elapsedSeconds++;
        notifyListeners();
      }
    });
  }

  /// Start GPS tracking
  void _startGpsTracking() {
    _stopGpsTracking();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: gpsDistanceFilter,
    );

    _gpsStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _updateRoute(position);
    });
  }

  /// Stop GPS tracking
  void _stopGpsTracking() {
    _gpsStream?.cancel();
    _gpsStream = null;
  }

  /// Update route as user moves
  void _updateRoute(Position position) {
    if (!_isRecording || _activeRunSession == null) return;

    final currentPoint = LatLng(position.latitude, position.longitude);

    // Calculate distance from last position
    if (_lastPosition != null) {
      final distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        currentPoint.latitude,
        currentPoint.longitude,
      );

      // Only add point if movement is significant
      if (distance > gpsDistanceFilter) {
        _totalDistance += distance;
        _routePoints.add(currentPoint);
        _lastPosition = currentPoint;

        // Calculate pace
        final pace = currentPace;

        // Update active run session
        _activeRunSession = _activeRunSession!.copyWith(
          routePoints: List.from(_routePoints),
          distanceMeters: _totalDistance,
          durationSeconds: _elapsedSeconds,
          averagePaceMinPerKm: pace,
          updatedAt: DateTime.now(),
        );

        // Draw route
        _drawRoute();
        notifyListeners();
      }
    } else {
      _lastPosition = currentPoint;
    }
  }

  /// Draw route on map
  void _drawRoute() {
    _routePolylines.clear();

    if (_routePoints.length < 2) return;

    _routePolylines.add(
      Polyline(
        polylineId: const PolylineId('landmark_route'),
        points: _routePoints,
        color: const Color(0xFF00E676), // Bright green
        width: 6,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    );
  }

  /// Create start marker
  void _createStartMarker() {
    if (_startPoint == null) return;

    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('landmark_start'),
        position: _startPoint!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Start Point'),
      ),
    );
  }

  /// Complete landmark run
  /// Returns the completed session for validation
  Future<RunSession?> completeLandmarkRun() async {
    if (_activeRunSession == null || !_isRecording) return null;

    try {
      _runCompleted = true;
      _isRecording = false;
      _stopGpsTracking();
      _timer?.cancel();

      final endTime = DateTime.now();
      final finalDistance = _totalDistance;
      final finalDuration = _elapsedSeconds;
      final finalPace = currentPace;
      final calories = (finalDistance / 1000 * 60).round();

      // Update run session in database
      await _supabase.from('run_sessions').update({
        'status': RunSessionStatus.completed.name,
        'end_time': endTime.toIso8601String(),
        'route_points': _routePoints
            .map((point) => {
                  'lat': point.latitude,
                  'lng': point.longitude,
                })
            .toList(),
        'distance_meters': finalDistance,
        'duration_seconds': finalDuration,
        'average_pace_min_per_km': finalPace,
        'calories_burned': calories,
        'updated_at': endTime.toIso8601String(),
      }).eq('id', _activeRunSession!.id);

      // Update local session
      _activeRunSession = _activeRunSession!.copyWith(
        status: RunSessionStatus.completed,
        endTime: endTime,
        distanceMeters: finalDistance,
        durationSeconds: finalDuration,
        averagePaceMinPerKm: finalPace,
        caloriesBurned: calories,
        updatedAt: endTime,
      );

      _isRunning = false;

      AppLogger.success(LogLabel.general, 'Landmark run completed');
      notifyListeners();

      return _activeRunSession;
    } catch (e) {
      AppLogger.error(LogLabel.general, 'Failed to complete landmark run: $e');
      return null;
    }
  }

  /// Cancel landmark run
  Future<void> cancelLandmarkRun() async {
    if (_activeRunSession == null) return;

    try {
      // Delete the run session from database
      await _supabase
          .from('run_sessions')
          .delete()
          .eq('id', _activeRunSession!.id);

      _clearData();
      _isRunning = false;
      _runCompleted = false;

      AppLogger.info(LogLabel.general, 'Landmark run cancelled');
      notifyListeners();
    } catch (e) {
      AppLogger.error(LogLabel.general, 'Failed to cancel landmark run: $e');
    }
  }

  /// Create territory from completed landmark run
  Future<Territory?> createTerritory({
    required String name,
    required String description,
  }) async {
    if (_activeRunSession == null || !_runCompleted) {
      AppLogger.error(LogLabel.general, 'No completed run session to create landmark');
      return null;
    }

    if (_totalDistance < minDistanceMeters) {
      AppLogger.error(
        LogLabel.general,
        'Distance too short: ${_totalDistance}m < ${minDistanceMeters}m',
      );
      return null;
    }

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();

      // Fetch user profile to get owner info
      final userProfile = await _supabase
          .from('users')
          .select('full_name, profile_color')
          .eq('id', userId)
          .single();

      // Simplify route points to create reasonable number of checkpoints
      final simplifiedPoints = _simplifyRoutePoints(_routePoints);

      // Create territory in database (user-created landmark becomes a territory)
      final territoryData = {
        'name': name,
        'region': description.isNotEmpty ? description : name, // Use description as region, or name as fallback
        'points': simplifiedPoints
            .map((point) => {
                  'lat': point.latitude,
                  'lng': point.longitude,
                })
            .toList(),
        'owner_id': userId,
        'owner_name': userProfile['full_name'], // Store owner name directly
        'owner_color': userProfile['profile_color'], // Store owner color directly
        // 'difficulty': _calculateDifficulty(_totalDistance), // Temporarily commented out
        'reward_points': _calculateRewardPoints(_totalDistance),
        'area_size_km': _totalDistance / 1000, // Convert meters to kilometers
        'image_url': null, // User-created territories don't have images initially
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final response = await _supabase
          .from('territories')
          .insert(territoryData)
          .select()
          .single();

      final territory = Territory.fromJson(response);

      AppLogger.success(LogLabel.general, 'Territory created from landmark: ${territory.name}');

      // ✅ UPDATE: Link the run session to the newly created territory
      // This ensures the owner's run appears in the leaderboard
      if (_activeRunSession != null) {
        try {
          await _supabase
              .from('run_sessions')
              .update({
                'territory_id': territory.id,
                'updated_at': now.toIso8601String(),
              })
              .eq('id', _activeRunSession!.id);

          AppLogger.success(
            LogLabel.general,
            'Linked run session ${_activeRunSession!.id} to territory ${territory.id}',
          );
        } catch (e) {
          AppLogger.error(
            LogLabel.general,
            'Failed to link run session to territory: $e',
          );
          // Continue even if linking fails - territory is still created
        }
      }

      // Clear current run data
      _clearData();

      // Reload territories to include the new one
      await loadUserTerritories();

      notifyListeners();
      return territory;
    } catch (e) {
      AppLogger.error(LogLabel.general, 'Failed to create landmark: $e');
      return null;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Simplify route points for territory creation
  /// Reduces the number of points while maintaining route shape
  List<LatLng> _simplifyRoutePoints(List<LatLng> points) {
    if (points.length <= 10) return points; // Already simple enough

    // Target: ~8-15 checkpoints for a good gameplay experience
    // Minimum distance between checkpoints based on total distance
    final totalDistance = _totalDistance;
    final targetCheckpoints = totalDistance < 2000
        ? 8   // Short route: 8 checkpoints
        : totalDistance < 5000
            ? 12  // Medium route: 12 checkpoints
            : 15; // Long route: 15 checkpoints

    final minDistanceBetweenPoints = totalDistance / targetCheckpoints;

    final simplified = <LatLng>[points.first]; // Always include start
    LatLng lastIncluded = points.first;

    for (int i = 1; i < points.length - 1; i++) {
      final distance = Geolocator.distanceBetween(
        lastIncluded.latitude,
        lastIncluded.longitude,
        points[i].latitude,
        points[i].longitude,
      );

      if (distance >= minDistanceBetweenPoints) {
        simplified.add(points[i]);
        lastIncluded = points[i];
      }
    }

    simplified.add(points.last); // Always include end

    AppLogger.info(
      LogLabel.general,
      'Simplified route: ${points.length} points → ${simplified.length} checkpoints',
    );

    return simplified;
  }

  /// Calculate difficulty based on distance
  String _calculateDifficulty(double distanceMeters) {
    final distanceKm = distanceMeters / 1000;
    if (distanceKm < 2) return 'Easy';
    if (distanceKm < 5) return 'Medium';
    return 'Hard';
  }

  /// Calculate reward points based on distance
  int _calculateRewardPoints(double distanceMeters) {
    final distanceKm = distanceMeters / 1000;
    return (distanceKm * 100).round(); // 100 points per km
  }

  // ==================== TERRITORY LOADING & DISPLAY ====================

  /// Load all user-created territories for global map display
  Future<void> loadUserTerritories() async {
    _isLoadingTerritories = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('territories')
          .select()
          .order('created_at', ascending: false);

      _userTerritories = (response as List)
          .map((json) => Territory.fromJson(json as Map<String, dynamic>))
          .toList();

      _generateTerritoryPolygons();

      AppLogger.success(LogLabel.general, 'Loaded ${_userTerritories.length} user territories');
    } catch (e) {
      AppLogger.error(LogLabel.general, 'Failed to load user territories: $e');
      _userTerritories = [];
    } finally {
      _isLoadingTerritories = false;
      notifyListeners();
    }
  }

  /// Generate polygons for user territories to display on map
  void _generateTerritoryPolygons() {
    _territoryPolygons.clear();

    for (final territory in _userTerritories) {
      if (territory.points.length < 3) continue;

      // Create a polygon from the territory points
      final color = _parseColor(territory.ownerColor);

      _territoryPolygons.add(
        Polygon(
          polygonId: PolygonId('user_territory_${territory.id}'),
          points: territory.points,
          strokeColor: color,
          strokeWidth: 3,
          fillColor: color.withValues(alpha: 0.2),
        ),
      );
    }
  }

  /// Parse color from hex string
  Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return Colors.green;
    }

    try {
      String color = hexColor.replaceAll('#', '');
      if (color.length == 6) {
        color = 'FF$color';
      }
      return Color(int.parse('0x$color'));
    } catch (e) {
      return Colors.green;
    }
  }

  /// Clear all data
  void _clearData() {
    _routePoints.clear();
    _isRecording = false;
    _startPoint = null;
    _startTime = null;
    _timer?.cancel();
    _elapsedSeconds = 0;
    _totalDistance = 0.0;
    _lastPosition = null;
    _routePolylines.clear();
    _markers.clear();
    _activeRunSession = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopGpsTracking();
    _timer?.cancel();
    super.dispose();
  }
}
