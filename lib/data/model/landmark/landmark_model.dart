import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Model for user-created landmarks
class Landmark {
  final int id;
  final String name;
  final String? description;
  final String ownerId;
  final String ownerName;
  final String? ownerUsername;
  final String? ownerAvatarUrl;
  final String? ownerProfileColor;
  final List<LatLng> routePoints;
  final double distanceMeters;
  final int durationSeconds;
  final double averagePaceMinPerKm;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Difficulty calculated from distance
  String get difficulty {
    final distanceKm = distanceMeters / 1000;
    if (distanceKm < 2) return 'Easy';
    if (distanceKm < 5) return 'Medium';
    return 'Hard';
  }

  /// Difficulty stars (1-3)
  int get difficultyStars {
    final distanceKm = distanceMeters / 1000;
    if (distanceKm < 2) return 1;
    if (distanceKm < 5) return 2;
    return 3;
  }

  /// Format distance for display
  String get formattedDistance {
    if (distanceMeters < 1000) {
      return '${distanceMeters.toStringAsFixed(0)} m';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(2)} km';
  }

  /// Format duration for display
  String get formattedDuration {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m ${seconds}s';
  }

  /// Format pace for display
  String get formattedPace {
    final paceMinutes = averagePaceMinPerKm.floor();
    final paceSeconds = ((averagePaceMinPerKm - paceMinutes) * 60).round();
    return "$paceMinutes'${paceSeconds.toString().padLeft(2, '0')}\"";
  }

  /// Calculate center point of the route
  LatLng get centerPoint {
    if (routePoints.isEmpty) {
      return const LatLng(0, 0);
    }

    double totalLat = 0;
    double totalLng = 0;

    for (var point in routePoints) {
      totalLat += point.latitude;
      totalLng += point.longitude;
    }

    return LatLng(
      totalLat / routePoints.length,
      totalLng / routePoints.length,
    );
  }

  /// Get start point
  LatLng? get startPoint {
    if (routePoints.isEmpty) return null;
    return routePoints.first;
  }

  /// Get end point
  LatLng? get endPoint {
    if (routePoints.isEmpty) return null;
    return routePoints.last;
  }

  Landmark({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    required this.ownerName,
    this.ownerUsername,
    this.ownerAvatarUrl,
    this.ownerProfileColor,
    required this.routePoints,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.averagePaceMinPerKm,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON (Supabase response)
  factory Landmark.fromJson(Map<String, dynamic> json) {
    // Parse route points
    List<LatLng> routePoints = [];
    if (json['route_points'] != null) {
      final points = json['route_points'] as List;
      routePoints = points.map((p) {
        if (p is Map) {
          return LatLng(
            (p['lat'] ?? p['latitude'] as num).toDouble(),
            (p['lng'] ?? p['longitude'] as num).toDouble(),
          );
        }
        return const LatLng(0, 0);
      }).toList();
    }

    // Parse owner data if joined
    String ownerName = 'Unknown';
    String? ownerUsername;
    String? ownerAvatarUrl;
    String? ownerProfileColor;

    if (json['users'] != null && json['users'] is Map) {
      final userData = json['users'] as Map<String, dynamic>;
      ownerName = userData['full_name'] as String? ?? 'Unknown';
      ownerUsername = userData['username'] as String?;
      ownerAvatarUrl = userData['avatar_url'] as String?;
      ownerProfileColor = userData['profile_color'] as String?;
    }

    return Landmark(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      ownerId: json['owner_id'] as String,
      ownerName: ownerName,
      ownerUsername: ownerUsername,
      ownerAvatarUrl: ownerAvatarUrl,
      ownerProfileColor: ownerProfileColor,
      routePoints: routePoints,
      distanceMeters: (json['distance_meters'] as num).toDouble(),
      durationSeconds: json['duration_seconds'] as int,
      averagePaceMinPerKm: (json['average_pace_min_per_km'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'owner_id': ownerId,
      'route_points': routePoints
          .map((point) => {
                'lat': point.latitude,
                'lng': point.longitude,
              })
          .toList(),
      'distance_meters': distanceMeters,
      'duration_seconds': durationSeconds,
      'average_pace_min_per_km': averagePaceMinPerKm,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with
  Landmark copyWith({
    int? id,
    String? name,
    String? description,
    String? ownerId,
    String? ownerName,
    String? ownerUsername,
    String? ownerAvatarUrl,
    String? ownerProfileColor,
    List<LatLng>? routePoints,
    double? distanceMeters,
    int? durationSeconds,
    double? averagePaceMinPerKm,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Landmark(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerUsername: ownerUsername ?? this.ownerUsername,
      ownerAvatarUrl: ownerAvatarUrl ?? this.ownerAvatarUrl,
      ownerProfileColor: ownerProfileColor ?? this.ownerProfileColor,
      routePoints: routePoints ?? this.routePoints,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      averagePaceMinPerKm: averagePaceMinPerKm ?? this.averagePaceMinPerKm,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
