import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/share_compact_stat.dart';
import 'share_route_grid.dart';

class ShareAchievementCard extends StatelessWidget {
  final String distance;
  final String pace;
  final String duration;
  final List<LatLng>? routePoints;
  final bool isLandmark;
  final String? userAvatarUrl;

  const ShareAchievementCard({
    super.key,
    required this.distance,
    required this.pace,
    required this.duration,
    this.routePoints,
    required this.isLandmark,
    this.userAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Main stat - Distance
          Column(
            children: [
              Text(
                'Sector Secured',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              ShareRouteGrid(
                routePoints: routePoints,
                isLandmark: isLandmark,
                userAvatarUrl: userAvatarUrl,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Divider
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),

          const SizedBox(height: 20),

          // Secondary main stats
          Row(
            children: [
              Expanded(
                child: ShareCompactStat(
                  label: 'DISTANCE',
                  value: distance,
                  icon: Icons.directions_walk,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: ShareCompactStat(
                  label: 'PACE',
                  value: pace,
                  icon: Icons.speed,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: ShareCompactStat(
                  label: 'TIME',
                  value: duration,
                  icon: Icons.timer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
