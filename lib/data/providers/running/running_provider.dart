import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

import '../../model/territory/territory_model.dart';

class RunningProvider extends ChangeNotifier {
  // Location properties
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;
  LatLng? _currentLatLng;

  // Territories properties
  List<Territory> _territories = [];
  Set<Polygon> _polygons = {};
  bool _isLoadingTerritories = false;
  String? _territoriesError;

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

  // Inisialisasi location saat app start
  Future<void> initializeLocation() async {
    if (_currentPosition != null && _territories.isNotEmpty) return;

    // Load location dan territories secara parallel untuk performa lebih cepat
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
      // Check permission
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

      // Check if location service enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Get current position dengan accuracy tinggi tapi timeout cepat
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5), // Timeout 5 detik
      );

      _currentLatLng = LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
    } catch (e) {
      _error = e.toString();
      // Fallback ke default location (Batam)
      _currentLatLng = const LatLng(1.18376, 104.01703);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update location di background (optional)
  void startLocationUpdates() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update setiap 10 meter
      ),
    ).listen((Position position) {
      _currentPosition = position;
      _currentLatLng = LatLng(position.latitude, position.longitude);
      notifyListeners();
    });
  }

  // ==================== TERRITORIES FUNCTIONS ====================

  // Load territories dari Supabase
  Future<void> loadTerritories() async {
    _isLoadingTerritories = true;
    _territoriesError = null;
    notifyListeners();

    try {
      debugPrint('🔄 Loading territories from Supabase...');

      final response = await _supabase.from('territories').select().order('id');

      debugPrint('📦 Raw response: $response');
      debugPrint('📦 Response type: ${response.runtimeType}');

      if (response == null) {
        debugPrint('⚠️ Response is null');
        _territories = [];
      } else if (response is List) {
        debugPrint('📋 Response is List with ${response.length} items');

        _territories = response.map((json) {
          debugPrint('🔍 Parsing territory: $json');
          return Territory.fromJson(json as Map<String, dynamic>);
        }).toList();
      } else {
        debugPrint('⚠️ Unexpected response type: ${response.runtimeType}');
        _territories = [];
      }

      // Generate polygons untuk ditampilkan di map
      _generatePolygons();

      debugPrint('✅ Loaded ${_territories.length} territories');
      if (_territories.isNotEmpty) {
        debugPrint(
            '📍 First territory: ${_territories.first.name}, Points: ${_territories.first.points.length}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading territories: $e');
      debugPrint('Stack trace: $stackTrace');
      _territoriesError = 'Failed to load territories: $e';
      _territories = [];
    } finally {
      _isLoadingTerritories = false;
      notifyListeners();
    }
  }

  // Generate polygons dari territories
  void _generatePolygons() {
    _polygons.clear();

    for (var territory in _territories) {
      if (territory.points.isEmpty) continue;

      // Tentukan warna berdasarkan ownership
      Color fillColor;
      Color strokeColor;

      if (territory.isOwned) {
        // Territory yang sudah dikuasai - biru
        fillColor = Colors.blue.withOpacity(0.3);
        strokeColor = Colors.blue;
      } else {
        // Territory kosong - abu-abu
        fillColor = Colors.grey.withOpacity(0.2);
        strokeColor = Colors.grey.shade400;
      }

      final polygon = Polygon(
        polygonId: PolygonId('territory_${territory.id}'),
        points: territory.points,
        fillColor: fillColor,
        strokeColor: strokeColor,
        strokeWidth: 2,
        consumeTapEvents: true,
        onTap: () {
          _onTerritoryTap(territory);
        },
      );

      _polygons.add(polygon);
    }

    debugPrint('✅ Generated ${_polygons.length} polygons');
  }

  // Handle territory tap
  void _onTerritoryTap(Territory territory) {
    debugPrint(
        '🎯 Territory tapped: ${territory.name ?? "Territory #${territory.id}"}');
    debugPrint('   Owner: ${territory.ownerId ?? "Unclaimed"}');
    debugPrint('   Region: ${territory.region ?? "Unknown"}');
    // TODO: Show bottom sheet dengan info territory
    // TODO: Tambahkan logic untuk claim territory
  }

  // Update territory ownership (claim territory)
  Future<bool> claimTerritory(int territoryId, String userId) async {
    try {
      await _supabase
          .from('territories')
          .update({'owner_id': userId}).eq('id', territoryId);

      // Reload territories untuk update UI
      await loadTerritories();

      debugPrint('✅ Territory $territoryId claimed by $userId');
      return true;
    } catch (e) {
      debugPrint('❌ Error claiming territory: $e');
      return false;
    }
  }

  // Get territories near location (dalam radius tertentu)
  List<Territory> getTerritoriesNear(LatLng location, double radiusInKm) {
    return _territories.where((territory) {
      if (territory.points.isEmpty) return false;

      // Check if any point in territory is within radius
      return territory.points.any((point) {
        final distance = Geolocator.distanceBetween(
          location.latitude,
          location.longitude,
          point.latitude,
          point.longitude,
        );
        return distance <= radiusInKm * 1000; // Convert km to meters
      });
    }).toList();
  }

  // Get unclaimed territories near location
  List<Territory> getUnclaimedTerritoriesNear(
      LatLng location, double radiusInKm) {
    return getTerritoriesNear(location, radiusInKm)
        .where((t) => !t.isOwned)
        .toList();
  }

  // Check if user is inside a territory
  Territory? getTerritoryAtLocation(LatLng location) {
    for (var territory in _territories) {
      if (_isPointInPolygon(location, territory.points)) {
        return territory;
      }
    }
    return null;
  }

  // Helper: Check if point is inside polygon (Ray Casting Algorithm)
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

  // Get statistics
  int get totalTerritories => _territories.length;
  int get claimedTerritories => _territories.where((t) => t.isOwned).length;
  int get unclaimedTerritories => _territories.where((t) => !t.isOwned).length;

  // Get territories by user
  List<Territory> getTerritoriesByUser(String userId) {
    return _territories.where((t) => t.ownerId == userId).toList();
  }
}
