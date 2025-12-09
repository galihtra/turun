import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:turun/app/app_logger.dart';

class DirectionsService {
  // ✅ Replace with your Google Maps API Key
  static const String _apiKey = 'AIzaSyCwKZBR34ZCyH75mwUxNOKGXf7ZUWuIA-c';
  
  static const String _baseUrl = 
      'https://maps.googleapis.com/maps/api/directions/json';
   

  /// Get directions route from origin to destination
  /// Returns list of LatLng points that follow roads
  static Future<DirectionsResult?> getDirections({
    required LatLng origin,
    required LatLng destination,
    TravelMode mode = TravelMode.walking,
  }) async {
    try {
      AppLogger.info(LogLabel.network, 'Fetching directions from Google API');
      
      final url = Uri.parse(_baseUrl).replace(queryParameters: {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'mode': mode.value,
        'key': _apiKey,
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          AppLogger.success(LogLabel.network, 'Directions fetched successfully');
          return DirectionsResult.fromJson(data);
        } else {
          AppLogger.error(
            LogLabel.network, 
            'Directions API error: ${data['status']}'
          );
          return null;
        }
      } else {
        AppLogger.error(
          LogLabel.network, 
          'HTTP error: ${response.statusCode}'
        );
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        LogLabel.network, 
        'Failed to fetch directions', 
        e, 
        stackTrace
      );
      return null;
    }
  }
}

/// Travel mode for directions
enum TravelMode {
  driving('driving'),
  walking('walking'),
  bicycling('bicycling'),
  transit('transit');

  final String value;
  const TravelMode(this.value);
}

/// Directions result containing route information
class DirectionsResult {
  final List<LatLng> polylinePoints;
  final String distanceText;
  final int distanceValue; // in meters
  final String durationText;
  final int durationValue; // in seconds
  final String startAddress;
  final String endAddress;

  DirectionsResult({
    required this.polylinePoints,
    required this.distanceText,
    required this.distanceValue,
    required this.durationText,
    required this.durationValue,
    required this.startAddress,
    required this.endAddress,
  });

  factory DirectionsResult.fromJson(Map<String, dynamic> json) {
    final route = json['routes'][0];
    final leg = route['legs'][0];
    
    // Decode polyline points
    final polyline = route['overview_polyline']['points'];
    final points = _decodePolyline(polyline);

    return DirectionsResult(
      polylinePoints: points,
      distanceText: leg['distance']['text'],
      distanceValue: leg['distance']['value'],
      durationText: leg['duration']['text'],
      durationValue: leg['duration']['value'],
      startAddress: leg['start_address'],
      endAddress: leg['end_address'],
    );
  }

  /// Decode Google's encoded polyline string to list of LatLng
  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }
}