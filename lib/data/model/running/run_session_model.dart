import 'package:google_maps_flutter/google_maps_flutter.dart';

class RunSession {
  final String? id;
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

  RunSession({
    this.id,
    required this.userId,
    required this.territoryId,
    required this.startTime,
    this.endTime,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.averagePaceMinPerKm,
    required this.maxSpeed,
    required this.caloriesBurned,
    required this.routePoints,
    required this.status,
    this.territoryConquered = false,
    this.previousOwnerId,
  });

  // Convert meters/second to minutes/kilometer (pace)
  static double calculatePace(double distanceMeters, int durationSeconds) {
    if (distanceMeters == 0) return 0;
    final distanceKm = distanceMeters / 1000;
    final durationMinutes = durationSeconds / 60;
    return durationMinutes / distanceKm;
  }

  // Convert pace (min/km) to speed (km/h)
  static double paceToSpeed(double paceMinPerKm) {
    if (paceMinPerKm == 0) return 0;
    return 60 / paceMinPerKm;
  }

  // Estimate calories burned (rough estimate based on weight)
  static int estimateCalories(
      double distanceKm, int durationMinutes, double weightKg) {
    // MET (Metabolic Equivalent) for running varies by speed
    // Approximate: 8-12 MET for running
    const met = 10.0;
    final calories = (met * weightKg * durationMinutes / 60).round();
    return calories;
  }

  factory RunSession.fromJson(Map<String, dynamic> json) {
    List<LatLng> points = [];
    if (json['route_points'] != null) {
      final pointsData = json['route_points'] as List;
      points = pointsData.map((point) {
        return LatLng(
          (point['lat'] as num).toDouble(),
          (point['lng'] as num).toDouble(),
        );
      }).toList();
    }

    return RunSession(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      territoryId: json['territory_id'] as int,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      distanceMeters: (json['distance_meters'] as num).toDouble(),
      durationSeconds: json['duration_seconds'] as int,
      averagePaceMinPerKm: (json['average_pace_min_per_km'] as num).toDouble(),
      maxSpeed: (json['max_speed'] as num).toDouble(),
      caloriesBurned: json['calories_burned'] as int,
      routePoints: points,
      status: RunSessionStatus.values.firstWhere(
        (e) => e.toString() == 'RunSessionStatus.${json['status']}',
        orElse: () => RunSessionStatus.completed,
      ),
      territoryConquered: json['territory_conquered'] as bool? ?? false,
      previousOwnerId: json['previous_owner_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'territory_id': territoryId,
      'start_time': startTime.toIso8601String(),
      if (endTime != null) 'end_time': endTime!.toIso8601String(),
      'distance_meters': distanceMeters,
      'duration_seconds': durationSeconds,
      'average_pace_min_per_km': averagePaceMinPerKm,
      'max_speed': maxSpeed,
      'calories_burned': caloriesBurned,
      'route_points': routePoints.map((point) {
        return {'lat': point.latitude, 'lng': point.longitude};
      }).toList(),
      'status': status.name,
      'territory_conquered': territoryConquered,
      if (previousOwnerId != null) 'previous_owner_id': previousOwnerId,
    };
  }

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
    );
  }

  String get formattedDistance {
    if (distanceMeters < 1000) {
      return '${distanceMeters.toStringAsFixed(0)} m';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(2)} km';
  }

  String get formattedDuration {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String get formattedPace {
    final minutes = averagePaceMinPerKm.floor();
    final seconds = ((averagePaceMinPerKm - minutes) * 60).round();
    return "$minutes'${seconds.toString().padLeft(2, '0')}\" /km";
  }

  String get formattedSpeed {
    final speed = paceToSpeed(averagePaceMinPerKm);
    return '${speed.toStringAsFixed(1)} km/h';
  }
}

enum RunSessionStatus {
  active,
  paused,
  completed,
  cancelled,
}
