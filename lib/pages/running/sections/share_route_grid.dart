import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:turun/base_widgets/route_visualization.dart';

class ShareRouteGrid extends StatelessWidget {
  final List<LatLng>? routePoints;
  final bool isLandmark;
  final String? userAvatarUrl;

  const ShareRouteGrid({
    super.key,
    this.routePoints,
    required this.isLandmark,
    this.userAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Territory polygon background
          SizedBox(
            width: double.infinity,
            height: 100,
            child: CustomPaint(
              painter: ShareRoutePainter(
                routePoints: routePoints,
                isLandmark: isLandmark,
              ),
            ),
          ),
          // Profile with flag badge
          _buildProfileBadge(),
        ],
      ),
    );
  }

  Widget _buildProfileBadge() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Profile image
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: userAvatarUrl == null
                ? (isLandmark ? const Color(0xFF00E676) : Colors.red)
                : null,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: (isLandmark ? const Color(0xFF00E676) : Colors.red)
                    .withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
            image: userAvatarUrl != null
                ? DecorationImage(
                    image: NetworkImage(userAvatarUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: userAvatarUrl == null
              ? const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 24,
                )
              : null,
        ),
        // Flag badge
        Positioned(
          right: -5,
          bottom: -5,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.flag_rounded,
              color: Colors.white,
              size: 8,
            ),
          ),
        ),
      ],
    );
  }
}
