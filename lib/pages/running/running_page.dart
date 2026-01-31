import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:turun/app/app_logger.dart';
import 'package:turun/pages/landmark/landmark_route_planner_screen.dart';
import '../../data/providers/running/running_provider.dart';
import '../../data/providers/landmark/landmark_provider.dart';
import '../../data/model/running/run_mode.dart';
import 'sections/navigation_section.dart';
import 'sections/territory_list_carousel.dart';
import 'widgets/territory_card_shimmer.dart';
import 'widgets/mode_selector.dart';
import 'widgets/start_landmark_button.dart';
import 'widgets/start_run_button.dart';
import 'sections/map_controls.dart';
import '../../pages/landmark/widgets/planning_dialogs.dart';
import 'run_tracking_screen.dart';
import 'helpers/map_helper.dart';
import 'package:turun/resources/colors_app.dart';

class RunningPage extends StatefulWidget {
  const RunningPage({super.key});

  @override
  RunningPageState createState() => RunningPageState();
}

class RunningPageState extends State<RunningPage> {
  GoogleMapController? mapController;
  double _currentZoom = 16.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RunningProvider>().initializeLocation();
    });
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
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
      setState(() => _currentZoom = (_currentZoom + 1).clamp(0, 21));
      mapController!.animateCamera(CameraUpdate.zoomTo(_currentZoom));
    }
  }

  void _zoomOut() {
    if (mapController != null) {
      setState(() => _currentZoom = (_currentZoom - 1).clamp(0, 21));
      mapController!.animateCamera(CameraUpdate.zoomTo(_currentZoom));
    }
  }

  void _recenterMap() async {
    final runningProvider = context.read<RunningProvider>();
    if (runningProvider.currentLatLng != null && mapController != null) {
      await mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(runningProvider.currentLatLng!, 17.0),
      );
      setState(() => _currentZoom = 17.0);
    }
  }

  void _handleTerritoryNavigate(RunningProvider provider, int index) {
    final territory = provider.territories[index];
    AppLogger.info(LogLabel.general, 'User tapped Go to Location');

    provider.startNavigation(territory);

    // Animate camera to show route
    if (provider.currentLatLng != null && mapController != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (provider.routePolylines.isNotEmpty && mapController != null) {
          final bounds = MapHelper.calculateBounds(
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

  Future<void> _handleStartRunning(RunningProvider provider) async {
    final selectedTerritory = provider.selectedTerritory;
    if (selectedTerritory == null || provider.currentLatLng == null) return;

    final isAtStartPoint = provider.isAtTerritoryStartPoint(
      provider.currentLatLng!,
      selectedTerritory,
    );

    if (isAtStartPoint) {
      _showSnackBar(
        '🎉 You\'re at the start point! Starting run...',
        Colors.green.shade600,
      );

      final started = await provider.startRunSession();
      if (started && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RunTrackingScreen()),
        );
      }
    } else {
      final distanceToStart = provider.getDistanceToStartPoint(
        provider.currentLatLng,
        selectedTerritory,
      );

      String distanceMessage = _formatDistance(distanceToStart) ?? provider.distanceText ?? '---';

      _showSnackBar(
        'Please go to the START POINT first!\n$distanceMessage remaining',
        Colors.orange.shade600,
        duration: 3,
      );
    }
  }

  Future<void> _handleStartLandmarkRun() async {
    final runProvider = context.read<RunningProvider>();
    final landmarkProvider = context.read<LandmarkProvider>();
    final currentLocation = runProvider.currentLatLng;

    if (currentLocation == null) {
      _showSnackBar('Waiting for GPS location...', Colors.orange);
      return;
    }

    // Check if user is near any existing territory
    final nearbyTerritory = await landmarkProvider.checkTerritoryProximity(currentLocation);

    if (nearbyTerritory != null && mounted) {
      // ✅ Use new cool gamified warning
      final wantToChallenge = await PlanningDialogs.showOverlapWarning(
        context, 
        nearbyTerritory,
        mode: WarningMode.proximity,
      );

      if (wantToChallenge && mounted) {
        runProvider.switchMode(RunMode.territory);
        runProvider.selectTerritory(nearbyTerritory);

        final territoryIndex = runProvider.territories.indexWhere(
          (t) => t.id == nearbyTerritory.id,
        );

        if (territoryIndex != -1) {
          _handleTerritoryNavigate(runProvider, territoryIndex);
        } else {
          runProvider.startNavigation(nearbyTerritory);
        }
      }
      return;
    }

    // No nearby territory, start landmark run
    final started = await landmarkProvider.startLandmarkRun(currentLocation);
    if (started && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RunTrackingScreen()),
      );
    }
  }

  Future<void> _handleStartRunAtPoint(RunningProvider provider) async {
    _showSnackBar('Starting running...', Colors.blue[700]!, duration: 2);

    final started = await provider.startRunSession();
    if (started && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RunTrackingScreen()),
      );
    }
  }

  void _showSnackBar(String message, Color backgroundColor, {int duration = 2}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: duration),
      ),
    );
  }

  String? _formatDistance(double? distance) {
    if (distance == null) return null;
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(2)} km';
    }
  }

  void _openRoutePlanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LandmarkRoutePlannerScreen(),
      ),
    );
  }

  Set<Polyline> _getPolylines(RunningProvider runningProvider, LandmarkProvider landmarkProvider) {
    final polylines = <Polyline>{
      ...runningProvider.routePolylines,
      ...runningProvider.territoryPolylines, // ✅ NEW: Always show territory routes
    };
    
    if (runningProvider.isLandmarkMode && landmarkProvider.hasPlannedRoute) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('planned_ghost_route'),
          points: landmarkProvider.plannedRoutePoints,
          color: AppColors.blueLogo.withValues(alpha: 0.5),
          width: 5,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );
    }
    
    return polylines;
  }
  
  Set<Marker> _getMarkers(RunningProvider runningProvider, LandmarkProvider landmarkProvider) {
    final markers = <Marker>{...runningProvider.markers};
    
     if (runningProvider.isLandmarkMode && landmarkProvider.hasPlannedRoute) {
       final points = landmarkProvider.plannedRoutePoints;
       markers.add(
         Marker(
           markerId: const MarkerId('planned_start'),
           position: points.first,
           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
           alpha: 0.7,
           infoWindow: const InfoWindow(title: 'Planned Start'),
         ),
       );
       if (points.length > 1) {
         markers.add(
           Marker(
             markerId: const MarkerId('planned_end'),
             position: points.last,
             icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
             alpha: 0.7,
             infoWindow: const InfoWindow(title: 'Planned End'),
           ),
         );
       }
     }
     
     return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<RunningProvider, LandmarkProvider>(
        builder: (context, runningProvider, landmarkProvider, child) {
          final initialPosition = runningProvider.currentLatLng ?? const LatLng(1.18376, 104.01703);

          return Stack(
            alignment: Alignment.center,
            children: [
              // Google Map
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
                polylines: _getPolylines(runningProvider, landmarkProvider),
                markers: _getMarkers(runningProvider, landmarkProvider),
              ),

              // Loading Overlay
              if (runningProvider.isLoading || runningProvider.isLoadingTerritories)
                _buildLoadingOverlay(runningProvider),

              // Mode Selector (Territory/Landmark)
              if (!runningProvider.isRunning)
                Positioned(
                  top: 60,
                  left: MediaQuery.of(context).size.width * 0.2,
                  right: MediaQuery.of(context).size.width * 0.2,
                  child: ModeSelector(
                    currentMode: runningProvider.currentMode,
                    onModeChanged: (mode) => runningProvider.switchMode(mode),
                  ),
                ),

              // Navigation Info Card
              if (runningProvider.isNavigating &&
                  runningProvider.selectedTerritory != null &&
                  !runningProvider.hasArrivedAtStartPoint)
                Positioned(
                  top: 115,
                  left: 0,
                  right: 0,
                  child: NavigationSection(
                    selectedTerritory: runningProvider.selectedTerritory!,
                    distanceText: runningProvider.distanceText,
                    durationText: runningProvider.durationText,
                    isLoadingRoute: runningProvider.isLoadingRoute,
                    onStop: () => runningProvider.stopNavigation(),
                    onStartRunning: () => _handleStartRunning(runningProvider),
                  ),
                ),

              // Territory List Shimmer (Loading)
              if (runningProvider.isTerritoryMode &&
                  !runningProvider.isNavigating &&
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
                      itemCount: 3,
                      itemBuilder: (context, index) => const TerritoryCardShimmer(),
                    ),
                  ),
                ),

              // Territory List Carousel
              if (runningProvider.isTerritoryMode &&
                  !runningProvider.isNavigating &&
                  !runningProvider.isLoadingTerritories &&
                  runningProvider.territories.isNotEmpty)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: TerritoryListCarousel(
                    territories: runningProvider.territories,
                    selectedTerritory: runningProvider.selectedTerritory,
                    currentLocation: runningProvider.currentLatLng,
                    onTerritorySelected: (territory) => runningProvider.selectTerritory(territory),
                    onNavigate: (territory) {
                      final index = runningProvider.territories.indexOf(territory);
                      _handleTerritoryNavigate(runningProvider, index);
                    },
                    mapController: mapController,
                  ),
                ),

              // PLAN ROUTE BUTTON (Top) - REMOVED since it's merged into the bottom button
              // But we keep the Clear button if a route exists
              if (runningProvider.isLandmarkMode && !runningProvider.isRunning && landmarkProvider.hasPlannedRoute)
                Positioned(
                  top: 130,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: TextButton.icon(
                      onPressed: () => landmarkProvider.clearPlannedRoute(),
                      icon: const Icon(Icons.clear, size: 16, color: Colors.red),
                      label: const Text(
                        'Clear Planned Route',
                        style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Colors.red, width: 1),
                        ),
                      ),
                    ),
                  ),
                ),

              // DYNAMIC LANDMARK BUTTON (Bottom)
              if (runningProvider.isLandmarkMode &&
                  !runningProvider.isRunning &&
                  !runningProvider.isNavigating)
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: StartLandmarkButton(
                    title: landmarkProvider.hasPlannedRoute ? 'Start Landmark Run' : 'Plan Landmark Route',
                    subtitle: landmarkProvider.hasPlannedRoute ? 'Follow your ghost route' : 'Draw your path on the map',
                    icon: landmarkProvider.hasPlannedRoute ? Icons.play_arrow_rounded : Icons.add_road_rounded,
                    onPressed: landmarkProvider.hasPlannedRoute ? _handleStartLandmarkRun : _openRoutePlanner,
                  ),
                ),

              // Map Controls (Now on the Right)
              Positioned(
                bottom: runningProvider.isNavigating || runningProvider.isLandmarkMode ? 180 : 240,
                right: 20, // Moved to right
                child: MapControls(
                  onZoomIn: _zoomIn,
                  onZoomOut: _zoomOut,
                  onRecenter: _recenterMap,
                ),
              ),

              // Start Run Button (when arrived at start point)
              if (runningProvider.isNavigating && runningProvider.hasArrivedAtStartPoint)
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: StartRunButton(
                    onPressed: () => _handleStartRunAtPoint(runningProvider),
                  ),
                ),

              // Error Message
              if (runningProvider.error != null)
                Positioned(
                  top: runningProvider.isNavigating ? 250 : 120,
                  child: _buildErrorBadge(),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingOverlay(RunningProvider provider) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Colors.blue,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                provider.isLoadingTerritories
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
      ),
    );
  }

  Widget _buildErrorBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade600, Colors.orange.shade700],
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
          Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
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
    );
  }
}
