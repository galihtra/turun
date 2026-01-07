import 'package:flutter/material.dart';
import 'package:turun/resources/colors_app.dart';

class MapControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onRecenter;

  const MapControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onRecenter,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.3,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom In Button
          Material(
            elevation: 4,
            shape: const CircleBorder(),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(
                  Icons.add_rounded,
                  color: AppColors.blueLogo,
                  size: 20,
                ),
                onPressed: onZoomIn,
                tooltip: 'Zoom In',
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Zoom Out Button
          Material(
            elevation: 4,
            shape: const CircleBorder(),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(
                  Icons.remove_rounded,
                  color: AppColors.blueLogo,
                  size: 20,
                ),
                onPressed: onZoomOut,
                tooltip: 'Zoom Out',
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Recenter Button
          Material(
            elevation: 4,
            shape: const CircleBorder(),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(
                  Icons.my_location_rounded,
                  color: AppColors.blueLogo,
                  size: 20,
                ),
                onPressed: onRecenter,
                tooltip: 'Recenter Map',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
