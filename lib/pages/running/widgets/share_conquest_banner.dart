import 'package:flutter/material.dart';
import 'package:turun/resources/colors_app.dart';

class ShareConquestBanner extends StatelessWidget {
  final bool isLandmark;
  final String? territoryName;

  const ShareConquestBanner({
    super.key,
    required this.isLandmark,
    this.territoryName,
  });

  @override
  Widget build(BuildContext context) {
    final bannerColor = isLandmark ? const Color(0xFF00E676) : AppColors.blueLogo;
    final bannerIcon = isLandmark ? Icons.add_location_alt : Icons.military_tech;
    final bannerText = isLandmark
        ? 'This landmark is officially'
        : 'This territory is officially';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            bannerColor.withValues(alpha: 0.2),
            bannerColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bannerColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: bannerColor.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bannerColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              bannerIcon,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bannerText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  territoryName ?? (isLandmark ? 'Unknown Landmark' : 'Unknown Territory'),
                  maxLines: 2,
                  style: TextStyle(
                    color: bannerColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
