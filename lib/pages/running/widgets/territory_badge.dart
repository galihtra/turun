import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class TerritoryBadge extends StatelessWidget {
  final bool isLandmarkMode;
  final String? territoryName;
  final Color userColor;

  const TerritoryBadge({
    super.key,
    required this.isLandmarkMode,
    this.territoryName,
    required this.userColor,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isLandmarkMode
                      ? const Color(0xFF00E676).withValues(alpha: 0.2)
                      : userColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLandmarkMode
                      ? Icons.add_location_alt
                      : Icons.flag_rounded,
                  color: isLandmarkMode
                      ? const Color(0xFF00E676)
                      : userColor,
                  size: 14,
                ),
              ),
              const Gap(8),
              Text(
                isLandmarkMode ? 'Landmark Run' : (territoryName ?? 'Territory'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isLandmarkMode
                      ? const Color(0xFF00E676)
                      : userColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
