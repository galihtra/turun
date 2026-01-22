import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:turun/data/model/nutrition/meal_log_model.dart';
import 'package:turun/data/providers/nutrition/nutrition_provider.dart';
import 'package:turun/pages/nutrition/food_scanner_screen.dart';
import 'package:turun/resources/colors_app.dart';

/// Dashboard utama untuk tracking nutrisi harian
/// Menampilkan 3 kartu meal (Breakfast, Lunch, Dinner)
class NutritionDashboardScreen extends StatefulWidget {
  const NutritionDashboardScreen({super.key});

  @override
  State<NutritionDashboardScreen> createState() =>
      _NutritionDashboardScreenState();
}

class _NutritionDashboardScreenState extends State<NutritionDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<NutritionProvider>(context, listen: false);
    await provider.loadAllNutritionData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Consumer<NutritionProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueLogo),
                ),
              );
            }

            final goal = provider.nutritionGoal;
            if (goal == null) {
              return const Center(child: Text('No nutrition goal found'));
            }

            return RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.blueLogo,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(provider),
                      const Gap(24),

                      // Calorie Summary Card
                      _buildCalorieSummary(provider),
                      const Gap(28),

                      // Today's Meals Section
                      const Text(
                        "Today's Meals",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D1B2A),
                        ),
                      ),
                      const Gap(16),

                      // Meal Cards
                      ...MealType.values.map((mealType) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildMealCard(provider, mealType),
                          )),

                      const Gap(20),
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

  Widget _buildHeader(NutritionProvider provider) {
    final goal = provider.nutritionGoal!;

    return Row(
      children: [
        // Back button
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF0D1B2A),
            ),
          ),
        ),
        const Gap(16),
        // Title
        const Expanded(
          child: Text(
            'Daily Meal Tracker',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D1B2A),
            ),
          ),
        ),
        // Streak badge
        if (goal.streak > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 16,
                ),
                const Gap(4),
                Text(
                  '${goal.streak}-DAY STREAK',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCalorieSummary(NutritionProvider provider) {
    final goal = provider.nutritionGoal!;
    final consumed = provider.todayConsumedCalories;
    final total = goal.dailyCalories.round();
    final remaining = provider.remainingCalories;
    final progress = provider.calorieProgress.clamp(0.0, 1.0);
    final percentage = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              Text(
                'CALORIES CONSUMED',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey.shade600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const Gap(8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$consumed',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D1B2A),
                  height: 1,
                ),
              ),
              const Gap(8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '/ $total kcal',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.grey.shade600,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.blueLogo.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$percentage% Goal',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueLogo,
                  ),
                ),
              ),
            ],
          ),
          const Gap(16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween(begin: 0.0, end: progress),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 12,
                  backgroundColor: AppColors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.blueLogo,
                  ),
                );
              },
            ),
          ),
          const Gap(12),
          Text(
            remaining >= 0
                ? '$remaining KCAL REMAINING FOR TODAY'
                : '${-remaining} KCAL OVER TARGET',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color:
                  remaining >= 0 ? AppColors.blueLogo : AppColors.red.shade500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(NutritionProvider provider, MealType mealType) {
    final mealLog = provider.getMealByType(mealType);
    final goal = provider.nutritionGoal!;
    final targetCalories = mealType.getTargetCalories(goal.dailyCalories);
    final isCompleted = mealLog != null;
    final isCurrentMeal = _isCurrentMeal(mealType);

    return GestureDetector(
      onTap:
          isCompleted ? null : () => _openFoodScanner(mealType, targetCalories),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isCurrentMeal && !isCompleted
              ? Border.all(color: AppColors.blueLogo, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Current meal badge
            if (isCurrentMeal && !isCompleted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  color: AppColors.blueLogo,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'CURRENT MEAL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Status icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? _getStatusColor(mealLog.status)
                              .withValues(alpha: 0.1)
                          : AppColors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isCompleted
                          ? (mealLog.status == MealStatus.pass
                              ? Icons.check_circle
                              : Icons.warning)
                          : Icons.lock_outlined,
                      color: isCompleted
                          ? _getStatusColor(mealLog.status)
                          : AppColors.grey.shade400,
                    ),
                  ),
                  const Gap(16),
                  // Meal info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mealType.displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D1B2A),
                          ),
                        ),
                        const Gap(2),
                        Text(
                          isCompleted
                              ? mealLog.foodName
                              : 'Scheduled for ${mealType.scheduledTime}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isCompleted
                                ? AppColors.blueLogo
                                : AppColors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Calories or scan button
                  if (isCompleted)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${mealLog.calories}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D1B2A),
                          ),
                        ),
                        Text(
                          'KCAL',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.grey.shade500,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      '---',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey.shade300,
                      ),
                    ),
                ],
              ),
            ),

            // Scan button for current meal
            if (isCurrentMeal && !isCompleted)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _openFoodScanner(mealType, targetCalories),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueLogo,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text(
                      'Tap to Scan Meal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isCurrentMeal(MealType mealType) {
    final hour = DateTime.now().hour;
    switch (mealType) {
      case MealType.breakfast:
        return hour >= 5 && hour < 11;
      case MealType.lunch:
        return hour >= 11 && hour < 16;
      case MealType.dinner:
        return hour >= 16 || hour < 5;
    }
  }

  Color _getStatusColor(MealStatus status) {
    switch (status) {
      case MealStatus.pass:
        return AppColors.green.shade500;
      case MealStatus.over:
        return AppColors.yellow.shade600;
      case MealStatus.under:
        return AppColors.blue.shade500;
      case MealStatus.empty:
        return AppColors.grey.shade400;
    }
  }

  void _openFoodScanner(MealType mealType, int targetCalories) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodScannerScreen(
          mealType: mealType,
          targetCalories: targetCalories,
        ),
      ),
    ).then((_) => _loadData());
  }
}
