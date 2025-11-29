import 'package:google_maps_flutter/google_maps_flutter.dart';
class Territory {
  final int id;
  final String? name;
  final String? region;
  final List<LatLng> points;
  final String? ownerId;
  final DateTime createdAt;

  Territory({
    required this.id,
    this.name,
    this.region,
    required this.points,
    this.ownerId,
    required this.createdAt,
  });

  factory Territory.fromJson(Map<String, dynamic> json) {
    List<LatLng> pointsList = [];
    if (json['points'] != null) {
      final pointsData = json['points'] as List;
      pointsList = pointsData.map((point) {
        return LatLng(
          (point['lat'] as num).toDouble(),
          (point['lng'] as num).toDouble(),
        );
      }).toList();
    }

    return Territory(
      id: json['id'] as int,
      name: json['name'] as String?,
      region: json['region'] as String?,
      points: pointsList,
      ownerId: json['owner_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  bool get isOwned => ownerId != null;
}
