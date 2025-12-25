import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turun/data/model/running/run_session_model.dart';
import 'package:turun/data/providers/goals/goal_provider.dart';
import 'package:turun/data/providers/achievement/achievement_provider.dart';
import 'package:turun/pages/goals/goal_setting_screen.dart';
import 'package:turun/pages/achievements/achievements_page.dart';
import 'package:turun/pages/activities/all_activities_page.dart';
import 'package:turun/pages/activities/activity_detail_page.dart';
import 'package:turun/resources/colors_app.dart';

import '../../resources/styles_app.dart';
import '../../resources/values_app.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final SupabaseClient supabase = Supabase.instance.client;
  List<RunSession> _latestActivities = [];
  bool _isLoadingActivities = false;

  // Stats data
  int _currentStreak = 0;
  int _totalRuns = 0;
  double _totalDistance = 0.0;
  String _personalBest = '0:00';
  bool _isLoadingStats = false;

  late AnimationController _streakController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    _streakController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalProvider>().loadActiveGoals();
      context.read<AchievementProvider>().loadUserAchievements();
      _loadLatestActivities();
      _loadUserStats();

      // Start animations
      _streakController.forward();
      _progressController.forward();
    });
  }

  @override
  void dispose() {
    _streakController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserStats() async {
    setState(() => _isLoadingStats = true);

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Get all completed runs
      final response = await supabase
          .from('run_sessions')
          .select()
          .eq('user_id', userId)
          .eq('status', 'completed')
          .order('created_at', ascending: false);

      final runs = (response as List)
          .map((json) => RunSession.fromJson(json as Map<String, dynamic>))
          .toList();

      // Calculate stats
      _totalRuns = runs.length;
      _totalDistance = runs.fold(0.0, (sum, run) => sum + run.distanceKm);

      // Calculate streak
      _currentStreak = _calculateStreak(runs);

      // Get personal best (fastest pace)
      if (runs.isNotEmpty) {
        final fastest = runs.reduce((a, b) {
          return a.averagePaceMinPerKm < b.averagePaceMinPerKm ? a : b;
        });
        _personalBest = fastest.formattedPace;
      }
    } catch (e) {
      // Handle error silently
    } finally {
      setState(() => _isLoadingStats = false);
    }
  }

  int _calculateStreak(List<RunSession> runs) {
    if (runs.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();

    // Normalize to start of day
    currentDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    for (int i = 0; i < runs.length; i++) {
      final runDate = runs[i].startTime;
      final normalizedRunDate =
          DateTime(runDate.year, runDate.month, runDate.day);

      final difference = currentDate.difference(normalizedRunDate).inDays;

      if (difference == streak) {
        streak++;
      } else if (difference > streak) {
        break;
      }
    }

    return streak;
  }

  Future<void> _loadLatestActivities() async {
    setState(() => _isLoadingActivities = true);

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Consumer<GoalProvider>(
          builder: (context, goalProvider, child) {
            if (goalProvider.isLoading && _isLoadingStats) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await goalProvider.loadActiveGoals();
                await _loadLatestActivities();
                await _loadUserStats();
                _progressController.reset();
                _progressController.forward();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with gradient background
                    Center(
                      child: Text(
                        'TuRun',
                        style: AppStyles.titleLogo
                            .copyWith(fontSize: AppSizes.s26),
                      ),
                    ),
                    AppGaps.kGap6,
                    Center(
                      child: Text(
                        'Track, Unlocked, Run!',
                        style: AppStyles.body2Regular
                            .copyWith(color: Colors.grey.shade500),
                      ),
                    ),
                    // Main content
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Streak counter (prominent)
                          _buildStreakCard(),

                          const Gap(20),

                          // Quick stats row
                          _buildQuickStats(),

                          const Gap(28),

                          // Goals section
                          _buildGoalsSection(goalProvider),

                          const Gap(28),

                          // Achievement teaser
                          _buildAchievementTeaser(),

                          const Gap(28),

                          // Latest Activities
                          _buildLatestActivities(),

                          const Gap(20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (value * 0.1),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF6B6B),
                    Color(0xFFFF8E53),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative elements
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -30,
                    bottom: -30,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.local_fire_department,
                            color: _currentStreak > 0
                                ? const Color(0xFFFFD700)
                                : Colors.white.withValues(alpha: 0.5),
                            size: 40,
                          ),
                        ),
                        const Gap(20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current Streak',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Gap(4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  TweenAnimationBuilder<int>(
                                    duration:
                                        const Duration(milliseconds: 1000),
                                    tween:
                                        IntTween(begin: 0, end: _currentStreak),
                                    builder: (context, value, child) {
                                      return Text(
                                        '$value',
                                        style: const TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          height: 1,
                                        ),
                                      );
                                    },
                                  ),
                                  const Gap(8),
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      'days',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(4),
                              Text(
                                _currentStreak > 0
                                    ? 'Keep it up! Don\'t break the chain 🔥'
                                    : 'Start your streak today! 💪',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    final stats = [
      {
        'label': 'Total Runs',
        'value': _totalRuns.toString(),
        'icon': Icons.directions_run,
        'color': const Color(0xFF2563EB),
      },
      {
        'label': 'Total Distance',
        'value': '${_totalDistance.toStringAsFixed(1)}',
        'unit': 'km',
        'icon': Icons.route,
        'color': const Color(0xFF10B981),
      },
      {
        'label': 'Best Pace',
        'value': _personalBest,
        'icon': Icons.speed,
        'color': const Color(0xFF8B5CF6),
      },
    ];

    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildStatCard(
              label: stat['label'] as String,
              value: stat['value'] as String,
              unit: stat['unit'] as String? ?? '',
              icon: stat['icon'] as IconData,
              color: stat['color'] as Color,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    String unit = '',
    required IconData icon,
    required Color color,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animValue, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animValue)),
          child: Opacity(
            opacity: animValue,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const Gap(12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D1B2A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unit.isNotEmpty) ...[
                        const Gap(2),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            unit,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Gap(4),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoalsSection(GoalProvider goalProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            OutlinedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GoalSettingScreen(),
                  ),
                );
                if (result == true && mounted) {
                  context.read<GoalProvider>().loadActiveGoals();
                  _progressController.reset();
                  _progressController.forward();
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.blueLogo,
                side: const BorderSide(color: AppColors.blueLogo, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              icon: const Icon(Icons.settings, size: 16),
              label: const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const Gap(16),
        _buildLinearGoals(goalProvider),
      ],
    );
  }

  Widget _buildLinearGoals(GoalProvider goalProvider) {
    final distanceGoal = goalProvider.activeDistanceGoal;
    final caloriesGoal = goalProvider.activeCaloriesGoal;

    return Column(
      children: [
        if (distanceGoal != null)
          _buildLinearGoalCard(
            label: 'Distance Goal',
            subtitle: distanceGoal.periodLabel,
            currentValue: distanceGoal.currentValue,
            targetValue: distanceGoal.targetValue,
            unit: distanceGoal.unit.name == 'km' ? 'km' : 'mile',
            icon: Icons.route,
            color: const Color(0xFF2563EB),
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
            ),
          )
        else
          _buildEmptyGoalCard('Set a distance goal to track your progress'),
        const Gap(16),
        if (caloriesGoal != null)
          _buildLinearGoalCard(
            label: 'Calories Goal',
            subtitle: caloriesGoal.periodLabel,
            currentValue: caloriesGoal.currentValue,
            targetValue: caloriesGoal.targetValue,
            unit: 'kcal',
            icon: Icons.local_fire_department,
            color: const Color(0xFFFF6B6B),
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
            ),
          )
        else
          _buildEmptyGoalCard('Set a calories goal to track your progress'),
      ],
    );
  }

  Widget _buildLinearGoalCard({
    required String label,
    required String subtitle,
    required double currentValue,
    required double targetValue,
    required String unit,
    required IconData icon,
    required Color color,
    required Gradient gradient,
  }) {
    final progress =
        targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).toInt();

    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        final animatedProgress = progress * _progressController.value;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D1B2A),
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${currentValue.toStringAsFixed(unit == 'kcal' ? 0 : 1)} $unit',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1B2A),
                    ),
                  ),
                  Text(
                    'of ${targetValue.toStringAsFixed(0)} $unit',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Gap(12),
              Stack(
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: animatedProgress,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (progress >= 1.0) ...[
                const Gap(12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Color(0xFF10B981),
                        size: 16,
                      ),
                      Gap(6),
                      Text(
                        'Goal Achieved! 🎉',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyGoalCard(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.flag_outlined,
              color: Color(0xFF9CA3AF),
              size: 24,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementTeaser() {
    return Consumer<AchievementProvider>(
      builder: (context, achievementProvider, child) {
        final recentlyUnlocked =
            achievementProvider.getRecentlyUnlocked(limit: 4);
        final nextToUnlock = achievementProvider.getNextToUnlock(limit: 4);

        // Show mix of recently unlocked and next to unlock
        final displayAchievements = [
          ...recentlyUnlocked.take(2),
          ...nextToUnlock.take(4 - recentlyUnlocked.take(2).length),
        ].take(4).toList();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF8B5CF6),
                Color(0xFF6366F1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Achievements',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        '${achievementProvider.unlockedAchievements.length} unlocked • ${achievementProvider.totalPoints} pts',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AchievementsPage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Gap(4),
                        Icon(Icons.arrow_forward_ios, size: 12),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(16),
              if (displayAchievements.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Start running to unlock achievements!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else
                Row(
                  children: displayAchievements.map((userAchievement) {
                    final achievement = userAchievement.achievement;
                    if (achievement == null) return const SizedBox.shrink();

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildAchievementBadge(
                          icon: achievement.icon,
                          label: achievement.name,
                          isUnlocked: userAchievement.isUnlocked,
                          progress: userAchievement.isUnlocked
                              ? null
                              : userAchievement.progress,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAchievementBadge({
    required IconData icon,
    required String label,
    required bool isUnlocked,
    double? progress,
  }) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUnlocked
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: isUnlocked
                    ? const Color(0xFFFFD700)
                    : Colors.white.withValues(alpha: 0.5),
                size: 32,
              ),
            ),
            if (!isUnlocked && progress != null)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const Gap(8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isUnlocked ? Colors.white : Colors.white60,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllActivitiesPage(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_run,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const Gap(16),
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(RunSession activity) {
    final dateFormat = DateFormat('dd MMM yyyy • HH:mm');
    final isConquered = activity.territoryConquered;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActivityDetailPage(activity: activity),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.blueLogo.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.blueLogo.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.blueLogo,
                    AppColors.blueLogo.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.directions_run,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Running',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          dateFormat.format(activity.startTime),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isConquered)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.emoji_events,
                            size: 14,
                            color: Color(0xFF0D1B2A),
                          ),
                          Gap(4),
                          Text(
                            'Conquered',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D1B2A),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Stats section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActivityStatCard(
                      icon: Icons.route,
                      label: 'Distance',
                      value: activity.formattedDistance,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: _buildActivityStatCard(
                      icon: Icons.access_time,
                      label: 'Duration',
                      value: activity.formattedDuration,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: _buildActivityStatCard(
                      icon: Icons.speed,
                      label: 'Avg Pace',
                      value: activity.formattedPace,
                      color: const Color(0xFFFF6B6B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const Gap(6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Gap(2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
