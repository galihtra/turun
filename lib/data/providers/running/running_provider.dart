import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turun/app/app_logger.dart';

import '../../model/territory/territory_model.dart';
import '../../services/directions_service.dart';

class RunningProvider extends ChangeNotifier {
  // Location properties
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;
  LatLng? _currentLatLng;
  StreamSubscription<Position>? _positionStream;

  // Territories properties
  List<Territory> _territories = [];
  Set<Polygon> _polygons = {};
  bool _isLoadingTerritories = false;
  String? _territoriesError;

  // Navigation properties
  Territory? _selectedTerritory;
  Set<Polyline> _routePolylines = {};
  List<LatLng> _routePoints = [];
  bool _isNavigating = false;
  bool _isLoadingRoute = false;
  double? _distanceToDestination;
  double? _estimatedTime;
  String? _distanceText;
  String? _durationText;

  final SupabaseClient _supabase = Supabase.instance.client;

  // Location getters
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;
  LatLng? get currentLatLng => _currentLatLng;

  // Territories getters
  List<Territory> get territories => _territories;
  Set<Polygon> get polygons => _polygons;
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
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
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

      if (response == null) {
        _territories = [];
      } else if (response is List) {
        _territories = response.map((json) {
          return Territory.fromJson(json as Map<String, dynamic>);
        }).toList();
      } else {
        _territories = [];
      }

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

    for (var territory in _territories) {
      if (territory.points.isEmpty) continue;

      Color fillColor;
      Color strokeColor;

      // Highlight selected territory
      if (_selectedTerritory?.id == territory.id) {
        fillColor = Colors.green.withOpacity(0.4);
        strokeColor = Colors.green;
      } else if (territory.isOwned) {
        fillColor = Colors.blue.withOpacity(0.3);
        strokeColor = Colors.blue;
      } else {
        fillColor = Colors.grey.withOpacity(0.2);
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

    // Get center point of territory
    final destination = _getCenterPoint(territory.points);

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

    final destination = _getCenterPoint(_selectedTerritory!.points);

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

  @override
  void dispose() {
    stopLocationTracking();
    super.dispose();
  }
}