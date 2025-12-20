import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../model/territory/territory_model.dart';
import '../../services/territory_leaderboard_service.dart';

class TerritoryLeaderboardProvider with ChangeNotifier {
  final TerritoryLeaderboardService _service = TerritoryLeaderboardService();

  // State variables
  List<Territory> _territories = [];
  List<Territory> _filteredTerritories = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  LatLng? _userLocation;
  double _currentZoom = 14.0;
  GoogleMapController? _mapController;

  // Getters
  List<Territory> get territories => _filteredTerritories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  LatLng? get userLocation => _userLocation;
  double get currentZoom => _currentZoom;

  /// Initialize provider - load territories and get user location
  Future<void> initialize() async {
    await Future.wait([
      loadTerritories(),
      getUserLocation(),
    ]);
  }

  /// Load all territories from Supabase
  Future<void> loadTerritories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _territories = await _service.getAllTerritories();
      _filteredTerritories = List.from(_territories);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load territories: $e';
      notifyListeners();
    }
  }

  /// Search territories by name
  Future<void> searchTerritories(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredTerritories = List.from(_territories);
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _filteredTerritories = await _service.searchTerritories(query);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to search territories: $e';
      notifyListeners();
    }
  }

  /// Clear search and show all territories
  void clearSearch() {
    _searchQuery = '';
    _filteredTerritories = List.from(_territories);
    notifyListeners();
  }

  /// Get user's current location
  Future<void> getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _userLocation = const LatLng(1.18376, 104.01703); // Default location
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _userLocation = const LatLng(1.18376, 104.01703); // Default location
        notifyListeners();
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _userLocation = LatLng(position.latitude, position.longitude);
      notifyListeners();
    } catch (e) {
      print('Error getting user location: $e');
      _userLocation = const LatLng(1.18376, 104.01703); // Default location
      notifyListeners();
    }
  }

  /// Set map controller
  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  /// Zoom in
  Future<void> zoomIn() async {
    if (_mapController == null) return;

    _currentZoom = (_currentZoom + 1).clamp(0, 21);
    await _mapController!.animateCamera(
      CameraUpdate.zoomTo(_currentZoom),
    );
    notifyListeners();
  }

  /// Zoom out
  Future<void> zoomOut() async {
    if (_mapController == null) return;

    _currentZoom = (_currentZoom - 1).clamp(0, 21);
    await _mapController!.animateCamera(
      CameraUpdate.zoomTo(_currentZoom),
    );
    notifyListeners();
  }

  /// Recenter map to user location
  Future<void> recenterMap() async {
    if (_mapController == null || _userLocation == null) return;

    await _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(_userLocation!, 17.0),
    );
    _currentZoom = 17.0;
    notifyListeners();
  }

  /// Move camera to territory
  Future<void> moveToTerritory(Territory territory) async {
    if (_mapController == null || territory.points.isEmpty) return;

    // Calculate center of territory
    double sumLat = 0;
    double sumLng = 0;
    for (final point in territory.points) {
      sumLat += point.latitude;
      sumLng += point.longitude;
    }
    final center = LatLng(
      sumLat / territory.points.length,
      sumLng / territory.points.length,
    );

    await _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(center, 17.0),
    );
    _currentZoom = 17.0;
    notifyListeners();
  }

  /// Calculate distance from user to territory (in km)
  double? getDistanceToTerritory(Territory territory) {
    if (_userLocation == null || territory.points.isEmpty) return null;

    // Calculate center of territory
    double sumLat = 0;
    double sumLng = 0;
    for (final point in territory.points) {
      sumLat += point.latitude;
      sumLng += point.longitude;
    }
    final center = LatLng(
      sumLat / territory.points.length,
      sumLng / territory.points.length,
    );

    // Calculate distance in meters, then convert to km
    final distanceInMeters = Geolocator.distanceBetween(
      _userLocation!.latitude,
      _userLocation!.longitude,
      center.latitude,
      center.longitude,
    );

    return distanceInMeters / 1000;
  }

  /// Dispose
  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
