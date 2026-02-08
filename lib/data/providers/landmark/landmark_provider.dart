import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turun/app/app_logger.dart';
import 'package:turun/data/services/notification_service.dart';
import 'package:turun/data/services/push_notification_service.dart';
import 'package:turun/data/services/navigation_notification_service.dart';

import '../../model/territory/territory_model.dart';
import '../../model/running/run_session_model.dart';

/// Provider for Landmark running mode
/// Handles free running without territory boundaries
class LandmarkProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final NotificationService _notificationService = NotificationService();
  final PushNotificationService _pushNotificationService = PushNotificationService();
  final NavigationNotificationService _navNotificationService = NavigationNotificationService();

  // Landmark run tracking
  final List<LatLng> _routePoints = [];
  bool _isRecording = false;
  LatLng? _startPoint;
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

  // Planned Route (Pre-run)
  List<LatLng> _plannedRoutePoints = [];
  bool get hasPlannedRoute => _plannedRoutePoints.isNotEmpty;
  List<LatLng> get plannedRoutePoints => List.unmodifiable(_plannedRoutePoints);

  // All user-created territories (for display on global map)
  List<Territory> _userTerritories = [];
  bool _isLoadingTerritories = false;
  final Set<Polygon> _territoryPolygons = {};
  final Set<Polyline> _territoryPolylines = {}; // ✅ NEW

  // Constants
  static const double minDistanceMeters = 500.0; // Minimum 500m for valid landmark
  static const int gpsDistanceFilter = 3; // 3 meters for high accuracy
  static const double territoryProximityMeters = 1000.0; // 1km proximity check for existing territories

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
  Set<Polyline> get territoryPolylines => _territoryPolylines; // ✅ NEW

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

  /// Check if user is near any existing territory
  /// Returns the nearest territory if within proximity, null otherwise
  /// 
  /// FIXED: Now checks distance to the NEAREST POINT on the territory route,
  /// not just the center. This prevents blocking landmark creation when user
  /// is far from the actual route but close to the center of a long territory.
  Future<Territory?> checkTerritoryProximity(LatLng currentLocation) async {
    try {
      // Load territories if not already loaded
      if (_userTerritories.isEmpty) {
        await loadUserTerritories();
      }

      for (final territory in _userTerritories) {
        if (territory.points.isEmpty) continue;

        // First, quick check using center + max radius to skip far territories
        double totalLat = 0;
        double totalLng = 0;
        for (var point in territory.points) {
          totalLat += point.latitude;
          totalLng += point.longitude;
        }
        final centerLat = totalLat / territory.points.length;
        final centerLng = totalLng / territory.points.length;

        // Calculate max radius from center to any point
        double maxRadius = 0;
        for (var point in territory.points) {
          final d = Geolocator.distanceBetween(
            centerLat, centerLng, point.latitude, point.longitude);
          if (d > maxRadius) maxRadius = d;
        }

        // Quick check: if distance to center > maxRadius + proximityMeters, skip
        final distanceToCenter = Geolocator.distanceBetween(
          currentLocation.latitude,
          currentLocation.longitude,
          centerLat,
          centerLng,
        );

        if (distanceToCenter > maxRadius + territoryProximityMeters) {
          continue; // Too far, skip detailed check
        }

        // Detailed check: find distance to NEAREST point on the route
        double minDistanceToRoute = double.infinity;
        for (var point in territory.points) {
          final distance = Geolocator.distanceBetween(
            currentLocation.latitude,
            currentLocation.longitude,
            point.latitude,
            point.longitude,
          );
          if (distance < minDistanceToRoute) {
            minDistanceToRoute = distance;
          }
        }

        // If within proximity of ANY point on the route, return this territory
        if (minDistanceToRoute <= territoryProximityMeters) {
          AppLogger.info(
            LogLabel.general,
            'User is near territory route: ${territory.name} (${minDistanceToRoute.toStringAsFixed(0)}m from nearest point)',
          );
          return territory;
        }
      }

      return null;
    } catch (e) {
      AppLogger.error(LogLabel.general, 'Failed to check territory proximity: $e');
      return null;
    }
  }

  /// ✅ NEW: Check if a planned route overlaps with ANY existing territory
  /// Returns the territory it overlaps with, or null if clear.
  Future<Territory?> checkRouteOverlap(List<LatLng> points) async {
    try {
      if (_userTerritories.isEmpty) {
        await loadUserTerritories();
      }

      const double overlapThreshold = 50.0; // 50 meters overlap limit

      for (final territory in _userTerritories) {
        if (territory.points.isEmpty) continue;

        // Optimized check: first check distance to territory center
        // If center is very far away, skip detailed point check
        double tLat = 0, tLng = 0;
        for (var tp in territory.points) {
          tLat += tp.latitude;
          tLng += tp.longitude;
        }
        final centerLat = tLat / territory.points.length;
        final centerLng = tLng / territory.points.length;

        // Find max radius of territory from center
        double maxRadius = 0;
        for (var tp in territory.points) {
          final d = Geolocator.distanceBetween(centerLat, centerLng, tp.latitude, tp.longitude);
          if (d > maxRadius) maxRadius = d;
        }

        // Check if ANY planned point is roughly near the territory circle
        bool isRoughlyNear = false;
        for (var p in points) {
          final distToCenter = Geolocator.distanceBetween(p.latitude, p.longitude, centerLat, centerLng);
          if (distToCenter < maxRadius + overlapThreshold + 100) { // 100m buffer
            isRoughlyNear = true;
            break;
          }
        }

        if (!isRoughlyNear) continue;

        // Detailed check: compare every point in route with every point in territory
        // (For small datasets, this N*M is acceptable in planning phase)
        for (var p in points) {
          for (var tp in territory.points) {
            final distance = Geolocator.distanceBetween(
              p.latitude,
              p.longitude,
              tp.latitude,
              tp.longitude,
            );

            if (distance < overlapThreshold) {
              AppLogger.warning(
                LogLabel.general,
                '⚠️ Overlap detected with ${territory.name} at distance ${distance.toStringAsFixed(1)}m',
              );
              return territory;
            }
          }
        }
      }

      return null;
    } catch (e, stackTrace) {
      AppLogger.error(LogLabel.general, 'Failed to check route overlap', e, stackTrace);
      return null;
    }
  }

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
      
      // ✅ Start navigation notification
      final routeName = hasPlannedRoute ? 'Ghost Route' : 'Free Run';
      await _navNotificationService.startNavigation(
        territoryName: routeName,
        totalCheckpoints: hasPlannedRoute ? (_plannedRoutePoints.length / 10).ceil() : 1,
      );

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
        
        // ✅ Update navigation notification every second
        _updateNavigationNotification();
        
        notifyListeners();
      }
    });
  }
  
  /// Update navigation notification with current progress
  void _updateNavigationNotification() {
    final routeName = hasPlannedRoute ? 'Ghost Route' : 'Free Run';
    
    // Calculate progress if following planned route
    int currentCheckpoint = 0;
    int totalCheckpoints = 0;
    String? nextDirection;
    
    if (hasPlannedRoute && _routePoints.isNotEmpty) {
      totalCheckpoints = (_plannedRoutePoints.length / 10).ceil(); // Approximate checkpoints
      currentCheckpoint = (_routePoints.length / (_plannedRoutePoints.length / totalCheckpoints)).floor();
      currentCheckpoint = currentCheckpoint.clamp(0, totalCheckpoints);
      
      // Calculate distance to end
      if (_lastPosition != null && _plannedRoutePoints.isNotEmpty) {
        final endPoint = _plannedRoutePoints.last;
        final distToEnd = Geolocator.distanceBetween(
          _lastPosition!.latitude, _lastPosition!.longitude,
          endPoint.latitude, endPoint.longitude,
        );
        nextDirection = 'To finish: ${distToEnd.toStringAsFixed(0)}m';
      }
    }
    
    _navNotificationService.updateProgress(
      territoryName: routeName,
      currentCheckpoint: currentCheckpoint,
      totalCheckpoints: totalCheckpoints > 0 ? totalCheckpoints : 1,
      distanceKm: _totalDistance / 1000,
      elapsedSeconds: _elapsedSeconds,
      paceMinPerKm: currentPace,
      nextDirection: nextDirection,
    );
  }

  /// Start GPS tracking with platform-specific background support
  /// ✅ Uses stream + polling backup for reliable background tracking
  Timer? _gpsPollingTimer;
  static const int _gpsPollingIntervalMs = 3000; // Poll every 3 seconds
  
  void _startGpsTracking() {
    _stopGpsTracking();

    // ✅ APPROACH 1: Start GPS stream (may stop in background)
    _startGpsStream();
    
    // ✅ APPROACH 2: Start polling as BACKUP (more reliable in background)
    _startGpsPolling();
    
    AppLogger.info(LogLabel.general, '📍 Landmark GPS tracking started with stream + polling backup');
  }
  
  /// Start GPS stream for landmark tracking
  void _startGpsStream() {
    // ✅ Use platform-specific settings for background tracking
    late LocationSettings locationSettings;
    
    if (Platform.isAndroid) {
      // Android: Use Foreground Service for background tracking
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: gpsDistanceFilter,
        forceLocationManager: false,
        intervalDuration: const Duration(seconds: 2),
        // ✅ FOREGROUND SERVICE - Keeps GPS running when screen is locked
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: "Recording your landmark route...",
          notificationTitle: "TURUN Landmark 🗺️",
          enableWakeLock: true,
          setOngoing: true,
          notificationIcon: AndroidResource(name: 'launcher_icon', defType: 'mipmap'),
        ),
      );
    } else if (Platform.isIOS) {
      // iOS: Use Apple settings for background location
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.fitness,
        distanceFilter: gpsDistanceFilter,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    } else {
      // Fallback for other platforms
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: gpsDistanceFilter,
      );
    }

    _gpsStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _updateRoute(position);
    });
  }
  
  /// ✅ Periodic GPS polling (backup for when stream stops in background)
  void _startGpsPolling() {
    _gpsPollingTimer = Timer.periodic(
      const Duration(milliseconds: _gpsPollingIntervalMs),
      (timer) async {
        if (!_isRecording || _activeRunSession == null) return;
        
        try {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.bestForNavigation,
              timeLimit: Duration(seconds: 5),
            ),
          );
          
          _updateRoute(position);
        } catch (e) {
          // Silently fail - polling is a backup
          AppLogger.debug(LogLabel.general, '📍 Landmark GPS polling failed: $e');
        }
      },
    );
  }

  /// Stop GPS tracking
  void _stopGpsTracking() {
    _gpsStream?.cancel();
    _gpsStream = null;
    _gpsPollingTimer?.cancel();
    _gpsPollingTimer = null;
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
        
        // ✅ Update navigation notification on every GPS update (real-time)
        _updateNavigationNotification();
        
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
      
      // ✅ Stop navigation notification
      await _navNotificationService.stopNavigation();

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

      // Show push notification
      await _pushNotificationService.showRunCompletedNotification(
        title: '🏁 LANDMARK COMPLETED!',
        body: 'Great job! You covered ${(finalDistance / 1000).toStringAsFixed(2)} km. Register this landmark as your territory now!',
        data: {
          'type': 'landmarkRunCompleted',
          'session_id': _activeRunSession!.id,
          'distance': finalDistance,
        },
      );

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
      
      // ✅ Stop navigation notification
      await _navNotificationService.stopNavigation();

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
        'difficulty': _calculateDifficulty(_totalDistance),
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

      // Show push notification for landmark creation
      await _pushNotificationService.showRunCompletedNotification(
        title: '🏗️ TERRITORY CLAIMED!',
        body: 'Congratulations! Your new landmark "${territory.name}" is now officially under your control!',
        data: {
          'type': 'territoryCreated',
          'territory_id': territory.id,
          'territory_name': territory.name,
        },
      );

      // Save to notification history
      await _notificationService.generateTerritoryCreatedNotification(
        userId: userId,
        territoryId: territory.id,
        territoryName: territory.name ?? 'New Landmark',
      );

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

  /// Update territory name and description
  Future<bool> updateTerritoryDetails({
    required int territoryId,
    required String name,
    required String description,
  }) async {
    try {
      final now = DateTime.now();
      await _supabase.from('territories').update({
        'name': name,
        'region': description,
        'updated_at': now.toIso8601String(),
      }).eq('id', territoryId);

      AppLogger.success(LogLabel.general, 'Territory $territoryId updated: $name');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(LogLabel.general, 'Failed to update territory details', e, stackTrace);
      return false;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Simplify route points for territory creation
  /// Reduces the number of points while maintaining route shape
  List<LatLng> _simplifyRoutePoints(List<LatLng> points) {
    if (points.length <= 20) return points; // Already simple enough

    // Target: High fidelity visualization + fun checkpoint density
    // We keep a point roughly every 12-15 meters.
    // This allows the visual line to follow road curves perfectly.
    const double targetInterval = 12.0; 

    final simplified = <LatLng>[points.first]; // Always include start
    LatLng lastIncluded = points.first;

    for (int i = 1; i < points.length - 1; i++) {
      final distance = Geolocator.distanceBetween(
        lastIncluded.latitude,
        lastIncluded.longitude,
        points[i].latitude,
        points[i].longitude,
      );

      // Only include point if it's far enough from the last one
      if (distance >= targetInterval) {
        simplified.add(points[i]);
        lastIncluded = points[i];
      }
    }

    // Always include the last point to close the route accurately
    if (simplified.last != points.last) {
      simplified.add(points.last);
    }

    AppLogger.info(
      LogLabel.general,
      'Simplified route: ${points.length} points → ${simplified.length} points (Fidelity focused)',
    );

    return simplified;
  }

  /// Calculate difficulty based on distance
  String _calculateDifficulty(double distanceMeters) {
    final distanceKm = distanceMeters / 1000;
    if (distanceKm < 3) return 'Easy';
    if (distanceKm < 10) return 'Medium';
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
    _territoryPolylines.clear();

    for (final territory in _userTerritories) {
      if (territory.points.isEmpty) continue;

      final color = _parseColor(territory.ownerColor);

      // ✅ ADD: Polyline to follow route exactly
      _territoryPolylines.add(
        Polyline(
          polylineId: PolylineId('user_territory_line_${territory.id}'),
          points: territory.points,
          color: color,
          width: 3,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      );

      // Check if it's a loop for Polygon fill
      bool isLoop = false;
      if (territory.points.length >= 3) {
        final dist = Geolocator.distanceBetween(
          territory.points.first.latitude,
          territory.points.first.longitude,
          territory.points.last.latitude,
          territory.points.last.longitude,
        );
        isLoop = dist < 40;
      }

      if (isLoop) {
        _territoryPolygons.add(
          Polygon(
            polygonId: PolygonId('user_territory_${territory.id}'),
            points: territory.points,
            strokeColor: Colors.transparent, // Border handled by polyline
            strokeWidth: 0,
            fillColor: color.withValues(alpha: 0.2),
          ),
        );
      }
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
    _timer?.cancel();
    _elapsedSeconds = 0;
    _totalDistance = 0.0;
    _lastPosition = null;
    _routePolylines.clear();
    _markers.clear();
    _activeRunSession = null;
    notifyListeners();
  }

  // ==================== PLANNED ROUTE METHODS ====================

  /// Set the planned route points
  void setPlannedRoute(List<LatLng> points) {
    _plannedRoutePoints = List.from(points);
    notifyListeners();
  }

  /// Clear the planned route
  void clearPlannedRoute() {
    _plannedRoutePoints.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopGpsTracking();
    _timer?.cancel();
    super.dispose();
  }
}
