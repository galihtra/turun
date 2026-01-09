import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapHelper {
  /// Calculate bounds to show both current location and destination
  static LatLngBounds calculateBounds(LatLng point1, LatLng point2) {
    final southwest = LatLng(
      point1.latitude < point2.latitude ? point1.latitude : point2.latitude,
      point1.longitude < point2.longitude ? point1.longitude : point2.longitude,
    );

    final northeast = LatLng(
      point1.latitude > point2.latitude ? point1.latitude : point2.latitude,
      point1.longitude > point2.longitude ? point1.longitude : point2.longitude,
    );

    return LatLngBounds(southwest: southwest, northeast: northeast);
  }

  /// Calculate center of a list of points
  static LatLng? calculateCenter(List<LatLng> points) {
    if (points.isEmpty) return null;

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
}
