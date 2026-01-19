import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:turun/data/providers/nutrition/nutrition_provider.dart';
import 'package:turun/pages/nutrition/nutrition_dashboard_screen.dart';
import 'package:turun/pages/nutrition/nutrition_setup_screen.dart';
import 'package:turun/resources/colors_app.dart';

/// Widget status nutrisi untuk profile screen
/// Ditampilkan di bawah LevelProgress card
class NutritionStatusWidget extends StatelessWidget {
  const NutritionStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NutritionProvider>(
      builder: (context, nutritionProvider, child) {
        // Show loading skeleton
        if (nutritionProvider.isLoading) {
          return _buildLoadingState();
        }

        return GestureDetector(
          onTap: () => _navigateToNutrition(context, nutritionProvider),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blueLogo.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: nutritionProvider.hasNutritionGoal
                ? _buildActiveState(nutritionProvider)
                : _buildSetupState(),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueLogo.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueLogo),
        ),
      ),
    );
  }

  /// State untuk user yang sudah setup nutrition goal
  Widget _buildActiveState(NutritionProvider provider) {
    final goal = provider.nutritionGoal!;
    final consumed = provider.todayConsumedCalories;
    final total = goal.dailyCalories.round();
    final progress = provider.calorieProgress.clamp(0.0, 1.0);

    return Row(
      children: [
        // Circular Progress
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1200),
          tween: Tween(begin: 0.0, end: progress),
          curve: Curves.easeOutCubic,
          builder: (context, animatedProgress, child) {
            return SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background circle
                  CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 8,
                    backgroundColor: AppColors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.grey.shade200,
                    ),
                  ),
                  // Progress circle with gradient effect
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return AppColors.blueGradient.createShader(bounds);
                    },
                    child: CircularProgressIndicator(
                      value: animatedProgress,
                      strokeWidth: 8,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                  // Center icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppColors.blueGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const Gap(20),
        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Energy Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1B2A),
                    ),
                  ),
                  const Gap(8),
                  // Streak badge
                  if (goal.streak > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: 12,
                          ),
                          const Gap(2),
                          Text(
                            '${goal.streak}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const Gap(4),
              RichText(
                text: TextSpan(
                  style:
                      const TextStyle(fontSize: 28, color: Color(0xFF0D1B2A)),
                  children: [
                    TextSpan(
                      text: '$consumed',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' / $total kkal',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(4),
              Text(
                provider.remainingCalories >= 0
                    ? '${provider.remainingCalories} kkal tersisa'
                    : '${(-provider.remainingCalories)} kkal melebihi target',
                style: TextStyle(
                  fontSize: 13,
                  color: provider.remainingCalories >= 0
                      ? AppColors.green.shade500
                      : AppColors.red.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Arrow
        Icon(
          Icons.chevron_right,
          color: AppColors.grey.shade400,
        ),
      ],
    );
  }

  /// State untuk user baru yang belum setup
  Widget _buildSetupState() {
    return Row(
      children: [
        // Icon placeholder
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.blueGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.restaurant_menu,
            color: Colors.white,
            size: 36,
          ),
        ),
        const Gap(20),
        // Setup CTA
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Nutrition Tracker',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D1B2A),
                ),
              ),
              const Gap(4),
              Text(
                'Track your daily meals with AI food scanner',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.grey.shade600,
                ),
              ),
              const Gap(8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.blueGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Tap to Setup Plan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right,
          color: AppColors.grey.shade400,
        ),
      ],
    );
  }

  void _navigateToNutrition(BuildContext context, NutritionProvider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => provider.hasNutritionGoal
            ? const NutritionDashboardScreen()
            : const NutritionSetupScreen(),
      ),
    );
  }
}
