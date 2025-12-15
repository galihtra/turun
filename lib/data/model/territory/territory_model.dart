import 'package:google_maps_flutter/google_maps_flutter.dart';

class Territory {
  final int id;
  final String? name;
  final String? region;
  final List<LatLng> points;
  final String? ownerId;
  final String? ownerName;
  final String? ownerColor;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? imageUrl;
  final String? difficulty;
  final int? rewardPoints;
  final double? areaSizeKm;
  final String? description;

  Territory({
    required this.id,
    this.name,
    this.region,
    required this.points,
    this.ownerId,
    this.ownerName,
    this.ownerColor,
    required this.createdAt,
    this.updatedAt,
    this.imageUrl,
    this.difficulty,
    this.rewardPoints,
    this.areaSizeKm,
    this.description,
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
      ownerName: json['owner_name'] as String?,
      ownerColor: json['owner_color'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      imageUrl: json['image_url'] as String?,
      difficulty: json['difficulty'] as String?,
      rewardPoints: json['reward_points'] as int?,
      areaSizeKm: json['area_size_km'] != null
          ? (json['area_size_km'] as num).toDouble()
          : null,
      description: json['description'] as String?,
    );
  }

  bool get isOwned => ownerId != null;
}
