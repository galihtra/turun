import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Status enum for run session
enum RunSessionStatus {
  active,
  paused,
  completed,
  cancelled;

  static RunSessionStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return RunSessionStatus.active;
      case 'paused':
        return RunSessionStatus.paused;
      case 'completed':
        return RunSessionStatus.completed;
      case 'cancelled':
        return RunSessionStatus.cancelled;
      default:
        return RunSessionStatus.active;
    }
  }
}

/// Model untuk run session
class RunSession {
  final String id;
  final String userId;
  final int territoryId;
  final DateTime startTime;
  final DateTime? endTime;
  final double distanceMeters;
  final int durationSeconds;
  final double averagePaceMinPerKm;
  final double maxSpeed;
  final int caloriesBurned;
  final List<LatLng> routePoints;
  final RunSessionStatus status;
  final bool territoryConquered;
  final String? previousOwnerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional user data from join
  final String? userName;
  final String? userUsername;
  final String? userAvatarUrl;
  final String? userProfileColor;

  RunSession({
    required this.id,
    required this.userId,
    required this.territoryId,
    required this.startTime,
    this.endTime,
    this.distanceMeters = 0,
    this.durationSeconds = 0,
    this.averagePaceMinPerKm = 0,
    this.maxSpeed = 0,
    this.caloriesBurned = 0,
    this.routePoints = const [],
    this.status = RunSessionStatus.active,
    this.territoryConquered = false,
    this.previousOwnerId,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userUsername,
    this.userAvatarUrl,
    this.userProfileColor,
  });

  /// Create from JSON (Supabase response)
  factory RunSession.fromJson(Map<String, dynamic> json) {
    // Parse route points
    List<LatLng> routePoints = [];
    if (json['route_points'] != null) {
      final points = json['route_points'] as List;
      routePoints = points.map((p) {
        if (p is Map) {
          return LatLng(
            (p['lat'] as num).toDouble(),
            (p['lng'] as num).toDouble(),
          );
        }
        return const LatLng(0, 0);
      }).toList();
    }

    // Parse user data if joined
    String? userName;
    String? userUsername;
    String? userAvatarUrl;
    String? userProfileColor;

    if (json['users'] != null && json['users'] is Map) {
      final userData = json['users'] as Map<String, dynamic>;
      userName = userData['full_name'] as String?;
      userUsername = userData['username'] as String?;
      userAvatarUrl = userData['avatar_url'] as String?;
      userProfileColor = userData['profile_color'] as String?;
    }

    return RunSession(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      territoryId: json['territory_id'] as int,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      distanceMeters: (json['distance_meters'] as num?)?.toDouble() ?? 0,
      durationSeconds: (json['duration_seconds'] as int?) ?? 0,
      averagePaceMinPerKm:
          (json['average_pace_min_per_km'] as num?)?.toDouble() ?? 0,
      maxSpeed: (json['max_speed'] as num?)?.toDouble() ?? 0,
      caloriesBurned: (json['calories_burned'] as int?) ?? 0,
      routePoints: routePoints,
      status: RunSessionStatus.fromString(json['status'] as String? ?? 'active'),
      territoryConquered: json['territory_conquered'] as bool? ?? false,
      previousOwnerId: json['previous_owner_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userName: userName,
      userUsername: userUsername,
      userAvatarUrl: userAvatarUrl,
      userProfileColor: userProfileColor,
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'territory_id': territoryId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'distance_meters': distanceMeters,
      'duration_seconds': durationSeconds,
      'average_pace_min_per_km': averagePaceMinPerKm,
      'max_speed': maxSpeed,
      'calories_burned': caloriesBurned,
      'route_points': routePoints.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'status': status.name,
      'territory_conquered': territoryConquered,
      'previous_owner_id': previousOwnerId,
    };
  }

  /// Create copy with updated fields
  RunSession copyWith({
    String? id,
    String? userId,
    int? territoryId,
    DateTime? startTime,
    DateTime? endTime,
    double? distanceMeters,
    int? durationSeconds,
    double? averagePaceMinPerKm,
    double? maxSpeed,
    int? caloriesBurned,
    List<LatLng>? routePoints,
    RunSessionStatus? status,
    bool? territoryConquered,
    String? previousOwnerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RunSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      territoryId: territoryId ?? this.territoryId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      averagePaceMinPerKm: averagePaceMinPerKm ?? this.averagePaceMinPerKm,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      routePoints: routePoints ?? this.routePoints,
      status: status ?? this.status,
      territoryConquered: territoryConquered ?? this.territoryConquered,
      previousOwnerId: previousOwnerId ?? this.previousOwnerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName,
      userUsername: userUsername,
      userAvatarUrl: userAvatarUrl,
      userProfileColor: userProfileColor,
    );
  }

  // ==================== COMPUTED PROPERTIES ====================

  /// Distance in kilometers
  double get distanceKm => distanceMeters / 1000;

  /// Formatted distance (e.g., "2.5 km" or "500 m")
  String get formattedDistance {
    if (distanceMeters < 1000) {
      return '${distanceMeters.toStringAsFixed(0)} m';
    }
    return '${distanceKm.toStringAsFixed(2)} km';
  }

  /// Formatted duration (e.g., "12:34" or "1:23:45")
  String get formattedDuration {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formatted pace (e.g., "5'30\"" for 5:30 per km)
  String get formattedPace {
    if (averagePaceMinPerKm <= 0 || averagePaceMinPerKm.isInfinite || averagePaceMinPerKm.isNaN) {
      return "--'--\"";
    }

    final minutes = averagePaceMinPerKm.floor();
    final seconds = ((averagePaceMinPerKm - minutes) * 60).round();

    return "$minutes'${seconds.toString().padLeft(2, '0')}\"";
  }

  /// Formatted pace with label (e.g., "5'30\"/km")
  String get formattedPaceWithUnit => '${formattedPace}/km';

  /// Average speed in km/h
  double get averageSpeedKmh {
    if (durationSeconds <= 0) return 0;
    return (distanceKm / durationSeconds) * 3600;
  }

  /// Formatted speed (e.g., "8.5 km/h")
  String get formattedSpeed {
    return '${averageSpeedKmh.toStringAsFixed(1)} km/h';
  }

  /// User display name (prefers full_name, falls back to username)
  String get userDisplayName {
    if (userName != null && userName!.isNotEmpty) return userName!;
    if (userUsername != null && userUsername!.isNotEmpty) return userUsername!;
    return 'Unknown Runner';
  }

  /// Is this run completed?
  bool get isCompleted => status == RunSessionStatus.completed;

  /// Is this run active?
  bool get isActive => status == RunSessionStatus.active;

  /// Did this run result in a territory conquest?
  bool get didConquerTerritory => territoryConquered;

  @override
  String toString() {
    return 'RunSession(id: $id, distance: $formattedDistance, duration: $formattedDuration, pace: $formattedPace, conquered: $territoryConquered)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RunSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}