import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:turun/data/providers/running/running_provider.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:gap/gap.dart';
import 'run_completion_screen.dart';

class RunTrackingScreen extends StatefulWidget {
  const RunTrackingScreen({super.key});

  @override
  State<RunTrackingScreen> createState() => _RunTrackingScreenState();
}

class _RunTrackingScreenState extends State<RunTrackingScreen> {
  GoogleMapController? _mapController;
  Timer? _uiUpdateTimer;
  bool _isStatsExpanded = false; // For expandable stats

  @override
  void initState() {
    super.initState();
    // Update UI every second for live metrics
    _uiUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
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
      body: Consumer<RunningProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              // Map showing run route
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: provider.currentLatLng ?? const LatLng(1.18376, 104.01703),
                  zoom: 17.0,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
                tiltGesturesEnabled: false,
                rotateGesturesEnabled: false,
                polygons: provider.polygons,
                polylines: provider.runRoutePolylines,
              ),

              // Gradient overlay at top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Top stats card
              SafeArea(
                child: Column(
                  children: [
                    // Header with territory name
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: AppColors.blueGradient,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.flag,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const Gap(12),
                            Text(
                              provider.selectedTerritory?.name ??
                                  'Territory ${provider.selectedTerritory?.id}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.deepBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Main metrics card
                    Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Duration - Big display
                          Text(
                            _formatDuration(provider.runDuration),
                            style: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..shader = AppColors.blueGradient.createShader(
                                  const Rect.fromLTWH(0, 0, 300, 100),
                                ),
                              letterSpacing: -2,
                            ),
                          ),

                          const Gap(8),

                          Text(
                            'Duration',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const Gap(24),

                          // Distance and Pace
                          Row(
                            children: [
                              Expanded(
                                child: _MetricCard(
                                  icon: Icons.straighten_rounded,
                                  label: 'Distance',
                                  value: _formatDistance(provider.runDistance),
                                  color: AppColors.blueLogo,
                                ),
                              ),
                              const Gap(16),
                              Expanded(
                                child: _MetricCard(
                                  icon: Icons.speed_rounded,
                                  label: 'Pace',
                                  value: '${_formatPace(provider.currentPace)}/km',
                                  color: AppColors.cyan,
                                ),
                              ),
                            ],
                          ),

                          const Gap(16),

                          // Current Speed
                          _MetricCard(
                            icon: Icons.directions_run_rounded,
                            label: 'Current Speed',
                            value: '${(provider.currentSpeed * 3.6).toStringAsFixed(1)} km/h',
                            color: AppColors.greenLunatic,
                            isWide: true,
                          ),
                        ],
                      ),
                    ),

                    const Gap(20),

                    // Control buttons
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Pause/Resume button
                          _ControlButton(
                            icon: provider.activeRunSession?.status.name == 'active'
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            label: provider.activeRunSession?.status.name == 'active'
                                ? 'Pause'
                                : 'Resume',
                            color: AppColors.yellow[500]!,
                            onTap: () {
                              if (provider.activeRunSession?.status.name == 'active') {
                                provider.pauseRunSession();
                              } else {
                                provider.resumeRunSession();
                              }
                            },
                          ),

                          // Finish button
                          _ControlButton(
                            icon: Icons.check_circle_rounded,
                            label: 'Finish',
                            color: AppColors.green[500]!,
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Finish Run?'),
                                  content: const Text(
                                    'Are you sure you want to finish this run?',
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.green[500],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text('Finish'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true && mounted) {
                                final result = await provider.completeRunSession();
                                if (result != null && mounted) {
                                  // Navigate to completion screen
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RunCompletionScreen(
                                        session: result,
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          ),

                          // Cancel button
                          _ControlButton(
                            icon: Icons.close_rounded,
                            label: 'Cancel',
                            color: AppColors.red[500]!,
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Cancel Run?'),
                                  content: const Text(
                                    'Are you sure? This will discard your progress.',
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('No'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.red[500],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
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
                            },
                          ),
                        ],
                      ),
                    ),

                    const Gap(30),
                  ],
                ),
              ),

              // Center location button
              Positioned(
                bottom: 200,
                right: 20,
                child: Material(
                  elevation: 5,
                  shape: const CircleBorder(),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(
                        Icons.my_location_rounded,
                        color: AppColors.blueLogo,
                        size: 22,
                      ),
                      onPressed: () {
                        if (provider.currentLatLng != null) {
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLngZoom(
                              provider.currentLatLng!,
                              17.0,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Metric Card Widget
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isWide;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: isWide
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 20,
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Gap(12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
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
                  textAlign: TextAlign.center,
                ),
              ],
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
              color: color.withValues(alpha: 0.3),
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
                color: color.withValues(alpha: 0.15),
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

