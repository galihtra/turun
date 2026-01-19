import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turun/app/app_logger.dart';
import 'package:turun/data/model/nutrition/meal_log_model.dart';
import 'package:turun/data/model/nutrition/nutrition_goal_model.dart';

/// Provider untuk state management nutrisi
/// Mengelola nutrition goals dan meal logs
class NutritionProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  NutritionGoalModel? _nutritionGoal;
  List<MealLogModel> _todayMeals = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  NutritionGoalModel? get nutritionGoal => _nutritionGoal;
  List<MealLogModel> get todayMeals => _todayMeals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Cek apakah user sudah setup nutrition goal
  bool get hasNutritionGoal => _nutritionGoal != null;

  /// Hitung total kalori hari ini
  int get todayConsumedCalories {
    return _todayMeals.fold(0, (sum, meal) => sum + meal.calories);
  }

  /// Hitung sisa kalori hari ini
  int get remainingCalories {
    if (_nutritionGoal == null) return 0;
    return _nutritionGoal!.dailyCalories.round() - todayConsumedCalories;
  }

  /// Persentase kalori yang sudah dikonsumsi
  double get calorieProgress {
    if (_nutritionGoal == null || _nutritionGoal!.dailyCalories == 0) return 0;
    return (todayConsumedCalories / _nutritionGoal!.dailyCalories)
        .clamp(0.0, 1.5);
  }

  /// Get meal log berdasarkan type
  MealLogModel? getMealByType(MealType type) {
    try {
      return _todayMeals.firstWhere((meal) => meal.mealType == type);
    } catch (_) {
      return null;
    }
  }

  /// Load nutrition goal untuk current user
  Future<void> loadNutritionGoal() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _isLoading = true;
    _error = null;

    try {
      final response = await _supabase
          .from('user_nutrition_goals')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        _nutritionGoal = NutritionGoalModel.fromJson(response);
        AppLogger.success(LogLabel.provider, 'Loaded nutrition goal');
      } else {
        _nutritionGoal = null;
        AppLogger.info(LogLabel.provider, 'No nutrition goal found');
      }
    } catch (e, stackTrace) {
      AppLogger.error(
          LogLabel.provider, 'Failed to load nutrition goal', e, stackTrace);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load meal logs untuk hari ini
  Future<void> loadTodayMeals() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('meal_logs')
          .select()
          .eq('user_id', userId)
          .gte('logged_at', startOfDay.toIso8601String())
          .lt('logged_at', endOfDay.toIso8601String())
          .order('logged_at');

      _todayMeals = (response as List)
          .map((json) => MealLogModel.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.success(
          LogLabel.provider, 'Loaded ${_todayMeals.length} meals for today');
    } catch (e, stackTrace) {
      AppLogger.error(
          LogLabel.provider, 'Failed to load today meals', e, stackTrace);
    }
    notifyListeners();
  }

  /// Simpan nutrition goal baru
  Future<bool> saveNutritionGoal({
    required NutritionGoalType goalType,
    required double targetWeight,
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Hitung BMR, TDEE, dan daily calories
      final bmr = NutritionGoalModel.calculateBMR(
        weightKg: weightKg,
        heightCm: heightCm,
        age: age,
        gender: gender,
      );
      final tdee = NutritionGoalModel.calculateTDEE(bmr);
      final dailyCalories =
          NutritionGoalModel.calculateDailyCalories(tdee, goalType);

      final now = DateTime.now();
      final goalData = {
        'user_id': userId,
        'goal_type': goalType.value,
        'target_weight': targetWeight,
        'daily_calories': dailyCalories,
        'bmr': bmr,
        'tdee': tdee,
        'streak': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      await _supabase.from('user_nutrition_goals').insert(goalData);

      // Reload goal
      await loadNutritionGoal();

      AppLogger.success(
          LogLabel.provider, 'Saved nutrition goal: $dailyCalories kkal/day');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
          LogLabel.provider, 'Failed to save nutrition goal', e, stackTrace);
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Simpan meal log
  Future<bool> saveMealLog({
    required MealType mealType,
    required String foodName,
    required int calories,
    String? imageUrl,
    String? aiAnalysis,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null || _nutritionGoal == null) return false;

    try {
      final targetCalories =
          mealType.getTargetCalories(_nutritionGoal!.dailyCalories);
      final status = MealStatus.fromCalories(calories, targetCalories);
      final now = DateTime.now();

      final mealData = {
        'user_id': userId,
        'meal_type': mealType.value,
        'food_name': foodName,
        'calories': calories,
        'target_calories': targetCalories,
        'image_url': imageUrl,
        'ai_analysis': aiAnalysis,
        'status': status.value,
        'logged_at': now.toIso8601String(),
        'created_at': now.toIso8601String(),
      };

      await _supabase.from('meal_logs').insert(mealData);

      // Reload today's meals
      await loadTodayMeals();

      // Update streak jika sudah lengkap
      await _checkAndUpdateStreak();

      AppLogger.success(
          LogLabel.provider, 'Saved meal: $foodName ($calories kkal)');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(
          LogLabel.provider, 'Failed to save meal log', e, stackTrace);
      return false;
    }
  }

  /// Cek dan update streak
  Future<void> _checkAndUpdateStreak() async {
    if (_nutritionGoal == null) return;

    // Cek apakah sudah log semua meal hari ini
    final hasBreakfast = getMealByType(MealType.breakfast) != null;
    final hasLunch = getMealByType(MealType.lunch) != null;
    final hasDinner = getMealByType(MealType.dinner) != null;

    if (hasBreakfast && hasLunch && hasDinner) {
      try {
        await _supabase.from('user_nutrition_goals').update({
          'streak': _nutritionGoal!.streak + 1,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', _nutritionGoal!.id);

        await loadNutritionGoal();
        AppLogger.success(LogLabel.provider, 'Streak updated!');
      } catch (e) {
        // Ignore streak update errors
      }
    }
  }

  /// Load semua data nutrisi
  Future<void> loadAllNutritionData() async {
    await Future.wait([
      loadNutritionGoal(),
      loadTodayMeals(),
    ]);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
