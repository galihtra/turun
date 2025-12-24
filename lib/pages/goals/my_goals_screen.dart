import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turun/data/model/running/run_session_model.dart';
import 'package:turun/data/providers/goals/goal_provider.dart';
import 'package:turun/pages/goals/goal_setting_screen.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:intl/intl.dart';

class MyGoalsScreen extends StatefulWidget {
  const MyGoalsScreen({super.key});

  @override
  State<MyGoalsScreen> createState() => _MyGoalsScreenState();
}

class _MyGoalsScreenState extends State<MyGoalsScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<RunSession> _latestActivities = [];
  bool _isLoadingActivities = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalProvider>().loadActiveGoals();
      _loadLatestActivities();
    });
  }

  Future<void> _loadLatestActivities() async {
    setState(() => _isLoadingActivities = true);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('run_sessions')
          .select()
          .eq('user_id', userId)
          .eq('status', 'completed')
          .order('created_at', ascending: false)
          .limit(3);

      setState(() {
        _latestActivities = (response as List)
            .map((json) => RunSession.fromJson(json as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      // Handle error silently
    } finally {
      setState(() => _isLoadingActivities = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<GoalProvider>(
          builder: (context, goalProvider, child) {
            if (goalProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await goalProvider.loadActiveGoals();
                await _loadLatestActivities();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(),

                      const Gap(24),

                      // My Goals title with Goal Setting button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'My Goals',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D1B2A),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const GoalSettingScreen(),
                                ),
                              );
                              if (result == true && mounted) {
                                context.read<GoalProvider>().loadActiveGoals();
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0D1B2A),
                              side: const BorderSide(color: Color(0xFF0D1B2A), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: const Row(
                              children: [
                                Text(
                                  'Goal Setting',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Gap(4),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Gap(32),

                      // Circular Progress Goals
                      _buildCircularGoals(goalProvider),

                      const Gap(40),

                      // Latest Activities
                      _buildLatestActivities(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TuRun',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.blueLogo,
            letterSpacing: -0.5,
          ),
        ),
        const Gap(4),
        const Text(
          'Track, Unlocked, Run!',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildCircularGoals(GoalProvider goalProvider) {
    final distanceGoal = goalProvider.activeDistanceGoal;
    final caloriesGoal = goalProvider.activeCaloriesGoal;

    return Row(
      children: [
        // Distance Goal
        Expanded(
          child: _buildCircularGoal(
            label: 'Distance',
            subtitle: distanceGoal?.periodLabel ?? 'Today',
            currentValue: distanceGoal?.currentValue ?? 0.0,
            targetValue: distanceGoal?.targetValue ?? 20.0,
            unit: distanceGoal?.unit.name == 'km' ? 'Km' : 'Mile',
            color: const Color(0xFF2563EB), // Blue
            backgroundColor: const Color(0xFFDCE7F7),
          ),
        ),
        const Gap(24),
        // Calories Goal
        Expanded(
          child: _buildCircularGoal(
            label: 'Calories',
            subtitle: caloriesGoal?.periodLabel ?? 'Today',
            currentValue: caloriesGoal?.currentValue ?? 0.0,
            targetValue: caloriesGoal?.targetValue ?? 500.0,
            unit: 'kcal',
            color: const Color(0xFFFF6B6B), // Red
            backgroundColor: const Color(0xFFFFE5E5),
          ),
        ),
      ],
    );
  }

  Widget _buildCircularGoal({
    required String label,
    required String subtitle,
    required double currentValue,
    required double targetValue,
    required String unit,
    required Color color,
    required Color backgroundColor,
  }) {
    final progress = targetValue > 0 ? currentValue / targetValue : 0.0;

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          // Circular progress painter
          CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: CircularProgressPainter(
              progress: progress.clamp(0.0, 1.0),
              color: color,
              backgroundColor: backgroundColor,
              strokeWidth: 16,
            ),
          ),
          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Gap(4),
                Text(
                  currentValue.toStringAsFixed(unit == 'kcal' ? 0 : 1),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D1B2A),
                    height: 1.1,
                  ),
                ),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D1B2A),
                  ),
                ),
                const Gap(4),
                Text(
                  '/${targetValue.toStringAsFixed(0)} $unit',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Latest Activities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D1B2A),
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all activities
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'See all',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.blueLogo,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const Gap(16),

        if (_isLoadingActivities)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_latestActivities.isEmpty)
          _buildEmptyActivities()
        else
          ..._latestActivities.map((activity) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildActivityCard(activity),
              )),
      ],
    );
  }

  Widget _buildEmptyActivities() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.directions_run,
              size: 48,
              color: Colors.grey[400],
            ),
            const Gap(12),
            Text(
              'No activities yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const Gap(4),
            Text(
              'Start running to see your activities here',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(RunSession activity) {
    final dateFormat = DateFormat('dd MMMM yyyy HH:mm a');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Activity thumbnail with map icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                Icons.directions_run,
                color: AppColors.blueLogo,
                size: 36,
              ),
            ),
          ),
          const Gap(16),
          // Activity details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.territoryConquered ? 'Territory Run' : 'Morning Run',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D1B2A),
                  ),
                ),
                const Gap(4),
                Text(
                  dateFormat.format(activity.startTime),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const Gap(12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActivityStat(
                        'Distance',
                        activity.formattedDistance,
                      ),
                    ),
                    Expanded(
                      child: _buildActivityStat(
                        'Duration',
                        activity.formattedDuration,
                      ),
                    ),
                    Expanded(
                      child: _buildActivityStat(
                        'Avg Pace',
                        activity.formattedPace,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D1B2A),
          ),
        ),
      ],
    );
  }
}

// Custom painter for circular progress
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    this.strokeWidth = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - (strokeWidth / 2);

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2; // Start from top
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
