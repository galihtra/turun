import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:turun/app/app_logger.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/values_app.dart';
import '../../data/providers/running/running_provider.dart';
import 'widgets/navigation_info_card.dart';
import 'widgets/territory_card.dart';
import 'widgets/territory_card_shimmer.dart';
import 'run_tracking_screen.dart';

class RunningPage extends StatefulWidget {
  const RunningPage({super.key});

  @override
  RunningPageState createState() => RunningPageState();
}

class RunningPageState extends State<RunningPage> {
  GoogleMapController? mapController;
  int _selectedMode = 0;
  double _currentZoom = 16.0;

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

  void _zoomIn() {
    if (mapController != null) {
      setState(() {
        _currentZoom = (_currentZoom + 1).clamp(0, 21);
      });
      mapController!.animateCamera(
        CameraUpdate.zoomTo(_currentZoom),
      );
    }
  }

  void _zoomOut() {
    if (mapController != null) {
      setState(() {
        _currentZoom = (_currentZoom - 1).clamp(0, 21);
      });
      mapController!.animateCamera(
        CameraUpdate.zoomTo(_currentZoom),
      );
    }
  }

  void _recenterMap() async {
    final runningProvider = context.read<RunningProvider>();
    if (runningProvider.currentLatLng != null && mapController != null) {
      await mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          runningProvider.currentLatLng!,
          17.0,
        ),
      );
      setState(() {
        _currentZoom = 17.0;
      });
    }
  }

  void _handleTerritoryNavigate(
      BuildContext context, RunningProvider provider, int index) {
    final territory = provider.territories[index];

    AppLogger.info(LogLabel.general, 'User tapped Go to Location');

    // Start navigation
    provider.startNavigation(territory);

    // Animate camera to show route
    if (provider.currentLatLng != null && mapController != null) {
      // Small delay to ensure route is loaded
      Future.delayed(const Duration(milliseconds: 500), () {
        if (provider.routePolylines.isNotEmpty && mapController != null) {
          // Calculate bounds to show both current location and destination
          final bounds = _calculateBounds(
            provider.currentLatLng!,
            provider.routePolylines.first.points.last,
          );

          mapController!.animateCamera(
            CameraUpdate.newLatLngBounds(bounds, 100),
          );
        }
      });
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
                mapType: MapType.normal,
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
                markers: runningProvider.markers, // ✅ Show start point marker
              ),

              // ==================== LOADING OVERLAY ====================
              if (runningProvider.isLoading ||
                  runningProvider.isLoadingTerritories)
                Container(
                  color: Colors.black.withValues(alpha: 0.7),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              const CircularProgressIndicator(
                                color: Colors.blue,
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                runningProvider.isLoadingTerritories
                                    ? 'Loading territories...'
                                    : 'Getting location...',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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
                          color: Colors.blue.withValues(alpha: 0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 3),
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
                                gradient: _selectedMode == 0
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF2196F3),
                                          Color(0xFF1976D2),
                                        ],
                                      )
                                    : null,
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
                                gradient: _selectedMode == 1
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF2196F3),
                                          Color(0xFF1976D2),
                                        ],
                                      )
                                    : null,
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

              // ==================== NAVIGATION INFO CARD ====================
              // Show ONLY when navigating AND not arrived yet
              if (runningProvider.isNavigating &&
                  runningProvider.selectedTerritory != null &&
                  !runningProvider.hasArrivedAtStartPoint)
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: NavigationInfoCard(
                    destinationName:
                        runningProvider.selectedTerritory!.name ??
                            'Territory #${runningProvider.selectedTerritory!.id}',
                    // ✅ FIX: Pass the actual distance and duration from provider
                    distanceText: runningProvider.distanceText,
                    durationText: runningProvider.durationText,
                    isLoadingRoute: runningProvider.isLoadingRoute,
                    onStop: () => runningProvider.stopNavigation(),
                    // ✅ START RUNNING callback (not used when card visible)
                    onStartRunning: () async {
                      final selectedTerritory = runningProvider.selectedTerritory;
                      if (selectedTerritory == null || runningProvider.currentLatLng == null) {
                        return;
                      }

                      // ✅ Check if user is at START POINT (first coordinate)
                      final isAtStartPoint = runningProvider.isAtTerritoryStartPoint(
                        runningProvider.currentLatLng!,
                        selectedTerritory,
                      );

                      if (isAtStartPoint) {
                        // ✅ User at start point! Can begin run
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.celebration, color: Colors.white),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '🎉 You\'re at the start point! Starting run...',
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green.shade600,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.all(16),
                            duration: const Duration(seconds: 2),
                          ),
                        );

                        // Start run session
                        final started = await runningProvider.startRunSession();

                        if (started && context.mounted) {
                          // Navigate to run tracking screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RunTrackingScreen(),
                            ),
                          );
                        }
                      } else {
                        // ⚠️ User not at start point yet
                        final distanceToStart = runningProvider.getDistanceToStartPoint(
                          runningProvider.currentLatLng,
                          selectedTerritory,
                        );

                        String distanceMessage;
                        if (distanceToStart != null) {
                          if (distanceToStart < 1000) {
                            distanceMessage = '${distanceToStart.toStringAsFixed(0)} m';
                          } else {
                            distanceMessage = '${(distanceToStart / 1000).toStringAsFixed(2)} km';
                          }
                        } else {
                          distanceMessage = runningProvider.distanceText ?? '---';
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.info_outline, color: Colors.white),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Please go to the START POINT first!\n$distanceMessage remaining',
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.orange.shade600,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.all(16),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                  ),
                ),

              // ==================== TERRITORY LIST SHIMMER (LOADING) ====================
              if (!runningProvider.isNavigating &&
                  runningProvider.isLoadingTerritories)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.28,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 3, // Show 3 shimmer cards
                      itemBuilder: (context, index) {
                        return const TerritoryCardShimmer();
                      },
                    ),
                  ),
                ),

              // ==================== TERRITORY LIST (BOTTOM) ====================
              if (!runningProvider.isNavigating &&
                  !runningProvider.isLoadingTerritories &&
                  runningProvider.territories.isNotEmpty)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: CarouselSlider.builder(
                    itemCount: runningProvider.territories.length,
                    options: CarouselOptions(
                      height: 200,
                      enlargeCenterPage: true,
                      enlargeFactor: 0.25,
                      viewportFraction: 0.85,
                      enableInfiniteScroll: false,
                      padEnds: true,
                    ),
                    itemBuilder: (context, index, realIndex) {
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
                        onTap: () {
                          runningProvider.selectTerritory(territory);
                          // Animate camera to territory location when card is tapped
                          if (territory.points.isNotEmpty &&
                              mapController != null) {
                            // Calculate center of territory
                            double totalLat = 0;
                            double totalLng = 0;
                            for (var point in territory.points) {
                              totalLat += point.latitude;
                              totalLng += point.longitude;
                            }
                            final centerLat =
                                totalLat / territory.points.length;
                            final centerLng =
                                totalLng / territory.points.length;
                            final territoryCenter =
                                LatLng(centerLat, centerLng);

                            // Animate camera to territory with smooth animation
                            mapController!.animateCamera(
                              CameraUpdate.newLatLngZoom(
                                territoryCenter,
                                16.5,
                              ),
                            );
                          }
                        },
                        onNavigate: () => _handleTerritoryNavigate(
                          context,
                          runningProvider,
                          index,
                        ),
                      );
                    },
                  ),
                ),

              // ==================== ZOOM CONTROLS ====================
              Positioned(
                bottom: runningProvider.isNavigating ? 50 : 240,
                left: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Zoom In Button
                    Material(
                      elevation: 5,
                      shape: const CircleBorder(),
                      shadowColor: Colors.blue.withValues(alpha: 0.3),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: Icon(
                            Icons.add_rounded,
                            color: Colors.blue.shade700,
                            size: 22,
                          ),
                          onPressed: _zoomIn,
                          tooltip: 'Zoom In',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Zoom Out Button
                    Material(
                      elevation: 5,
                      shape: const CircleBorder(),
                      shadowColor: Colors.blue.withValues(alpha: 0.3),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: Icon(
                            Icons.remove_rounded,
                            color: Colors.blue.shade700,
                            size: 22,
                          ),
                          onPressed: _zoomOut,
                          tooltip: 'Zoom Out',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ==================== START RUN FLOATING BUTTON ====================
              // Show when arrived at start point
              if (runningProvider.isNavigating &&
                  runningProvider.hasArrivedAtStartPoint)
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(30),
                      child: InkWell(
                        onTap: () async {
                          // Start run session
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.directions_run_rounded,
                                      color: Colors.white, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'Starting running...',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: AppColors.blue[700],
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(16),
                              duration: const Duration(seconds: 2),
                            ),
                          );

                          final started = await runningProvider.startRunSession();

                          if (started && context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RunTrackingScreen(),
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.blueGradient,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.blueLogo.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.directions_run_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Start Run',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // ==================== RECENTER BUTTON ====================
              Positioned(
                bottom: runningProvider.isNavigating ? 50 : 240,
                right: 20,
                child: Material(
                  elevation: 5,
                  shape: const CircleBorder(),
                  shadowColor: Colors.blue.withValues(alpha: 0.3),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(
                        Icons.my_location_rounded,
                        color: Colors.blue.shade700,
                        size: 22,
                      ),
                      onPressed: _recenterMap,
                      tooltip: 'Recenter Map',
                    ),
                  ),
                ),
              ),

              // ==================== ERROR MESSAGE ====================
              if (runningProvider.error != null)
                Positioned(
                  top: runningProvider.isNavigating ? 250 : 120,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade600,
                          Colors.orange.shade700,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Using default location',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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
    super.dispose();
  }
}