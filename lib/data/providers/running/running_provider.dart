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
import '../../../utils/custom_marker_helper.dart';

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
  final Set<Polyline> _territoryGuidancePolylines = {};
  final Set<Marker> _runMarkers = {};
  int _currentCheckpointIndex = 0;
  bool _hasLeftStartPoint = false;
  DateTime? _lastFinishLogTime;
  bool _runCompleted = false; // ✅ NEW: Flag to prevent multiple completions

  // ✅ NEW: GPS stream specifically for running
  StreamSubscription<Position>? _runGpsStream;

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
  Set<Polyline> get territoryGuidancePolylines => _territoryGuidancePolylines;
  Set<Marker> get runMarkers => _runMarkers;
  int get currentCheckpointIndex => _currentCheckpointIndex;
  double get runDistance => _runTrackingService.totalDistance;
  int get runDuration => _runTrackingService.elapsedSeconds;
  double get currentPace => _runTrackingService.currentPace;
  double get currentSpeed => _runTrackingService.currentSpeed;
  bool get runCompleted => _runCompleted; // ✅ NEW: Expose completion flag

  /// Get progress percentage through territory route
  double get routeProgress {
    if (_selectedTerritory == null || _selectedTerritory!.points.isEmpty) return 0;
    
    final totalCoins = _selectedTerritory!.points.length - 1;
    if (totalCoins <= 0) return 0;
    
    final coinsCollected = (_currentCheckpointIndex - 1).clamp(0, totalCoins);
    
    return (coinsCollected / totalCoins) * 100;
  }

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
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _currentPosition = position;
      _currentLatLng = LatLng(position.latitude, position.longitude);

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

  // ==================== GPS TRACKING FOR RUNNING ====================
  /// ✅ NEW: Start dedicated GPS tracking for run with checkpoint detection
  void _startRunGpsTracking() {
    AppLogger.info(LogLabel.general, '🏃 Starting GPS tracking for run...');

    _runGpsStream?.cancel(); // Cancel any existing stream

    _runGpsStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 3, // Update every 3 meters for accurate checkpoint detection
      ),
    ).listen(
      (Position position) {
        if (!_isRunning || _runCompleted) return;

        // Update current location
        _currentPosition = position;
        _currentLatLng = LatLng(position.latitude, position.longitude);

        AppLogger.debug(
          LogLabel.general,
          '📍 GPS Update: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
        );

        // ✅ Check checkpoint progress with new location
        _checkCheckpointProgressSync();

        notifyListeners();
      },
      onError: (error) {
        AppLogger.error(LogLabel.general, 'GPS tracking error during run', error);
      },
    );
  }

  /// ✅ NEW: Stop GPS tracking for run
  void _stopRunGpsTracking() {
    AppLogger.info(LogLabel.general, '🛑 Stopping run GPS tracking');
    _runGpsStream?.cancel();
    _runGpsStream = null;
  }

  // ==================== TERRITORIES ====================
  Future<void> loadTerritories() async {
    _isLoadingTerritories = true;
    _territoriesError = null;
    notifyListeners();

    try {
      AppLogger.info(LogLabel.supabase, 'Loading territories from database');

      // Fetch territories (owner_color already stored in territories table)
      final response = await _supabase
          .from('territories')
          .select()
          .order('id');

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

      if (_selectedTerritory?.id == territory.id) {
        fillColor = Colors.green.withOpacity(0.3);
        strokeColor = Colors.green;
      } else if (territory.isOwned) {
        // Use owner's profile color if available
        if (territory.ownerColor != null) {
          final ownerColor = _colorFromHex(territory.ownerColor!);
          fillColor = ownerColor.withOpacity(0.3);
          strokeColor = ownerColor;
        } else {
          // Fallback to blue if no color specified
          fillColor = Colors.blue.withOpacity(0.2);
          strokeColor = Colors.blue;
        }
      } else {
        fillColor = Colors.grey.withOpacity(0.15);
        strokeColor = Colors.grey.shade400;
      }

      final polygon = Polygon(
        polygonId: PolygonId('territory_${territory.id}'),
        points: territory.points,
        fillColor: fillColor,
        strokeColor: strokeColor,
        strokeWidth: _selectedTerritory?.id == territory.id ? 4 : 2,
        consumeTapEvents: true,
        onTap: () => selectTerritory(territory),
      );

      _polygons.add(polygon);

      if (_selectedTerritory?.id == territory.id &&
          territory.points.isNotEmpty &&
          !_isRunning) {
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

    final destination = territory.points.isNotEmpty
        ? territory.points.first
        : _getCenterPoint(territory.points);

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

      AppLogger.success(
        LogLabel.network, 
        'Route loaded: ${directionsResult.distanceText}, ${directionsResult.durationText}'
      );
    } else {
      AppLogger.warning(
        LogLabel.network, 
        'Directions API failed, using straight line'
      );
      
      _routePoints = [_currentLatLng!, destination];
      _calculateRouteMetricsFallback();
    }

    _createRoutePolyline();
    _isLoadingRoute = false;

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

  void _stopNavigationKeepTerritory() {
    AppLogger.info(LogLabel.general, 'Navigation stopped (keeping territory for run)');

    _isNavigating = false;
    _routePoints.clear();
    _routePolylines.clear();
    _distanceToDestination = null;
    _estimatedTime = null;
    _distanceText = null;
    _durationText = null;

    stopLocationTracking();
    _generatePolygons();
  }

  Future<void> _updateRouteRealtime() async {
    if (_currentLatLng == null || _selectedTerritory == null) return;

    final destination = _selectedTerritory!.points.isNotEmpty
        ? _selectedTerritory!.points.first
        : _getCenterPoint(_selectedTerritory!.points);

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
    );

    _routePolylines.add(polyline);
  }

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
    _estimatedTime = (distanceInMeters / 1000 / 5.0) * 60;
    
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

  bool isAtTerritoryStartPoint(LatLng userLocation, Territory territory) {
    if (territory.points.isEmpty) return false;

    final startPoint = territory.points.first;
    final distanceToStart = Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      startPoint.latitude,
      startPoint.longitude,
    );

    return distanceToStart <= 20;
  }

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

  /// Convert hex color string to Color object
  /// Supports formats: #RRGGBB, #AARRGGBB, RRGGBB, AARRGGBB
  Color _colorFromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));

    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      // Return blue as fallback if parsing fails
      AppLogger.warning(LogLabel.general, 'Failed to parse color: $hexString, using blue fallback');
      return Colors.blue;
    }
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

        // ✅ Reset ALL checkpoint progress flags
        _currentCheckpointIndex = 1;
        _hasLeftStartPoint = false;
        _lastFinishLogTime = null;
        _runCompleted = false; // ✅ CRITICAL: Reset completion flag

        AppLogger.info(LogLabel.general, '🚀 Run session initialized');
        AppLogger.info(LogLabel.general, '   - Territory: ${_selectedTerritory!.name}');
        AppLogger.info(LogLabel.general, '   - Total points: ${_selectedTerritory!.points.length}');
        AppLogger.info(LogLabel.general, '   - Total coins to collect: ${_selectedTerritory!.points.length - 1}');
        AppLogger.info(LogLabel.general, '   - Starting checkpoint index: $_currentCheckpointIndex');

        // Create markers BEFORE stopping navigation
        await _startRunRouteUpdates();

        // Stop navigation but keep territory
        _stopNavigationKeepTerritory();

        // ✅ START DEDICATED GPS TRACKING FOR RUN
        _startRunGpsTracking();

        notifyListeners();

        AppLogger.success(
          LogLabel.general,
          '✅ Run started with ${_runMarkers.length} markers visible',
        );

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

  Future<void> _startRunRouteUpdates() async {
    AppLogger.info(LogLabel.general, '🚀 _startRunRouteUpdates() START');
    AppLogger.info(LogLabel.general, '   Current markers before: ${_runMarkers.length}');

    await _createTerritoryGuidanceRoute();

    AppLogger.info(LogLabel.general, '   Current markers after: ${_runMarkers.length}');
    AppLogger.success(LogLabel.general, '🚀 _startRunRouteUpdates() COMPLETE');

    // Timer for UI updates only (checkpoint detection is handled by GPS stream)
    _runRouteTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRunning && !_runCompleted) {
        _updateRunRoutePolyline();
        notifyListeners();
      }
    });
  }

  /// Create guidance polyline showing territory route to follow
  Future<void> _createTerritoryGuidanceRoute() async {
    AppLogger.info(LogLabel.general, '🗺️ _createTerritoryGuidanceRoute() START');

    _territoryGuidancePolylines.clear();

    if (_selectedTerritory == null || _selectedTerritory!.points.isEmpty) {
      AppLogger.warning(LogLabel.general, '❌ No territory or empty points in guidance route!');
      return;
    }

    AppLogger.info(LogLabel.general, '   Territory: ${_selectedTerritory!.name}');
    AppLogger.info(LogLabel.general, '   Points count: ${_selectedTerritory!.points.length}');
    AppLogger.info(LogLabel.general, '   Current checkpoint index: $_currentCheckpointIndex');

    final points = _selectedTerritory!.points;
    
    // Create REMAINING route
    final List<LatLng> remainingRoutePoints = [];
    
    final startIndex = _currentCheckpointIndex.clamp(0, points.length - 1);
    for (int i = startIndex; i < points.length; i++) {
      remainingRoutePoints.add(points[i]);
    }
    remainingRoutePoints.add(points.first);
    
    if (remainingRoutePoints.length >= 2) {
      final remainingPolyline = Polyline(
        polylineId: const PolylineId('remaining_route'),
        points: remainingRoutePoints,
        color: Colors.blue.withOpacity(0.7),
        width: 6,
        geodesic: true,
        patterns: [
          PatternItem.dash(20),
          PatternItem.gap(10),
        ],
      );
      _territoryGuidancePolylines.add(remainingPolyline);
    }

    // Create NEXT CHECKPOINT indicator
    if (_currentLatLng != null && _currentCheckpointIndex < points.length) {
      final nextCheckpoint = points[_currentCheckpointIndex.clamp(0, points.length - 1)];
      final nextCheckpointLine = Polyline(
        polylineId: const PolylineId('next_checkpoint_line'),
        points: [_currentLatLng!, nextCheckpoint],
        color: Colors.orange,
        width: 4,
        geodesic: true,
        patterns: [
          PatternItem.dash(10),
          PatternItem.gap(5),
        ],
      );
      _territoryGuidancePolylines.add(nextCheckpointLine);
      AppLogger.info(LogLabel.general, '   ✅ Next checkpoint line created');
    }
    
    AppLogger.info(LogLabel.general, '   ✅ Guidance polylines created');

    AppLogger.info(LogLabel.general, '   Calling _createCheckpointMarkers()...');
    await _createCheckpointMarkers();

    AppLogger.success(
      LogLabel.general,
      '🗺️ _createTerritoryGuidanceRoute() COMPLETE: ${_runMarkers.length} markers ready',
    );
  }

  /// Create markers for each checkpoint in territory
  Future<void> _createCheckpointMarkers() async {
    AppLogger.info(LogLabel.general, '🔨 _createCheckpointMarkers() START');
    AppLogger.info(LogLabel.general, '   Territory: ${_selectedTerritory?.name}');
    AppLogger.info(LogLabel.general, '   Points: ${_selectedTerritory?.points.length}');

    _runMarkers.clear();

    if (_selectedTerritory == null || _selectedTerritory!.points.isEmpty) {
      AppLogger.warning(LogLabel.general, '❌ No territory or empty points!');
      return;
    }

    final points = _selectedTerritory!.points;
    final totalCoins = points.length - 1;
    final hasCompletedAllCheckpoints = _currentCheckpointIndex > totalCoins;
    
    AppLogger.info(LogLabel.general, '📍 Creating markers for ${points.length} points...');
    AppLogger.info(LogLabel.general, '   Current checkpoint: $_currentCheckpointIndex');
    AppLogger.info(LogLabel.general, '   Total coins: $totalCoins');
    AppLogger.info(LogLabel.general, '   All checkpoints completed: $hasCompletedAllCheckpoints');

    // START/FINISH marker at first position
    if (hasCompletedAllCheckpoints) {
      AppLogger.info(LogLabel.general, '   Creating FINISH marker (completed!)...');
      final finishIcon = await CustomMarkerHelper.createFinishMarker();
      final finishMarker = Marker(
        markerId: const MarkerId('start_finish_point'),
        position: points.first,
        icon: finishIcon,
        infoWindow: const InfoWindow(
          title: '🏆 FINISH',
          snippet: 'Return here to complete!',
        ),
      );
      _runMarkers.add(finishMarker);
      AppLogger.info(LogLabel.general, '   ✅ FINISH marker created');
    } else {
      AppLogger.info(LogLabel.general, '   Creating START marker...');
      final startIcon = await CustomMarkerHelper.createStartMarker();
      final startMarker = Marker(
        markerId: const MarkerId('start_finish_point'),
        position: points.first,
        icon: startIcon,
        infoWindow: const InfoWindow(
          title: '🏁 START / FINISH',
          snippet: 'Collect all coins and return here',
        ),
      );
      _runMarkers.add(startMarker);
      AppLogger.info(LogLabel.general, '   ✅ START marker created');
    }

    // Checkpoint coins (skip index 0, only show uncollected)
    for (int i = 1; i < points.length; i++) {
      if (i < _currentCheckpointIndex) {
        AppLogger.debug(LogLabel.general, '   ⏭️ Coin $i already collected, skipping');
        continue;
      }
      
      AppLogger.debug(LogLabel.general, '   Creating Coin $i...');
      final coinIcon = await CustomMarkerHelper.createCheckpointCoin(i);

      final marker = Marker(
        markerId: MarkerId('checkpoint_$i'),
        position: points[i],
        icon: coinIcon,
        infoWindow: InfoWindow(
          title: 'Checkpoint $i',
          snippet: '${(i / points.length * 100).toStringAsFixed(0)}% complete',
        ),
      );

      _runMarkers.add(marker);
    }

    AppLogger.success(
      LogLabel.general,
      '🔨 _createCheckpointMarkers() COMPLETE: ${_runMarkers.length} markers created',
    );
  }

  /// ✅ NEW: Synchronous checkpoint check called from GPS stream
  void _checkCheckpointProgressSync() {
    if (_currentLatLng == null || _selectedTerritory == null) return;
    if (!_isRunning || _runCompleted) return;

    final points = _selectedTerritory!.points;
    if (points.isEmpty) return;
    
    final startPoint = points.first;
    final totalCoins = points.length - 1;
    
    // Calculate distance to START point
    final distanceToStart = Geolocator.distanceBetween(
      _currentLatLng!.latitude,
      _currentLatLng!.longitude,
      startPoint.latitude,
      startPoint.longitude,
    );
    
    // STEP 1: Detect when user has LEFT the start area (more than 30m away)
    if (!_hasLeftStartPoint && distanceToStart > 30) {
      _hasLeftStartPoint = true;
      AppLogger.info(LogLabel.general, '🚀 User left START area (${distanceToStart.toStringAsFixed(0)}m away)');
    }
    
    // STEP 2: Check for coin collection
    if (_currentCheckpointIndex >= 1 && _currentCheckpointIndex <= totalCoins) {
      final nextCoinIndex = _currentCheckpointIndex;
      final coinPosition = points[nextCoinIndex];
      
      final distanceToCoin = Geolocator.distanceBetween(
        _currentLatLng!.latitude,
        _currentLatLng!.longitude,
        coinPosition.latitude,
        coinPosition.longitude,
      );
      
      AppLogger.debug(
        LogLabel.general,
        '📏 Distance to coin $nextCoinIndex: ${distanceToCoin.toStringAsFixed(1)}m',
      );
      
      // Within 25 meters = coin collected
      if (distanceToCoin <= 25) {
        AppLogger.success(
          LogLabel.general,
          '🪙 COIN $nextCoinIndex COLLECTED! (${distanceToCoin.toStringAsFixed(0)}m)',
        );

        _currentCheckpointIndex++;

        // Refresh markers asynchronously
        _refreshMarkersAsync();

        AppLogger.info(
          LogLabel.general,
          '📊 Progress: ${routeProgress.toStringAsFixed(0)}% (${_currentCheckpointIndex - 1}/$totalCoins coins)',
        );
      }
    }
    
    // STEP 3: Check for FINISH
    final allCoinsCollected = _currentCheckpointIndex > totalCoins;
    
    if (allCoinsCollected && _hasLeftStartPoint && !_runCompleted) {
      if (distanceToStart <= 25) {
        AppLogger.success(LogLabel.general, '🏆 FINISH! All coins collected and returned to START!');
        
        // ✅ Set completion flag IMMEDIATELY to prevent multiple triggers
        _runCompleted = true;
        
        // Trigger async completion
        _handleAutoFinish();
      } else {
        // Log distance to finish (throttled)
        final now = DateTime.now();
        if (_lastFinishLogTime == null || now.difference(_lastFinishLogTime!) > const Duration(seconds: 2)) {
          _lastFinishLogTime = now;
          AppLogger.info(
            LogLabel.general,
            '📍 All coins collected! Return to START to finish (${distanceToStart.toStringAsFixed(0)}m away)',
          );
        }
      }
    }
  }

  /// Refresh markers asynchronously after coin collection
  Future<void> _refreshMarkersAsync() async {
    await _createCheckpointMarkers();
    await _updateGuidanceRoute();
    notifyListeners();
  }

  /// Update guidance route after checkpoint collected
  Future<void> _updateGuidanceRoute() async {
    if (_selectedTerritory == null || _selectedTerritory!.points.isEmpty) return;

    _territoryGuidancePolylines.clear();
    
    final points = _selectedTerritory!.points;
    final totalCoins = points.length - 1;
    final allCoinsCollected = _currentCheckpointIndex > totalCoins;

    if (allCoinsCollected) {
      // Show route back to START
      if (_currentLatLng != null) {
        final returnRoute = Polyline(
          polylineId: const PolylineId('return_to_start'),
          points: [_currentLatLng!, points.first],
          color: Colors.green,
          width: 6,
          geodesic: true,
          patterns: [
            PatternItem.dash(15),
            PatternItem.gap(8),
          ],
        );
        _territoryGuidancePolylines.add(returnRoute);
      }
    } else {
      // Show remaining route
      final List<LatLng> remainingRoutePoints = [];
      final startIndex = _currentCheckpointIndex.clamp(0, points.length - 1);
      
      for (int i = startIndex; i < points.length; i++) {
        remainingRoutePoints.add(points[i]);
      }
      remainingRoutePoints.add(points.first);
      
      if (remainingRoutePoints.length >= 2) {
        final remainingPolyline = Polyline(
          polylineId: const PolylineId('remaining_route'),
          points: remainingRoutePoints,
          color: Colors.blue.withOpacity(0.7),
          width: 6,
          geodesic: true,
          patterns: [
            PatternItem.dash(20),
            PatternItem.gap(10),
          ],
        );
        _territoryGuidancePolylines.add(remainingPolyline);
      }

      // Next checkpoint line
      if (_currentLatLng != null && _currentCheckpointIndex < points.length) {
        final nextCheckpoint = points[_currentCheckpointIndex];
        final nextCheckpointLine = Polyline(
          polylineId: const PolylineId('next_checkpoint_line'),
          points: [_currentLatLng!, nextCheckpoint],
          color: Colors.orange,
          width: 4,
          geodesic: true,
          patterns: [
            PatternItem.dash(10),
            PatternItem.gap(5),
          ],
        );
        _territoryGuidancePolylines.add(nextCheckpointLine);
      }
    }
  }

  /// Handle auto finish when all checkpoints completed
  Future<void> _handleAutoFinish() async {
    AppLogger.info(LogLabel.general, '🎯 Auto-finishing run...');

    // Update markers to show FINISH trophy
    await _createCheckpointMarkers();
    notifyListeners();

    // Small delay to let user see the trophy
    await Future.delayed(const Duration(milliseconds: 500));

    // Complete the run session
    final session = await completeRunSession();
    if (session != null) {
      AppLogger.success(LogLabel.general, '✅ Run session auto-completed successfully!');
    }
  }

  void _updateRunRoutePolyline() {
    _runRoutePolylines.clear();

    final points = _runTrackingService.recordedPoints;
    if (points.length < 2) return;

    final polyline = Polyline(
      polylineId: const PolylineId('run_route'),
      points: points,
      color: const Color(0xFF00E676),
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
      // Stop tracking
      _stopRunGpsTracking();
      _runRouteTimer?.cancel();

      final completedSession = await _runTrackingService.completeRunSession(
        endLocation: _currentLatLng!,
      );

      if (completedSession != null) {
        _activeRunSession = completedSession;
        _isRunning = false;
        
        // Clean up run-specific visuals
        _runRoutePolylines.clear();
        _territoryGuidancePolylines.clear();
        _runMarkers.clear();
        _currentCheckpointIndex = 1;
        _hasLeftStartPoint = false;

        // Check if user can conquer territory
        final canConquer = await _checkTerritoryConquest(completedSession);

        if (canConquer) {
          _activeRunSession = completedSession.copyWith(
            territoryConquered: true,
          );
        }

        // Clear territory after processing conquest
        _selectedTerritory = null;

        // Reload territories
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
      AppLogger.info(LogLabel.general, '🔍 Checking territory conquest for run ${newRun.id}...');

      // Get best run EXCLUDING the current run
      final currentBestRun = await _runTrackingService.getBestRunForTerritory(
        territoryId: newRun.territoryId,
        excludeRunId: newRun.id, // Exclude current run from comparison
      );

      final canConquer = await _runTrackingService.canConquerTerritory(
        newRun: newRun,
        currentBestRun: currentBestRun,
      );

      if (canConquer) {
        AppLogger.info(LogLabel.general, '✅ Can conquer! Updating territory ownership...');

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

      AppLogger.info(LogLabel.general, '❌ Cannot conquer territory');
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
    _stopRunGpsTracking();
    _activeRunSession = null;
    _isRunning = false;
    _runCompleted = false;
    _runRouteTimer?.cancel();
    _runRoutePolylines.clear();
    _territoryGuidancePolylines.clear();
    _runMarkers.clear();
    _currentCheckpointIndex = 1;
    _hasLeftStartPoint = false;
    _selectedTerritory = null;
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
    _stopRunGpsTracking();
    _runTrackingService.dispose();
    _runRouteTimer?.cancel();
    super.dispose();
  }
}