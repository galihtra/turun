import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:turun/data/providers/landmark/landmark_provider.dart';
import 'package:turun/data/providers/running/running_provider.dart';
import 'package:turun/resources/colors_app.dart';
import 'widgets/planning_dialogs.dart';

class LandmarkRoutePlannerScreen extends StatefulWidget {
  const LandmarkRoutePlannerScreen({super.key});

  @override
  State<LandmarkRoutePlannerScreen> createState() =>
      _LandmarkRoutePlannerScreenState();
}

class _LandmarkRoutePlannerScreenState
    extends State<LandmarkRoutePlannerScreen> {
  GoogleMapController? _mapController;
  final List<LatLng> _points = [];
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  double _totalDistance = 0;

  @override
  void initState() {
    super.initState();
    final provider = context.read<LandmarkProvider>();
    if (provider.hasPlannedRoute) {
      _points.addAll(provider.plannedRoutePoints);
      _updateMapElements();
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    final runningProvider = context.read<RunningProvider>();
    if (runningProvider.currentLatLng != null && _points.isEmpty) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(runningProvider.currentLatLng!, 16),
      );
    } else if (_points.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _zoomToBounds();
      });
    }
  }

  void _onMapTap(LatLng point) {
    setState(() {
      _points.add(point);
      _updateMapElements();
    });
  }

  void _undoLastPoint() {
    if (_points.isNotEmpty) {
      setState(() {
        _points.removeLast();
        _updateMapElements();
      });
    }
  }

  Future<void> _clearRoute() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Route?'),
        content: const Text('This will remove all points you have placed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _points.clear();
        _updateMapElements();
      });
    }
  }

  void _updateMapElements() {
    _markers.clear();
    _polylines.clear();
    _totalDistance = 0;

    if (_points.isEmpty) return;

    // Start Marker
    _markers.add(
      Marker(
        markerId: const MarkerId('start'),
        position: _points.first,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Start Point'),
      ),
    );

    // End Marker
    if (_points.length > 1) {
      _markers.add(
        Marker(
          markerId: const MarkerId('end'),
          position: _points.last,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'End Point'),
        ),
      );

      // Polyline
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('planned_route'),
          points: _points,
          color: AppColors.blueLogo,
          width: 5,
          jointType: JointType.round,
          patterns: [
            PatternItem.dash(30),
            PatternItem.gap(10),
          ],
        ),
      );

      // Distance Calculation
      for (int i = 0; i < _points.length - 1; i++) {
        _totalDistance += Geolocator.distanceBetween(
          _points[i].latitude,
          _points[i].longitude,
          _points[i + 1].latitude,
          _points[i + 1].longitude,
        );
      }
    }
  }

  void _zoomToBounds() {
    if (_points.isEmpty || _mapController == null) return;

    if (_points.length == 1) {
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(_points.first, 16));
      return;
    }

    double minLat = _points.first.latitude;
    double maxLat = _points.first.latitude;
    double minLng = _points.first.longitude;
    double maxLng = _points.first.longitude;

    for (var point in _points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        80, // padding
      ),
    );
  }

  void _recenterOnUser() {
    final runningProvider = context.read<RunningProvider>();
    if (runningProvider.currentLatLng != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(runningProvider.currentLatLng!, 16),
      );
    }
  }

  void _zoomIn() async {
    if (_mapController != null) {
      final zoom = await _mapController!.getZoomLevel();
      _mapController!.animateCamera(CameraUpdate.zoomTo(zoom + 1));
    }
  }

  void _zoomOut() async {
    if (_mapController != null) {
      final zoom = await _mapController!.getZoomLevel();
      _mapController!.animateCamera(CameraUpdate.zoomTo(zoom - 1));
    }
  }

  Future<void> _saveRoute() async {
    if (_points.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least 2 points to create a route')),
      );
      return;
    }

    if (_totalDistance < 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Route is too short (${_totalDistance.toStringAsFixed(0)}m). Min: 500m.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ✅ NEW: Check for territory overlap
    final provider = context.read<LandmarkProvider>();
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final overlapTerritory = await provider.checkRouteOverlap(_points);
    
    // Close loading indicator
    if (mounted) Navigator.pop(context);

    if (overlapTerritory != null && mounted) {
      // Show cool gamified warning
      PlanningDialogs.showOverlapWarning(context, overlapTerritory);
      return;
    }

    if (mounted) {
      provider.setPlannedRoute(_points);
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Excellent! Your route plan is ready.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRouteValid = _points.length >= 2 && _totalDistance >= 500;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Route Planner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (_points.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
              onPressed: _clearRoute,
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 16,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onTap: _onMapTap,
            markers: _markers,
            polylines: _polylines,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          
          // Map Controls (Zoom & My Location)
          Positioned(
            right: 16,
            bottom: 120, // Positioned above the controls panel
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Zoom In
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  onPressed: _zoomIn,
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.blueLogo,
                  child: const Icon(Icons.add_rounded),
                ),
                const SizedBox(height: 12),
                // Zoom Out
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  onPressed: _zoomOut,
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.blueLogo,
                  child: const Icon(Icons.remove_rounded),
                ),
                const SizedBox(height: 12),
                // My Location
                FloatingActionButton.small(
                  heroTag: 'recenter',
                  onPressed: _recenterOnUser,
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.blueLogo,
                  child: const Icon(Icons.my_location_rounded),
                ),
              ],
            ),
          ),

          // Dynamic Instruction Overlay
          Positioned(
            top: 20,
            left: 50,
            right: 50,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: 1.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _points.isEmpty 
                    ? 'Tap map to start your route'
                    : _points.length == 1
                      ? 'Add another point'
                      : _totalDistance < 500
                        ? 'Keep going! (Needs 500m min)'
                        : 'Route ready to use!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          
          // Controls Panel
          Positioned(
            left: 16,
            right: 16,
            bottom: 30,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Planned Distance',
                            style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _totalDistance >= 1000
                                ? '${(_totalDistance / 1000).toStringAsFixed(2)} KM'
                                : '${_totalDistance.toStringAsFixed(0)} M',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isRouteValid ? Colors.green : AppColors.blueLogo,
                            ),
                          ),
                        ],
                      ),
                      
                      // Undo Button
                      Material(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: _points.isEmpty ? null : _undoLastPoint,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              Icons.undo_rounded,
                              color: _points.isEmpty ? Colors.grey : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isRouteValid ? _saveRoute : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueLogo,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isRouteValid ? 'Confirm Route' : 'Route too short',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
