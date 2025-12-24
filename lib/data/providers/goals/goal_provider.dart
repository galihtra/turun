import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turun/app/app_logger.dart';
import 'package:turun/data/model/goals/goal_model.dart';

/// Provider for managing user goals
class GoalProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  Goal? _activeDistanceGoal;
  Goal? _activeCaloriesGoal;
  bool _isLoading = false;
  String? _error;

  // Getters
  Goal? get activeDistanceGoal => _activeDistanceGoal;
  Goal? get activeCaloriesGoal => _activeCaloriesGoal;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load active goals for current user
  Future<void> loadActiveGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Fetch active goals
      final response = await _supabase
          .from('goals')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final goals = (response as List)
          .map((json) => Goal.fromJson(json as Map<String, dynamic>))
          .toList();

      // Separate distance and calories goals
      _activeDistanceGoal = goals.firstWhere(
        (goal) => goal.type == GoalType.distance,
        orElse: () => Goal(
          id: -1,
          userId: userId,
          type: GoalType.distance,
          targetValue: 20.0,
          currentValue: 0.0,
          unit: GoalUnit.km,
          period: GoalPeriod.daily,
          startDate: DateTime.now(),
          isActive: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      _activeCaloriesGoal = goals.firstWhere(
        (goal) => goal.type == GoalType.calories,
        orElse: () => Goal(
          id: -1,
          userId: userId,
          type: GoalType.calories,
          targetValue: 500.0,
          currentValue: 0.0,
          unit: GoalUnit.kcal,
          period: GoalPeriod.daily,
          startDate: DateTime.now(),
          isActive: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Calculate current progress from run history
      await _updateGoalProgress();

      AppLogger.success(LogLabel.general, 'Goals loaded successfully');
    } catch (e) {
      _error = e.toString();
      AppLogger.error(LogLabel.general, 'Failed to load goals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update goal progress based on run history
  Future<void> _updateGoalProgress() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Calculate distance progress
      if (_activeDistanceGoal != null) {
        final distanceValue = await _calculateGoalProgress(
          _activeDistanceGoal!,
          isDistance: true,
        );

        if (_activeDistanceGoal!.id > 0) {
          _activeDistanceGoal = _activeDistanceGoal!.copyWith(
            currentValue: distanceValue,
          );
          await _supabase.from('goals').update({
            'current_value': distanceValue,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', _activeDistanceGoal!.id);
        } else {
          _activeDistanceGoal = _activeDistanceGoal!.copyWith(
            currentValue: distanceValue,
          );
        }
      }

      // Calculate calories progress
      if (_activeCaloriesGoal != null) {
        final caloriesValue = await _calculateGoalProgress(
          _activeCaloriesGoal!,
          isDistance: false,
        );

        if (_activeCaloriesGoal!.id > 0) {
          _activeCaloriesGoal = _activeCaloriesGoal!.copyWith(
            currentValue: caloriesValue,
          );
          await _supabase.from('goals').update({
            'current_value': caloriesValue,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', _activeCaloriesGoal!.id);
        } else {
          _activeCaloriesGoal = _activeCaloriesGoal!.copyWith(
            currentValue: caloriesValue,
          );
        }
      }

      notifyListeners();
    } catch (e) {
      AppLogger.error(LogLabel.general, 'Failed to update goal progress: $e');
    }
  }

  /// Calculate goal progress based on period
  Future<double> _calculateGoalProgress(Goal goal, {required bool isDistance}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return 0.0;

    // Calculate date range based on period
    final now = DateTime.now();
    DateTime startDate;

    switch (goal.period) {
      case GoalPeriod.daily:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case GoalPeriod.weekly:
        // Start of week (Monday)
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case GoalPeriod.monthly:
        startDate = DateTime(now.year, now.month, 1);
        break;
    }

    // Get completed run sessions within the period
    final runSessions = await _supabase
        .from('run_sessions')
        .select()
        .eq('user_id', userId)
        .eq('status', 'completed')
        .gte('created_at', startDate.toIso8601String());

    double total = 0.0;

    for (var session in runSessions as List) {
      if (isDistance) {
        final distance = (session['distance_meters'] as num?)?.toDouble() ?? 0.0;
        total += distance / 1000; // Convert to km
      } else {
        final calories = (session['calories_burned'] as num?)?.toDouble() ?? 0.0;
        total += calories;
      }
    }

    return total;
  }

  /// Create or update a goal
  Future<bool> setGoal({
    required GoalType type,
    required double targetValue,
    required GoalUnit unit,
    required GoalPeriod period,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();

      // Check if goal already exists
      final existingGoal = type == GoalType.distance
          ? _activeDistanceGoal
          : _activeCaloriesGoal;

      if (existingGoal != null && existingGoal.id > 0) {
        // Update existing goal
        await _supabase.from('goals').update({
          'target_value': targetValue,
          'unit': unit.name,
          'period': period.name,
          'updated_at': now.toIso8601String(),
        }).eq('id', existingGoal.id);

        final updatedGoal = existingGoal.copyWith(
          targetValue: targetValue,
          unit: unit,
          period: period,
          updatedAt: now,
        );

        if (type == GoalType.distance) {
          _activeDistanceGoal = updatedGoal;
        } else {
          _activeCaloriesGoal = updatedGoal;
        }
      } else {
        // Create new goal
        final goalData = {
          'user_id': userId,
          'type': type.name,
          'target_value': targetValue,
          'current_value': existingGoal?.currentValue ?? 0.0,
          'unit': unit.name,
          'period': period.name,
          'start_date': now.toIso8601String(),
          'is_active': true,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };

        final response = await _supabase
            .from('goals')
            .insert(goalData)
            .select()
            .single();

        final newGoal = Goal.fromJson(response);

        if (type == GoalType.distance) {
          _activeDistanceGoal = newGoal;
        } else {
          _activeCaloriesGoal = newGoal;
        }
      }

      notifyListeners();
      AppLogger.success(LogLabel.general, 'Goal set successfully');
      return true;
    } catch (e) {
      AppLogger.error(LogLabel.general, 'Failed to set goal: $e');
      return false;
    }
  }

  /// Delete a goal
  Future<bool> deleteGoal(GoalType type) async {
    try {
      final goal = type == GoalType.distance
          ? _activeDistanceGoal
          : _activeCaloriesGoal;

      if (goal == null || goal.id <= 0) return false;

      await _supabase.from('goals').delete().eq('id', goal.id);

      if (type == GoalType.distance) {
        _activeDistanceGoal = null;
      } else {
        _activeCaloriesGoal = null;
      }

      notifyListeners();
      AppLogger.success(LogLabel.general, 'Goal deleted successfully');
      return true;
    } catch (e) {
      AppLogger.error(LogLabel.general, 'Failed to delete goal: $e');
      return false;
    }
  }
}
