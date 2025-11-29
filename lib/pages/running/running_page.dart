import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:turun/resources/values_app.dart';
import '../../data/providers/running/running_provider.dart';

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
      _currentMapType = _currentMapType == MapType.normal 
          ? MapType.hybrid 
          : MapType.normal;
    });
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
                // Tampilkan polygons dari territories
                polygons: runningProvider.polygons,
              ),

              // Loading overlay
              if (runningProvider.isLoading || runningProvider.isLoadingTerritories)
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

              // Mode selector (Game/Solo)
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

              // Territory info badge (optional)
              if (!runningProvider.isLoadingTerritories && 
                  runningProvider.territories.isNotEmpty)
                Positioned(
                  top: 115,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.grid_on,
                          size: 16,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${runningProvider.territories.length} territories',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // START Button
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
                            // Check nearby territories
                            final nearbyTerritories = runningProvider
                                .getTerritoriesNear(
                                    runningProvider.currentLatLng!, 
                                    0.5); // 500m radius
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Found ${nearbyTerritories.length} territories nearby',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            
                            // TODO: Navigate to running session
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

              // Map type toggle button
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

              // Center to current location button
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

              // Error message
              if (runningProvider.error != null)
                Positioned(
                  top: 120,
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
    super.dispose();
  }
}