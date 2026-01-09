import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:turun/data/model/territory/territory_model.dart';

import '../widgets/territory_card.dart';

class TerritoryListCarousel extends StatelessWidget {
  final List<Territory> territories;
  final Territory? selectedTerritory;
  final LatLng? currentLocation;
  final Function(Territory) onTerritorySelected;
  final Function(Territory) onNavigate;
  final GoogleMapController? mapController;

  const TerritoryListCarousel({
    super.key,
    required this.territories,
    required this.selectedTerritory,
    required this.currentLocation,
    required this.onTerritorySelected,
    required this.onNavigate,
    this.mapController,
  });

  @override
  Widget build(BuildContext context) {
    if (territories.isEmpty) return const SizedBox.shrink();

    return CarouselSlider.builder(
      itemCount: territories.length,
      options: CarouselOptions(
        height: 200,
        enlargeCenterPage: true,
        enlargeFactor: 0.25,
        viewportFraction: 0.85,
        enableInfiniteScroll: false,
        padEnds: true,
      ),
      itemBuilder: (context, index, realIndex) {
        final territory = territories[index];
        final isSelected = selectedTerritory?.id == territory.id;
        final distance = _calculateDistance(currentLocation, territory.points);

        return TerritoryCard(
          territory: territory,
          isSelected: isSelected,
          distance: distance,
          onTap: () {
            onTerritorySelected(territory);
            _animateCameraToTerritory(territory);
          },
          onNavigate: () => onNavigate(territory),
        );
      },
    );
  }

  void _animateCameraToTerritory(Territory territory) {
    if (territory.points.isEmpty || mapController == null) return;

    // Calculate center of territory
    double totalLat = 0;
    double totalLng = 0;
    for (var point in territory.points) {
      totalLat += point.latitude;
      totalLng += point.longitude;
    }
    final centerLat = totalLat / territory.points.length;
    final centerLng = totalLng / territory.points.length;
    final territoryCenter = LatLng(centerLat, centerLng);

    mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(territoryCenter, 16.5),
    );
  }

  double? _calculateDistance(LatLng? currentLocation, List<LatLng> territoryPoints) {
    if (currentLocation == null || territoryPoints.isEmpty) return null;

    // Calculate distance to center of territory
    double totalLat = 0;
    double totalLng = 0;

    for (var point in territoryPoints) {
      totalLat += point.latitude;
      totalLng += point.longitude;
    }

    final centerLat = totalLat / territoryPoints.length;
    final centerLng = totalLng / territoryPoints.length;

    return Geolocator.distanceBetween(
      currentLocation.latitude,
      currentLocation.longitude,
      centerLat,
      centerLng,
    );
  }
}
