import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turun/app/app_logger.dart';

import '../../model/territory/territory_model.dart';
import '../../model/running/run_session_model.dart';
import '../../services/directions_service.dart';
import '../../services/run_tracking_service.dart';

class RunningProvider extends ChangeNotifier {
  // Location properties
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;
  LatLng? _currentLatLng;
  StreamSubscription<Position>? _positionStream;

  // Territories properties
  List<Territory> _territories = [];
  final Set<Polygon> _polygons = {};
  final Set<Marker> _markers = {};
  bool _isLoadingTerritories = false;
  String? _territoriesError;

  // Navigation properties
  Territory? _selectedTerritory;
  final Set<Polyline> _routePolylines = {};
  List<LatLng> _routePoints = [];
  bool _isNavigating = false;
  bool _isLoadingRoute = false;
  double? _distanceToDestination;
  double? _estimatedTime;
  String? _distanceText;
  String? _durationText;

  // Run tracking properties
  final RunTrackingService _runTrackingService = RunTrackingService();
  RunSession? _activeRunSession;
  bool _isRunning = false;
  final Set<Polyline> _runRoutePolylines = {};

  final SupabaseClient _supabase = Supabase.instance.client;

  // Location getters
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;
  LatLng? get currentLatLng => _currentLatLng;

  // Territories getters
  List<Territory> get territories => _territories;
  Set<Polygon> get polygons => _polygons;
  Set<Marker> get markers => _markers;
  bool get isLoadingTerritories => _isLoadingTerritories;
  String? get territoriesError => _territoriesError;

  // Navigation getters
  Territory? get selectedTerritory => _selectedTerritory;
  Set<Polyline> get routePolylines => _routePolylines;
  bool get isNavigating => _isNavigating;
  bool get isLoadingRoute => _isLoadingRoute;
  double? get distanceToDestination => _distanceToDestination;
  double? get estimatedTime => _estimatedTime;
  String? get distanceText => _distanceText;
  String? get durationText => _durationText;

  /// Check if user has arrived at start point (within 20m)
  bool get hasArrivedAtStartPoint {
    if (!_isNavigating || _selectedTerritory == null || _currentLatLng == null) {
      return false;
    }
    return isAtTerritoryStartPoint(_currentLatLng!, _selectedTerritory!);
  }

  // Run tracking getters
  RunSession? get activeRunSession => _activeRunSession;
  bool get isRunning => _isRunning;
  Set<Polyline> get runRoutePolylines => _runRoutePolylines;
  double get runDistance => _runTrackingService.totalDistance;
  int get runDuration => _runTrackingService.elapsedSeconds;
  double get currentPace => _runTrackingService.currentPace;
  double get currentSpeed => _runTrackingService.currentSpeed;

  // ==================== INITIALIZATION ====================
  Future<void> initializeLocation() async {
    if (_currentPosition != null && _territories.isNotEmpty) return;

    await Future.wait([
      getCurrentLocation(),
      loadTerritories(),
    ]);
  }

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );

      _currentLatLng = LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      AppLogger.success(LogLabel.general, 'Current location obtained');
    } catch (e) {
      AppLogger.error(LogLabel.general, 'Failed to get location', e);
      _error = e.toString();
      _currentLatLng = const LatLng(1.18376, 104.01703);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== REAL-TIME LOCATION TRACKING ====================
  void startLocationTracking() {
    AppLogger.info(LogLabel.general, 'Starting real-time location tracking');

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters (untuk avoid too many API calls)
      ),
    ).listen((Position position) {
      _currentPosition = position;
      _currentLatLng = LatLng(position.latitude, position.longitude);

      // Update route if navigating
      if (_isNavigating && _selectedTerritory != null) {
        _updateRouteRealtime();
      }

      notifyListeners();
    });
  }

  void stopLocationTracking() {
    AppLogger.info(LogLabel.general, 'Stopping location tracking');
    _positionStream?.cancel();
    _positionStream = null;
  }

  // ==================== TERRITORIES ====================
  Future<void> loadTerritories() async {
    _isLoadingTerritories = true;
    _territoriesError = null;
    notifyListeners();

    try {
      AppLogger.info(LogLabel.supabase, 'Loading territories from database');

      final response = await _supabase.from('territories').select().order('id');

      _territories = (response as List)
          .map((json) => Territory.fromJson(json))
          .toList();

      _generatePolygons();

      AppLogger.success(
          LogLabel.supabase, 'Loaded ${_territories.length} territories');
    } catch (e, stackTrace) {
      AppLogger.error(LogLabel.supabase, 'Failed to load territories', e,
          stackTrace);
      _territoriesError = 'Failed to load territories: $e';
      _territories = [];
    } finally {
      _isLoadingTerritories = false;
      notifyListeners();
    }
  }

  void _generatePolygons() {
    _polygons.clear();
    _markers.clear();

    for (var territory in _territories) {
      if (territory.points.isEmpty) continue;

      Color fillColor;
      Color strokeColor;

      // Highlight selected territory
      if (_selectedTerritory?.id == territory.id) {
        fillColor = Colors.green.withValues(alpha: 0.4);
        strokeColor = Colors.green;
      } else if (territory.isOwned) {
        fillColor = Colors.blue.withValues(alpha: 0.3);
        strokeColor = Colors.blue;
      } else {
        fillColor = Colors.grey.withValues(alpha: 0.2);
        strokeColor = Colors.grey.shade400;
      }

      final polygon = Polygon(
        polygonId: PolygonId('territory_${territory.id}'),
        points: territory.points,
        fillColor: fillColor,
        strokeColor: strokeColor,
        strokeWidth: _selectedTerritory?.id == territory.id ? 3 : 2,
        consumeTapEvents: true,
        onTap: () => selectTerritory(territory),
      );

      _polygons.add(polygon);

      // Add START POINT marker for selected territory
      if (_selectedTerritory?.id == territory.id && territory.points.isNotEmpty) {
        final startPoint = territory.points.first;
        final marker = Marker(
          markerId: MarkerId('start_${territory.id}'),
          position: startPoint,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(
            title: '🏁 START POINT',
            snippet: 'Begin your run here',
          ),
        );
        _markers.add(marker);
      }
    }
  }

  // ==================== NAVIGATION ====================
  void selectTerritory(Territory territory) {
    AppLogger.info(
        LogLabel.general, 'Territory selected: ${territory.name ?? territory.id}');

    _selectedTerritory = territory;
    _generatePolygons();
    notifyListeners();
  }

  Future<void> startNavigation(Territory territory) async {
    if (_currentLatLng == null) {
      AppLogger.warning(LogLabel.general, 'Cannot start navigation: no location');
      return;
    }

    AppLogger.info(
        LogLabel.general, 'Starting navigation to ${territory.name ?? territory.id}');

    _selectedTerritory = territory;
    _isNavigating = true;
    _isLoadingRoute = true;
    notifyListeners();

    // ✅ Navigate to START POINT (first coordinate) instead of center
    final destination = territory.points.isNotEmpty
        ? territory.points.first
        : _getCenterPoint(territory.points);

    // ✅ Fetch real route from Google Directions API
    final directionsResult = await DirectionsService.getDirections(
      origin: _currentLatLng!,
      destination: destination,
      mode: TravelMode.walking, // atau driving/bicycling
    );

    if (directionsResult != null) {
      // ✅ Use real route points (following roads!)
      _routePoints = directionsResult.polylinePoints;
      
      // ✅ Use Google's calculated distance & time
      _distanceToDestination = directionsResult.distanceValue.toDouble();
      _estimatedTime = directionsResult.durationValue / 60.0; // to minutes
      _distanceText = directionsResult.distanceText;
      _durationText = directionsResult.durationText;

      AppLogger.success(
        LogLabel.network, 
        'Route loaded: ${directionsResult.distanceText}, ${directionsResult.durationText}'
      );
    } else {
      // ❌ Fallback to straight line if API fails
      AppLogger.warning(
        LogLabel.network, 
        'Directions API failed, using straight line'
      );
      
      _routePoints = [_currentLatLng!, destination];
      _calculateRouteMetricsFallback();
    }

    _createRoutePolyline();
    _isLoadingRoute = false;

    // Start tracking
    startLocationTracking();

    _generatePolygons();
    notifyListeners();
  }

  void stopNavigation() {
    AppLogger.info(LogLabel.general, 'Navigation stopped');

    _isNavigating = false;
    _selectedTerritory = null;
    _routePoints.clear();
    _routePolylines.clear();
    _distanceToDestination = null;
    _estimatedTime = null;
    _distanceText = null;
    _durationText = null;

    stopLocationTracking();
    _generatePolygons();
    notifyListeners();
  }

  /// Update route in real-time as user moves
  Future<void> _updateRouteRealtime() async {
    if (_currentLatLng == null || _selectedTerritory == null) return;

    // ✅ Always navigate to START POINT (first coordinate)
    final destination = _selectedTerritory!.points.isNotEmpty
        ? _selectedTerritory!.points.first
        : _getCenterPoint(_selectedTerritory!.points);

    // ✅ Fetch updated route from current position
    final directionsResult = await DirectionsService.getDirections(
      origin: _currentLatLng!,
      destination: destination,
      mode: TravelMode.walking,
    );

    if (directionsResult != null) {
      _routePoints = directionsResult.polylinePoints;
      _distanceToDestination = directionsResult.distanceValue.toDouble();
      _estimatedTime = directionsResult.durationValue / 60.0;
      _distanceText = directionsResult.distanceText;
      _durationText = directionsResult.durationText;

      _createRoutePolyline();
      notifyListeners();

      AppLogger.debug(
        LogLabel.general, 
        'Route updated: ${directionsResult.distanceText} remaining'
      );
    }
  }

  void _createRoutePolyline() {
    _routePolylines.clear();

    if (_routePoints.isEmpty) return;

    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      points: _routePoints,
      color: Colors.blue,
      width: 5,
      geodesic: true,
      // ✅ Solid line for real route (looks more professional)
    );

    _routePolylines.add(polyline);
  }

  /// Fallback calculation if Directions API fails
  void _calculateRouteMetricsFallback() {
    if (_currentLatLng == null || _routePoints.length < 2) return;

    final destination = _routePoints.last;

    final distanceInMeters = Geolocator.distanceBetween(
      _currentLatLng!.latitude,
      _currentLatLng!.longitude,
      destination.latitude,
      destination.longitude,
    );

    _distanceToDestination = distanceInMeters;
    _estimatedTime = (distanceInMeters / 1000 / 5.0) * 60; // 5 km/h walking speed
    
    // Format text manually
    if (distanceInMeters < 1000) {
      _distanceText = '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      _distanceText = '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
    
    final mins = (_estimatedTime ?? 0).round();
    _durationText = '$mins min';
  }

  LatLng _getCenterPoint(List<LatLng> points) {
    if (points.isEmpty) return const LatLng(0, 0);

    double totalLat = 0;
    double totalLng = 0;

    for (var point in points) {
      totalLat += point.latitude;
      totalLng += point.longitude;
    }

    return LatLng(
      totalLat / points.length,
      totalLng / points.length,
    );
  }

  // ==================== TERRITORY HELPERS ====================
  List<Territory> getTerritoriesNear(LatLng location, double radiusInKm) {
    return _territories.where((territory) {
      if (territory.points.isEmpty) return false;

      return territory.points.any((point) {
        final distance = Geolocator.distanceBetween(
          location.latitude,
          location.longitude,
          point.latitude,
          point.longitude,
        );
        return distance <= radiusInKm * 1000;
      });
    }).toList();
  }

  List<Territory> getUnclaimedTerritoriesNear(
      LatLng location, double radiusInKm) {
    return getTerritoriesNear(location, radiusInKm)
        .where((t) => !t.isOwned)
        .toList();
  }

  Territory? getTerritoryAtLocation(LatLng location) {
    for (var territory in _territories) {
      if (_isPointInPolygon(location, territory.points)) {
        return territory;
      }
    }
    return null;
  }

  /// Check if user is at the starting point of a territory
  /// Returns true if within 20 meters of first coordinate
  bool isAtTerritoryStartPoint(LatLng userLocation, Territory territory) {
    if (territory.points.isEmpty) return false;

    final startPoint = territory.points.first;
    final distanceToStart = Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      startPoint.latitude,
      startPoint.longitude,
    );

    // User must be within 20 meters of start point
    return distanceToStart <= 20;
  }

  /// Get distance to start point for display
  double? getDistanceToStartPoint(LatLng? userLocation, Territory? territory) {
    if (userLocation == null || territory == null || territory.points.isEmpty) {
      return null;
    }

    final startPoint = territory.points.first;
    return Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      startPoint.latitude,
      startPoint.longitude,
    );
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.length < 3) return false;

    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      if ((polygon[i].longitude > point.longitude) !=
              (polygon[j].longitude > point.longitude) &&
          point.latitude <
              (polygon[j].latitude - polygon[i].latitude) *
                      (point.longitude - polygon[i].longitude) /
                      (polygon[j].longitude - polygon[i].longitude) +
                  polygon[i].latitude) {
        inside = !inside;
      }
    }
    return inside;
  }

  // ==================== STATISTICS ====================
  int get totalTerritories => _territories.length;
  int get claimedTerritories => _territories.where((t) => t.isOwned).length;
  int get unclaimedTerritories => _territories.where((t) => !t.isOwned).length;

  List<Territory> getTerritoriesByUser(String userId) {
    return _territories.where((t) => t.ownerId == userId).toList();
  }

  // ==================== RUN TRACKING ====================

  /// Start run session at current territory
  Future<bool> startRunSession() async {
    if (_currentLatLng == null || _selectedTerritory == null) {
      AppLogger.warning(LogLabel.general, 'Cannot start run: no location or territory');
      return false;
    }

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      AppLogger.warning(LogLabel.general, 'Cannot start run: no user');
      return false;
    }

    try {
      final session = await _runTrackingService.startRunSession(
        userId: userId,
        territoryId: _selectedTerritory!.id,
        startLocation: _currentLatLng!,
      );

      if (session != null) {
        _activeRunSession = session;
        _isRunning = true;

        // Stop navigation since we're now running
        stopNavigation();

        // Start updating run route visualization
        _startRunRouteUpdates();

        notifyListeners();
        return true;
      }

      return false;
    } catch (e, stackTrace) {
      AppLogger.error(LogLabel.general, 'Failed to start run session', e, stackTrace);
      return false;
    }
  }

  /// Update run route visualization periodically
  Timer? _runRouteTimer;

  void _startRunRouteUpdates() {
    _runRouteTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isRunning && _runTrackingService.recordedPoints.isNotEmpty) {
        _updateRunRoutePolyline();
        notifyListeners();
      }
    });
  }

  void _updateRunRoutePolyline() {
    _runRoutePolylines.clear();

    final points = _runTrackingService.recordedPoints;
    if (points.length < 2) return;

    final polyline = Polyline(
      polylineId: const PolylineId('run_route'),
      points: points,
      color: const Color(0xFF00E676), // Bright green for active run
      width: 6,
      geodesic: true,
    );

    _runRoutePolylines.add(polyline);
  }

  /// Pause run session
  void pauseRunSession() {
    _runTrackingService.pauseRunSession();
    notifyListeners();
  }

  /// Resume run session
  void resumeRunSession() {
    _runTrackingService.resumeRunSession();
    notifyListeners();
  }

  /// Complete run session
  Future<RunSession?> completeRunSession() async {
    if (!_isRunning || _currentLatLng == null) return null;

    try {
      final completedSession = await _runTrackingService.completeRunSession(
        endLocation: _currentLatLng!,
      );

      if (completedSession != null) {
        _activeRunSession = completedSession;
        _isRunning = false;
        _runRouteTimer?.cancel();

        // Check if user can conquer territory
        final canConquer = await _checkTerritoryConquest(completedSession);

        if (canConquer) {
          _activeRunSession = completedSession.copyWith(
            territoryConquered: true,
          );
        }

        // Reload territories to reflect ownership changes
        await loadTerritories();

        notifyListeners();
        return _activeRunSession;
      }

      return null;
    } catch (e, stackTrace) {
      AppLogger.error(LogLabel.general, 'Failed to complete run', e, stackTrace);
      return null;
    }
  }

  /// Check if user conquered territory with this run
  Future<bool> _checkTerritoryConquest(RunSession newRun) async {
    try {
      // Get current best run for territory
      final currentBestRun = await _runTrackingService.getBestRunForTerritory(
        territoryId: newRun.territoryId,
      );

      final canConquer = await _runTrackingService.canConquerTerritory(
        newRun: newRun,
        currentBestRun: currentBestRun,
      );

      if (canConquer) {
        // Update territory ownership
        await _runTrackingService.updateTerritoryOwnership(
          territoryId: newRun.territoryId,
          newOwnerId: newRun.userId,
          previousOwnerId: currentBestRun?.userId,
        );

        AppLogger.success(
          LogLabel.general,
          '🏆 Territory conquered! Pace: ${newRun.formattedPace}',
        );

        return true;
      }

      return false;
    } catch (e, stackTrace) {
      AppLogger.error(
        LogLabel.general,
        'Failed to check territory conquest',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Cancel run session
  void cancelRunSession() {
    _runTrackingService.cancelRunSession();
    _activeRunSession = null;
    _isRunning = false;
    _runRouteTimer?.cancel();
    _runRoutePolylines.clear();
    notifyListeners();
  }

  /// Get leaderboard for current territory
  Future<List<RunSession>> getTerritoryLeaderboard() async {
    if (_selectedTerritory == null) return [];

    return await _runTrackingService.getTerritoryLeaderboard(
      territoryId: _selectedTerritory!.id,
    );
  }

  @override
  void dispose() {
    stopLocationTracking();
    _runTrackingService.dispose();
    _runRouteTimer?.cancel();
    super.dispose();
  }
}