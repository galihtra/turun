import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:turun/data/providers/running/running_provider.dart';
import 'package:turun/data/providers/landmark/landmark_provider.dart';
import 'package:turun/data/providers/user/user_provider.dart';
import 'package:turun/resources/colors_app.dart';
import 'run_completion_screen.dart';
import '../landmark/landmark_run_result_screen.dart';
import 'widgets/run_stats_panel.dart';
import 'widgets/progress_banner.dart';
import 'widgets/territory_badge.dart';
import 'widgets/map_controls.dart';
import 'utils/run_dialogs.dart';
import 'constants/run_constants.dart';

class RunTrackingScreen extends StatefulWidget {
  const RunTrackingScreen({super.key});

  @override
  State<RunTrackingScreen> createState() => _RunTrackingScreenState();
}

class _RunTrackingScreenState extends State<RunTrackingScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  Timer? _uiUpdateTimer;
  bool _hasNavigatedToCompletion = false;
  double _currentZoom = RunConstants.defaultZoom;

  // Draggable sheet controller
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  double _sheetSize = RunConstants.minSheetSize;

  @override
  void initState() {
    super.initState();
    // Update UI every second for live metrics and check for auto-finish
    _uiUpdateTimer = Timer.periodic(RunConstants.uiUpdateInterval, (timer) {
      if (mounted) {
        setState(() {});
        _checkAutoFinish();
      }
    });
  }

  /// Check if run was auto-finished and navigate to completion screen
  void _checkAutoFinish() {
    if (_hasNavigatedToCompletion) return;

    final provider = context.read<RunningProvider>();

    // ✅ Check both runCompleted flag AND if we have a completed session
    if (provider.runCompleted &&
        provider.activeRunSession != null &&
        !provider.isRunning) {
      _hasNavigatedToCompletion = true;

      // Navigate to completion screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && provider.activeRunSession != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RunCompletionScreen(session: provider.activeRunSession!),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _uiUpdateTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    final provider = context.read<RunningProvider>();
    if (provider.currentLatLng != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
            provider.currentLatLng!, RunConstants.defaultZoom),
      );
    }
  }

  void _zoomIn() {
    if (_mapController != null) {
      setState(() {
        _currentZoom = (_currentZoom + 1)
            .clamp(RunConstants.minZoom, RunConstants.maxZoom);
      });
      _mapController!.animateCamera(
        CameraUpdate.zoomTo(_currentZoom),
      );
    }
  }

  void _zoomOut() {
    if (_mapController != null) {
      setState(() {
        _currentZoom = (_currentZoom - 1)
            .clamp(RunConstants.minZoom, RunConstants.maxZoom);
      });
      _mapController!.animateCamera(
        CameraUpdate.zoomTo(_currentZoom),
      );
    }
  }

  void _recenterMap() {
    final provider = context.read<RunningProvider>();
    if (provider.currentLatLng != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          provider.currentLatLng!,
          RunConstants.defaultZoom,
        ),
      );
      setState(() {
        _currentZoom = RunConstants.defaultZoom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer3<RunningProvider, LandmarkProvider, UserProvider>(
        builder: (context, runProvider, landmarkProvider, userProvider, child) {
          // Get user's profile color for route polyline
          final userColor = _parseColor(userProvider.currentUser?.profileColor);

          // Determine which provider to use based on mode
          final isLandmarkMode = runProvider.isLandmarkMode;

          // ✅ Calculate coins collected and total (only for territory mode)
          // For landmark mode, these values are not used (no checkpoints)
          final totalCoins = isLandmarkMode
              ? 0
              : (runProvider.selectedTerritory?.points.length ?? 1) - 1;
          final coinsCollected = isLandmarkMode
              ? 0
              : (runProvider.currentCheckpointIndex - 1).clamp(0, totalCoins);
          final allCoinsCollected =
              !isLandmarkMode && coinsCollected >= totalCoins;

          return Stack(
            children: [
              // Map showing run route
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: runProvider.currentLatLng ??
                      const LatLng(1.18376, 104.01703),
                  zoom: RunConstants.defaultZoom,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
                tiltGesturesEnabled: false,
                rotateGesturesEnabled: false,
                polygons: isLandmarkMode ? {} : runProvider.polygons,
                polylines: isLandmarkMode
                    ? landmarkProvider.routePolylines
                    : _buildAllPolylines(runProvider, userColor),
                markers: isLandmarkMode
                    ? landmarkProvider.markers
                    : runProvider.runMarkers,
              ),

              // Top territory name badge
              TerritoryBadge(
                isLandmarkMode: isLandmarkMode,
                territoryName: runProvider.selectedTerritory?.name ??
                    'Territory ${runProvider.selectedTerritory?.id}',
                userColor: userColor,
              ),

              // ✅ "Return to START" banner when all coins collected
              if (allCoinsCollected && runProvider.isRunning)
                const ProgressBanner(),

              // Zoom controls and recenter button
              MapControls(
                onZoomIn: _zoomIn,
                onZoomOut: _zoomOut,
                onRecenter: _recenterMap,
              ),

              // Draggable bottom sheet with stats
              DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: RunConstants.minSheetSize,
                minChildSize: RunConstants.minSheetSize,
                maxChildSize: RunConstants.maxSheetSize,
                builder: (context, scrollController) {
                  return NotificationListener<DraggableScrollableNotification>(
                    onNotification: (notification) {
                      setState(() {
                        _sheetSize = notification.extent;
                      });
                      return true;
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: ListView(
                        controller: scrollController,
                        padding: EdgeInsets.zero,
                        children: [
                          // Drag handle
                          Center(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 12),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),

                          // Stats content
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: RunStatsPanel(
                              sheetSize: _sheetSize,
                              runProvider: runProvider,
                              landmarkProvider: landmarkProvider,
                              isLandmarkMode: isLandmarkMode,
                              userColor: userColor,
                              coinsCollected: coinsCollected,
                              totalCoins: totalCoins,
                              onPauseResume: () => _handlePauseResume(runProvider),
                              onFinish: () => _handleFinishRun(runProvider),
                              onCancel: () => _handleCancelRun(runProvider),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _handlePauseResume(RunningProvider provider) {
    if (provider.activeRunSession?.status.name == 'active') {
      provider.pauseRunSession();
    } else {
      provider.resumeRunSession();
    }
  }

  Future<void> _handleFinishRun(RunningProvider provider) async {
    final confirm = await RunDialogs.showFinishConfirmation(context);

    if (confirm == true && mounted) {
      // Handle finish based on mode
      if (provider.isLandmarkMode) {
        final landmarkProvider = context.read<LandmarkProvider>();
        final session = await landmarkProvider.completeLandmarkRun();
        if (mounted && session != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LandmarkRunResultScreen(session: session),
            ),
          );
        }
      } else {
        final result = await provider.completeRunSession();
        if (result != null && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RunCompletionScreen(session: result),
            ),
          );
        }
      }
    }
  }

  Future<void> _handleCancelRun(RunningProvider provider) async {
    final confirm = await RunDialogs.showCancelConfirmation(context);

    if (confirm == true && mounted) {
      // Handle cancel based on mode
      if (provider.isLandmarkMode) {
        final landmarkProvider = context.read<LandmarkProvider>();
        await landmarkProvider.cancelLandmarkRun();
      } else {
        provider.cancelRunSession();
      }
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  // Build all polylines: guidance + user's actual route
  Set<Polyline> _buildAllPolylines(RunningProvider provider, Color userColor) {
    final polylines = <Polyline>{};

    // 1. Territory guidance route
    polylines.addAll(provider.territoryGuidancePolylines);

    // 2. User's actual running path
    final userRoutePoints = provider.runRoutePolylines;
    for (var polyline in userRoutePoints) {
      polylines.add(
        polyline.copyWith(
          colorParam: userColor,
          widthParam: RunConstants.userRoutePolylineWidth,
        ),
      );
    }

    return polylines;
  }

  // Parse color from hex string
  Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) {
      return AppColors.blueLogo;
    }

    try {
      final hexColor = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    } catch (e) {
      return AppColors.blueLogo;
    }
  }
}
