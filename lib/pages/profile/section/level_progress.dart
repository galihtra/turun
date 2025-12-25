import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:turun/data/providers/achievement/achievement_provider.dart';

class LevelProgress extends StatelessWidget {
  const LevelProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AchievementProvider>(
      builder: (context, achievementProvider, child) {
        // Show loading state
        if (achievementProvider.isLoading) {
          return Container(
            height: 180,
            padding: const EdgeInsets.all(24),
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
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        }

        final totalPoints = achievementProvider.totalPoints;
        final level = _calculateLevel(totalPoints);
        final currentLevelPoints = _getLevelPoints(level);
        final nextLevelPoints = _getLevelPoints(level + 1);
        final pointsInLevel = totalPoints - currentLevelPoints;
        final pointsNeeded = nextLevelPoints - currentLevelPoints;

        // Debug
        print('DEBUG Level Progress:');
        print('Total Points: $totalPoints');
        print('Level: $level');
        print('Current Level Points: $currentLevelPoints');
        print('Next Level Points: $nextLevelPoints');
        print('Points in Level: $pointsInLevel');
        print('Points Needed: $pointsNeeded');

        final progress =
            pointsNeeded > 0 ? (pointsInLevel / pointsNeeded) : 1.0;
        print('Progress: $progress');

        return TweenAnimationBuilder<double>(
          key: ValueKey('level_progress_$totalPoints'),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0.0, end: progress.clamp(0.0, 1.0)),
          builder: (context, animatedProgress, child) {
            return Container(
              padding: const EdgeInsets.all(24),
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
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getLevelIcon(level),
                          color: _getLevelColor(level),
                          size: 28,
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getLevelName(level),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              'Level $level',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.8),
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
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.stars,
                              color: Color(0xFFFFD700),
                              size: 18,
                            ),
                            const Gap(6),
                            Text(
                              '$totalPoints',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        Container(
                          height: 12,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
                              height: 12,
                              width: constraints.maxWidth * animatedProgress,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFD700),
                                    Color(0xFFFFA500),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700)
                                        .withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const Gap(12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$totalPoints / $nextLevelPoints points',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      Text(
                        '${(animatedProgress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  int _calculateLevel(int points) {
    if (points < 100) return 1;
    if (points < 300) return 2;
    if (points < 600) return 3;
    if (points < 1000) return 4;
    if (points < 1500) return 5;
    if (points < 2100) return 6;
    if (points < 2800) return 7;
    if (points < 3600) return 8;
    if (points < 4500) return 9;
    return 10;
  }

  int _getLevelPoints(int level) {
    // Level 1 starts at 0, Level 2 starts at 100, etc.
    const points = [0, 0, 100, 300, 600, 1000, 1500, 2100, 2800, 3600, 4500, 5500];
    // Clamp level to valid range
    final index = level.clamp(0, points.length - 1);
    return points[index];
  }

  String _getLevelName(int level) {
    const names = [
      'Beginner',
      'Novice',
      'Runner',
      'Athlete',
      'Champion',
      'Elite',
      'Master',
      'Legend',
      'Hero',
      'God',
    ];
    return level > 0 && level <= names.length ? names[level - 1] : 'Max Level';
  }

  IconData _getLevelIcon(int level) {
    if (level <= 2) return Icons.local_fire_department;
    if (level <= 4) return Icons.star;
    if (level <= 6) return Icons.emoji_events;
    if (level <= 8) return Icons.military_tech;
    return Icons.workspace_premium;
  }

  Color _getLevelColor(int level) {
    if (level <= 2) return const Color(0xFFCD7F32); // Bronze
    if (level <= 4) return const Color(0xFFC0C0C0); // Silver
    if (level <= 6) return const Color(0xFFFFD700); // Gold
    if (level <= 8) return const Color(0xFFB9F2FF); // Diamond
    return const Color(0xFFE5E4E2); // Platinum
  }
}
