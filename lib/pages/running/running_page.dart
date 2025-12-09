import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:turun/app/app_logger.dart';
import 'package:turun/resources/values_app.dart';
import '../../data/providers/running/running_provider.dart';
import 'widgets/navigation_info_card.dart';
import 'widgets/territory_card.dart';

class RunningPage extends StatefulWidget {
  const RunningPage({super.key});

  @override
  _RunningPageState createState() => _RunningPageState();
}

class _RunningPageState extends State<RunningPage> {
  GoogleMapController? mapController;
  int _selectedMode = 0;
  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RunningProvider>().initializeLocation();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    final runningProvider = context.read<RunningProvider>();
    if (runningProvider.currentLatLng != null) {
      controller.animateCamera(
        CameraUpdate.newLatLng(runningProvider.currentLatLng!),
      );
    }
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType =
          _currentMapType == MapType.normal ? MapType.hybrid : MapType.normal;
    });
  }

  void _handleTerritoryNavigate(
      BuildContext context, RunningProvider provider, int index) {
    final territory = provider.territories[index];

    AppLogger.info(LogLabel.general, 'User tapped Go to Location');

    // Start navigation
    provider.startNavigation(territory);

    // Animate camera to show route
    if (provider.currentLatLng != null && mapController != null) {
      // Calculate bounds to show both current location and destination
      final bounds = _calculateBounds(
        provider.currentLatLng!,
        provider.routePolylines.first.points.last,
      );

      mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100),
      );
    }
  }

  LatLngBounds _calculateBounds(LatLng point1, LatLng point2) {
    final southwest = LatLng(
      point1.latitude < point2.latitude ? point1.latitude : point2.latitude,
      point1.longitude < point2.longitude
          ? point1.longitude
          : point2.longitude,
    );

    final northeast = LatLng(
      point1.latitude > point2.latitude ? point1.latitude : point2.latitude,
      point1.longitude > point2.longitude
          ? point1.longitude
          : point2.longitude,
    );

    return LatLngBounds(southwest: southwest, northeast: northeast);
  }

  double? _calculateDistance(
      LatLng? currentLocation, List<LatLng> territoryPoints) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RunningProvider>(
        builder: (context, runningProvider, child) {
          LatLng initialPosition = const LatLng(1.18376, 104.01703);

          if (runningProvider.currentLatLng != null) {
            initialPosition = runningProvider.currentLatLng!;
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              // ==================== GOOGLE MAP ====================
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: initialPosition,
                  zoom: 16.0,
                ),
                mapType: _currentMapType,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
                liteModeEnabled: false,
                tiltGesturesEnabled: false,
                rotateGesturesEnabled: false,
                polygons: runningProvider.polygons,
                polylines: runningProvider.routePolylines,
              ),

              // ==================== LOADING OVERLAY ====================
              if (runningProvider.isLoading ||
                  runningProvider.isLoadingTerritories)
                Container(
                  color: Colors.black26,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          runningProvider.isLoadingTerritories
                              ? 'Loading territories...'
                              : 'Getting location...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ==================== MODE SELECTOR (Game/Solo) ====================
              if (!runningProvider.isNavigating)
                Positioned(
                  top: 60,
                  left: MediaQuery.of(context).size.width * 0.2,
                  right: MediaQuery.of(context).size.width * 0.2,
                  child: Container(
                    height: AppDimens.h45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDimens.r30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedMode = 0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _selectedMode == 0
                                    ? Colors.blue
                                    : Colors.transparent,
                                borderRadius:
                                    BorderRadius.circular(AppDimens.r30),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.sports_esports,
                                        color: _selectedMode == 0
                                            ? Colors.white
                                            : Colors.black54,
                                        size: AppSizes.s18),
                                    AppGaps.kGap5,
                                    Text(
                                      "Game",
                                      style: TextStyle(
                                        color: _selectedMode == 0
                                            ? Colors.white
                                            : Colors.black54,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedMode = 1),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _selectedMode == 1
                                    ? Colors.blue
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  "Solo",
                                  style: TextStyle(
                                    color: _selectedMode == 1
                                        ? Colors.white
                                        : Colors.black54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ==================== TERRITORY LIST ====================
              if (!runningProvider.isNavigating &&
                  !runningProvider.isLoadingTerritories &&
                  runningProvider.territories.isNotEmpty)
                Positioned(
                  top: 120,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: runningProvider.territories.length,
                      itemBuilder: (context, index) {
                        final territory = runningProvider.territories[index];
                        final isSelected =
                            runningProvider.selectedTerritory?.id ==
                                territory.id;
                        final distance = _calculateDistance(
                          runningProvider.currentLatLng,
                          territory.points,
                        );

                        return TerritoryCard(
                          territory: territory,
                          isSelected: isSelected,
                          distance: distance,
                          onTap: () =>
                              runningProvider.selectTerritory(territory),
                          onNavigate: () => _handleTerritoryNavigate(
                            context,
                            runningProvider,
                            index,
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // ==================== NAVIGATION INFO CARD ====================
              if (runningProvider.isNavigating &&
                  runningProvider.selectedTerritory != null)
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: NavigationInfoCard(
                    destinationName:
                        runningProvider.selectedTerritory!.name ??
                            'Territory #${runningProvider.selectedTerritory!.id}',
                    onStop: () => runningProvider.stopNavigation(),
                  ),
                ),

              // ==================== START BUTTON ====================
              if (!runningProvider.isNavigating)
                Positioned(
                  bottom: 40,
                  child: ElevatedButton(
                    onPressed: (runningProvider.isLoading ||
                            runningProvider.isLoadingTerritories)
                        ? null
                        : () {
                            if (runningProvider.currentLatLng == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Waiting for location...'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } else {
                              final nearbyTerritories =
                                  runningProvider.getTerritoriesNear(
                                runningProvider.currentLatLng!,
                                0.5,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Found ${nearbyTerritories.length} territories nearby',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.r30),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimens.w40,
                        vertical: AppDimens.h15,
                      ),
                      elevation: 5,
                    ),
                    child: const Row(
                      children: [
                        Text(
                          "START",
                          style: TextStyle(
                            fontSize: AppSizes.s18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        AppGaps.kGap8,
                        Icon(Icons.play_arrow, color: Colors.white),
                      ],
                    ),
                  ),
                ),

              // ==================== MAP TYPE TOGGLE ====================
              Positioned(
                bottom: 50,
                left: 20,
                child: Material(
                  elevation: 3,
                  shape: const CircleBorder(),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(
                        _currentMapType == MapType.normal
                            ? Icons.layers
                            : Icons.map,
                        color: Colors.black87,
                      ),
                      onPressed: _toggleMapType,
                      tooltip: 'Toggle Map Type',
                    ),
                  ),
                ),
              ),

              // ==================== MY LOCATION BUTTON ====================
              Positioned(
                bottom: 50,
                right: 20,
                child: Material(
                  elevation: 3,
                  shape: const CircleBorder(),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.my_location, color: Colors.blue),
                      onPressed: () async {
                        if (runningProvider.currentLatLng != null &&
                            mapController != null) {
                          await mapController!.animateCamera(
                            CameraUpdate.newLatLngZoom(
                              runningProvider.currentLatLng!,
                              16.0,
                            ),
                          );
                        } else {
                          await runningProvider.getCurrentLocation();
                          if (runningProvider.currentLatLng != null &&
                              mapController != null) {
                            await mapController!.animateCamera(
                              CameraUpdate.newLatLngZoom(
                                runningProvider.currentLatLng!,
                                16.0,
                              ),
                            );
                          }
                        }
                      },
                      tooltip: 'My Location',
                    ),
                  ),
                ),
              ),

              // ==================== ERROR MESSAGE ====================
              if (runningProvider.error != null)
                Positioned(
                  top: runningProvider.isNavigating ? 250 : 320,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade700,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Using default location',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    // Provider will handle stopping location tracking
    super.dispose();
  }
}