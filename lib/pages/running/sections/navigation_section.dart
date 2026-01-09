import 'package:flutter/material.dart';
import 'package:turun/data/model/territory/territory_model.dart';
import 'navigation_info_card.dart';

class NavigationSection extends StatelessWidget {
  final Territory selectedTerritory;
  final String? distanceText;
  final String? durationText;
  final bool isLoadingRoute;
  final VoidCallback onStop;
  final VoidCallback onStartRunning;

  const NavigationSection({
    super.key,
    required this.selectedTerritory,
    required this.distanceText,
    required this.durationText,
    required this.isLoadingRoute,
    required this.onStop,
    required this.onStartRunning,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationInfoCard(
      destinationName: selectedTerritory.name ?? 'Territory #${selectedTerritory.id}',
      distanceText: distanceText,
      durationText: durationText,
      isLoadingRoute: isLoadingRoute,
      onStop: onStop,
      onStartRunning: onStartRunning,
    );
  }
}
