import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:turun/data/model/nutrition/meal_log_model.dart';
import 'package:turun/data/services/gemini_nutrition_service.dart';
import 'package:turun/resources/colors_app.dart';

/// Dialog untuk menampilkan hasil analisa AI
/// Menampilkan feedback sukses atau warning
class MealResultDialog extends StatelessWidget {
  final FoodAnalysisResult result;
  final MealType mealType;
  final File? imageFile;
  final VoidCallback onSave;
  final VoidCallback onRetake;

  const MealResultDialog({
    super.key,
    required this.result,
    required this.mealType,
    this.imageFile,
    required this.onSave,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(20),

          // Result content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Status icon with animation
                _buildStatusIcon(),
                const Gap(20),

                // Food name and calories
                Text(
                  result.foodName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D1B2A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            size: 20,
                            color: _getStatusColor(),
                          ),
                          const Gap(6),
                          Text(
                            '${result.calories} kkal',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (result.calorieDifference != 0) ...[
                      const Gap(8),
                      Text(
                        result.calorieDifference > 0
                            ? '+${result.calorieDifference}'
                            : '${result.calorieDifference}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(),
                        ),
                      ),
                    ],
                  ],
                ),
                const Gap(20),

                // Target comparison
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildComparisonItem(
                        'Target',
                        '${result.targetCalories}',
                        'kkal',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.grey.shade300,
                      ),
                      _buildComparisonItem(
                        'Actual',
                        '${result.calories}',
                        'kkal',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.grey.shade300,
                      ),
                      _buildComparisonItem(
                        'Difference',
                        result.calorieDifference >= 0
                            ? '+${result.calorieDifference}'
                            : '${result.calorieDifference}',
                        'kkal',
                      ),
                    ],
                  ),
                ),
                const Gap(20),

                // AI Feedback
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: result.isOnTarget
                        ? LinearGradient(
                            colors: [
                              AppColors.green.shade50,
                              AppColors.greenLunatic.withValues(alpha: 0.1),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              AppColors.yellow.shade50,
                              AppColors.orange.shade50,
                            ],
                          ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: result.isOnTarget
                          ? AppColors.green.shade200
                          : AppColors.yellow.shade300,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          result.isOnTarget ? '🎉' : '💡',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          result.feedback,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: AppColors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(24),

          // Action buttons
          Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              0,
              24,
              MediaQuery.of(context).padding.bottom + 24,
            ),
            child: Column(
              children: [
                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: result.isOnTarget
                          ? AppColors.greenLunatic
                          : AppColors.blueLogo,
                      foregroundColor: result.isOnTarget
                          ? const Color(0xFF0D1B2A)
                          : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          result.isOnTarget ? Icons.celebration : Icons.save,
                        ),
                        const Gap(8),
                        Text(
                          result.isOnTarget
                              ? 'Simpan Log (+10 XP)'
                              : 'Simpan Saja',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(12),
                // Retake button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: onRetake,
                    child: Text(
                      'Foto Ulang',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: result.isOnTarget
                  ? LinearGradient(
                      colors: [
                        AppColors.green.shade400,
                        AppColors.greenLunatic
                      ],
                    )
                  : result.isOverTarget
                      ? LinearGradient(
                          colors: [
                            AppColors.orange.shade400,
                            AppColors.yellow.shade400
                          ],
                        )
                      : LinearGradient(
                          colors: [
                            AppColors.blue.shade400,
                            AppColors.blue.shade300
                          ],
                        ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getStatusColor().withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              result.isOnTarget
                  ? Icons.thumb_up
                  : result.isOverTarget
                      ? Icons.warning
                      : Icons.trending_down,
              color: Colors.white,
              size: 36,
            ),
          ),
        );
      },
    );
  }

  Widget _buildComparisonItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.grey.shade600,
          ),
        ),
        const Gap(4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D1B2A),
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    if (result.isOnTarget) return AppColors.green.shade500;
    if (result.isOverTarget) return AppColors.orange.shade500;
    return AppColors.blue.shade500;
  }
}
