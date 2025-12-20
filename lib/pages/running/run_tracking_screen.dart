import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:turun/data/providers/running/running_provider.dart';
import 'package:turun/data/providers/user/user_provider.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:gap/gap.dart';
import 'run_completion_screen.dart';

class RunTrackingScreen extends StatefulWidget {
  const RunTrackingScreen({super.key});

  @override
  State<RunTrackingScreen> createState() => _RunTrackingScreenState();
}

class _RunTrackingScreenState extends State<RunTrackingScreen> with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  Timer? _uiUpdateTimer;
  bool _hasNavigatedToCompletion = false;
  double _currentZoom = 17.0;

  // Draggable sheet controller
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  double _sheetSize = 0.25;
  final double _minSheetSize = 0.25;
  final double _maxSheetSize = 0.7;

  @override
  void initState() {
    super.initState();
    // Update UI every second for live metrics and check for auto-finish
    _uiUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    if (provider.runCompleted && provider.activeRunSession != null && !provider.isRunning) {
      _hasNavigatedToCompletion = true;
      
      // Navigate to completion screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && provider.activeRunSession != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RunCompletionScreen(session: provider.activeRunSession!),
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
        CameraUpdate.newLatLngZoom(provider.currentLatLng!, 17.0),
      );
    }
  }

  void _zoomIn() {
    if (_mapController != null) {
      setState(() {
        _currentZoom = (_currentZoom + 1).clamp(0, 21);
      });
      _mapController!.animateCamera(
        CameraUpdate.zoomTo(_currentZoom),
      );
    }
  }

  void _zoomOut() {
    if (_mapController != null) {
      setState(() {
        _currentZoom = (_currentZoom - 1).clamp(0, 21);
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
          17.0,
        ),
      );
      setState(() {
        _currentZoom = 17.0;
      });
    }
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    }
    return '${(meters / 1000).toStringAsFixed(2)} km';
  }

  String _formatPace(double paceMinPerKm) {
    if (paceMinPerKm == 0 || paceMinPerKm.isInfinite) return "--'--\"";
    final minutes = paceMinPerKm.floor();
    final seconds = ((paceMinPerKm - minutes) * 60).round();
    return "$minutes'${seconds.toString().padLeft(2, '0')}\"";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<RunningProvider, UserProvider>(
        builder: (context, runProvider, userProvider, child) {
          // Get user's profile color for route polyline
          final userColor = _parseColor(userProvider.currentUser?.profileColor);

          // ✅ Calculate coins collected and total
          final totalCoins = (runProvider.selectedTerritory?.points.length ?? 1) - 1;
          final coinsCollected = (runProvider.currentCheckpointIndex - 1).clamp(0, totalCoins);
          final allCoinsCollected = coinsCollected >= totalCoins;

          return Stack(
            children: [
              // Map showing run route
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: runProvider.currentLatLng ?? const LatLng(1.18376, 104.01703),
                  zoom: 17.0,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
                tiltGesturesEnabled: false,
                rotateGesturesEnabled: false,
                polygons: runProvider.polygons,
                polylines: _buildAllPolylines(runProvider, userColor),
                markers: runProvider.runMarkers,
              ),

              // Top territory name badge
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
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
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: userColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.flag_rounded,
                            color: userColor,
                            size: 14,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          runProvider.selectedTerritory?.name ??
                              'Territory ${runProvider.selectedTerritory?.id}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: userColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ✅ "Return to START" banner when all coins collected
              if (allCoinsCollected && runProvider.isRunning)
                Positioned(
                  top: 100,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade600, Colors.green.shade800],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.emoji_events_rounded,
                            color: Colors.amber,
                            size: 24,
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '🎉 All Coins Collected!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                'Return to START to finish the run',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),

              // Zoom controls and recenter button
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.3,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Zoom In Button
                    Material(
                      elevation: 4,
                      shape: const CircleBorder(),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: Icon(
                            Icons.add_rounded,
                            color: userColor,
                            size: 20,
                          ),
                          onPressed: _zoomIn,
                          tooltip: 'Zoom In',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Zoom Out Button
                    Material(
                      elevation: 4,
                      shape: const CircleBorder(),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: Icon(
                            Icons.remove_rounded,
                            color: userColor,
                            size: 20,
                          ),
                          onPressed: _zoomOut,
                          tooltip: 'Zoom Out',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Recenter Button
                    Material(
                      elevation: 4,
                      shape: const CircleBorder(),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: Icon(
                            Icons.my_location_rounded,
                            color: userColor,
                            size: 20,
                          ),
                          onPressed: _recenterMap,
                          tooltip: 'Recenter Map',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Draggable bottom sheet with stats
              DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: _minSheetSize,
                minChildSize: _minSheetSize,
                maxChildSize: _maxSheetSize,
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
                            color: Colors.black.withOpacity(0.15),
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
                            child: _buildStatsContent(runProvider, userColor, coinsCollected, totalCoins),
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

  // Build stats content based on sheet size
  Widget _buildStatsContent(RunningProvider provider, Color userColor, int coinsCollected, int totalCoins) {
    final isExpanded = _sheetSize > 0.4;
    final allCoinsCollected = coinsCollected >= totalCoins;

    if (!isExpanded) {
      // COLLAPSED: Compact horizontal stats
      return Column(
        children: [
          // Route progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (allCoinsCollected) ...[
                          const Gap(8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '✓ Complete!',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '$coinsCollected / $totalCoins coins',
                      style: TextStyle(
                        fontSize: 10,
                        color: allCoinsCollected ? Colors.green : userColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: provider.routeProgress / 100,
                    minHeight: 6,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      allCoinsCollected ? Colors.green : userColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),

          // Compact metrics row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CompactMetric(
                label: 'Duration',
                value: _formatDuration(provider.runDuration),
                color: userColor,
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              _CompactMetric(
                label: 'Distance',
                value: _formatDistance(provider.runDistance),
                color: userColor,
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              _CompactMetric(
                label: 'Pace',
                value: _formatPace(provider.currentPace),
                color: userColor,
              ),
            ],
          ),
          const Gap(16),
          // Control buttons (compact)
          _buildCompactControls(provider, userColor),
          const Gap(12),
        ],
      );
    } else {
      // EXPANDED: Full detailed stats
      return Column(
        children: [
          // Route progress (with coin counter)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: allCoinsCollected 
                  ? Colors.green.shade50 
                  : userColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: allCoinsCollected 
                    ? Colors.green.withOpacity(0.3) 
                    : userColor.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          allCoinsCollected 
                              ? Icons.emoji_events_rounded 
                              : Icons.monetization_on_rounded,
                          color: allCoinsCollected ? Colors.amber : userColor,
                          size: 20,
                        ),
                        const Gap(8),
                        Text(
                          allCoinsCollected ? 'All Coins Collected!' : 'Coins Collected',
                          style: TextStyle(
                            fontSize: 12,
                            color: allCoinsCollected 
                                ? Colors.green.shade700 
                                : Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: allCoinsCollected 
                            ? Colors.green 
                            : userColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$coinsCollected / $totalCoins',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: provider.routeProgress / 100,
                    minHeight: 10,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      allCoinsCollected ? Colors.green : userColor,
                    ),
                  ),
                ),
                if (allCoinsCollected) ...[
                  const Gap(10),
                  Text(
                    '🏁 Return to START to finish!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Big duration display
          Text(
            _formatDuration(provider.runDuration),
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: userColor,
              letterSpacing: -2,
            ),
          ),
          Text(
            'Duration',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(24),

          // Detailed metrics grid
          Row(
            children: [
              Expanded(
                child: _DetailedMetricCard(
                  icon: Icons.straighten_rounded,
                  label: 'Distance',
                  value: _formatDistance(provider.runDistance),
                  color: userColor,
                ),
              ),
              const Gap(12),
              Expanded(
                child: _DetailedMetricCard(
                  icon: Icons.speed_rounded,
                  label: 'Pace',
                  value: '${_formatPace(provider.currentPace)}/km',
                  color: userColor,
                ),
              ),
            ],
          ),
          const Gap(12),
          _DetailedMetricCard(
            icon: Icons.directions_run_rounded,
            label: 'Current Speed',
            value: '${(provider.currentSpeed * 3.6).toStringAsFixed(1)} km/h',
            color: userColor,
            isWide: true,
          ),
          const Gap(24),

          // Control buttons (expanded)
          _buildExpandedControls(provider, userColor),
          const Gap(20),
        ],
      );
    }
  }

  // Build compact control buttons
  Widget _buildCompactControls(RunningProvider provider, Color userColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _CompactButton(
          icon: provider.activeRunSession?.status.name == 'active'
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          color: AppColors.yellow[500]!,
          onTap: () {
            if (provider.activeRunSession?.status.name == 'active') {
              provider.pauseRunSession();
            } else {
              provider.resumeRunSession();
            }
          },
        ),
        _CompactButton(
          icon: Icons.check_circle_rounded,
          color: AppColors.green[500]!,
          onTap: () => _handleFinishRun(provider),
        ),
        _CompactButton(
          icon: Icons.close_rounded,
          color: AppColors.red[500]!,
          onTap: () => _handleCancelRun(provider),
        ),
      ],
    );
  }

  // Build expanded control buttons
  Widget _buildExpandedControls(RunningProvider provider, Color userColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ControlButton(
          icon: provider.activeRunSession?.status.name == 'active'
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          label: provider.activeRunSession?.status.name == 'active' ? 'Pause' : 'Resume',
          color: AppColors.yellow[500]!,
          onTap: () {
            if (provider.activeRunSession?.status.name == 'active') {
              provider.pauseRunSession();
            } else {
              provider.resumeRunSession();
            }
          },
        ),
        _ControlButton(
          icon: Icons.check_circle_rounded,
          label: 'Finish',
          color: AppColors.green[500]!,
          onTap: () => _handleFinishRun(provider),
        ),
        _ControlButton(
          icon: Icons.close_rounded,
          label: 'Cancel',
          color: AppColors.red[500]!,
          onTap: () => _handleCancelRun(provider),
        ),
      ],
    );
  }

  Future<void> _handleFinishRun(RunningProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish Run?'),
        content: const Text('Are you sure you want to finish this run?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green[500],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Finish'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
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

  Future<void> _handleCancelRun(RunningProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Run?'),
        content: const Text('Are you sure? This will discard your progress.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red[500],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      provider.cancelRunSession();
      Navigator.pop(context);
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
          widthParam: 6,
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

// Compact Metric Widget
class _CompactMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _CompactMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const Gap(4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Detailed Metric Card
class _DetailedMetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isWide;

  const _DetailedMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: isWide
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Gap(10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }
}

// Compact Button Widget
class _CompactButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CompactButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 26,
        ),
      ),
    );
  }
}

// Control Button Widget
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const Gap(8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}