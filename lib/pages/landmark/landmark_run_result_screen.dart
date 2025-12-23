import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turun/data/model/running/run_session_model.dart';
import 'package:turun/data/providers/landmark/landmark_provider.dart';
import 'package:turun/resources/colors_app.dart';
import 'create_landmark_screen.dart';

/// Screen to display landmark run results and validation
class LandmarkRunResultScreen extends StatelessWidget {
  final RunSession session;

  const LandmarkRunResultScreen({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final landmarkProvider = context.watch<LandmarkProvider>();
    final isValid = landmarkProvider.totalDistance >= LandmarkProvider.minDistanceMeters;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isValid
                ? [
                    const Color(0xFF00E676),
                    const Color(0xFF00C853),
                  ]
                : [
                    Colors.orange.shade400,
                    Colors.orange.shade600,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Text(
                      isValid ? 'Run Completed!' : 'Run Too Short',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Result Icon
              const SizedBox(height: 40),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isValid ? Icons.check_circle : Icons.warning_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              // Status Message
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  isValid
                      ? 'Great job! Your run is eligible to become a landmark.'
                      : 'Your run is too short to create a landmark. Minimum distance is ${LandmarkProvider.minDistanceMeters}m.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Stats Cards
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        // Stats Grid
                        _buildStatCard(
                          'Distance',
                          landmarkProvider.formattedDistance,
                          Icons.straighten,
                          isValid ? AppColors.green[500]! : Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          'Duration',
                          landmarkProvider.formattedDuration,
                          Icons.timer,
                          AppColors.blue[500]!,
                        ),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          'Pace',
                          _formatPace(landmarkProvider.currentPace),
                          Icons.speed,
                          AppColors.purple[500]!,
                        ),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          'Calories',
                          '${session.caloriesBurned} kcal',
                          Icons.local_fire_department,
                          AppColors.red[500]!,
                        ),

                        if (isValid) ...[
                          const SizedBox(height: 40),

                          // Progress Bar
                          _buildProgressIndicator(landmarkProvider.totalDistance),

                          const SizedBox(height: 40),

                          // Create Landmark Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CreateLandmarkScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00E676),
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shadowColor: const Color(0xFF00E676).withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_location_alt, size: 24),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Create Landmark',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 40),

                          // Try Again Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shadowColor: Colors.orange.withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Try Again',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Skip Button
                        TextButton(
                          onPressed: () {
                            Navigator.popUntil(context, (route) => route.isFirst);
                          },
                          child: const Text(
                            'Back to Home',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(double distance) {
    final progress = (distance / LandmarkProvider.minDistanceMeters).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Minimum Distance',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                color: AppColors.green[500],
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.green[500]!),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${distance.toStringAsFixed(0)}m / ${LandmarkProvider.minDistanceMeters.toInt()}m',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatPace(double pace) {
    if (pace <= 0) return "0'00\"";
    final paceMinutes = pace.floor();
    final paceSeconds = ((pace - paceMinutes) * 60).round();
    return "$paceMinutes'${paceSeconds.toString().padLeft(2, '0')}\"";
  }
}
