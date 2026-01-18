import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turun/app/app_logger.dart';

import '../../model/weight/weight_entry_model.dart';

/// Provider for managing weight tracking state and data
class WeightProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<WeightEntryModel> _weightHistory = [];
  WeightStatistics _statistics = WeightStatistics.empty();
  bool _isLoading = false;
  String? _error;

  // Getters
  List<WeightEntryModel> get weightHistory => _weightHistory;
  WeightStatistics get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _weightHistory.isNotEmpty;

  /// Load weight history for the current user
  Future<void> loadWeightHistory() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      AppLogger.warning(LogLabel.auth, 'Cannot load weight history: No authenticated user');
      return;
    }

    AppLogger.info(LogLabel.provider, 'Loading weight history for user: $userId');

    _isLoading = true;
    _error = null;

    try {
      final response = await _supabase
          .from('weight_history')
          .select()
          .eq('user_id', userId)
          .order('recorded_at', ascending: false)
          .limit(100);

      AppLogger.network(LogLabel.supabase, 'Weight history fetched: ${response.length} entries');

      _weightHistory = (response as List)
          .map((json) => WeightEntryModel.fromJson(json))
          .toList();

      _statistics = WeightStatistics.fromEntries(_weightHistory);

      AppLogger.success(LogLabel.provider, 'Weight history loaded successfully');
    } catch (e, stackTrace) {
      AppLogger.error(LogLabel.provider, 'Failed to load weight history', e, stackTrace);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new weight entry
  Future<bool> addWeight(double weight, {DateTime? recordedAt}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      AppLogger.warning(LogLabel.auth, 'Cannot add weight: No authenticated user');
      _error = 'User not authenticated';
      return false;
    }

    AppLogger.info(LogLabel.provider, 'Adding weight entry: $weight kg');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = WeightEntryModel.toInsertJson(
        userId: userId,
        weight: weight,
        recordedAt: recordedAt,
      );

      await _supabase.from('weight_history').insert(data);

      AppLogger.success(LogLabel.supabase, 'Weight entry added successfully');

      // Reload history to get updated data
      await loadWeightHistory();

      return true;
    } catch (e, stackTrace) {
      AppLogger.error(LogLabel.provider, 'Failed to add weight', e, stackTrace);
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a weight entry
  Future<bool> deleteWeight(String entryId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      _error = 'User not authenticated';
      return false;
    }

    AppLogger.info(LogLabel.provider, 'Deleting weight entry: $entryId');

    try {
      await _supabase
          .from('weight_history')
          .delete()
          .eq('id', entryId)
          .eq('user_id', userId);

      AppLogger.success(LogLabel.supabase, 'Weight entry deleted');

      // Reload history
      await loadWeightHistory();

      return true;
    } catch (e, stackTrace) {
      AppLogger.error(LogLabel.provider, 'Failed to delete weight', e, stackTrace);
      _error = e.toString();
      return false;
    }
  }

  /// Get weight entries for the last N days (for chart)
  List<WeightEntryModel> getEntriesForDays(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _weightHistory
        .where((entry) => entry.recordedAt.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
  }

  /// Get chart data points normalized to 0-1 range
  List<double> getChartDataPoints({int days = 30, int maxPoints = 12}) {
    final entries = getEntriesForDays(days);
    
    if (entries.isEmpty) {
      return [];
    }

    // Sample entries to fit maxPoints
    List<WeightEntryModel> sampled;
    if (entries.length <= maxPoints) {
      sampled = entries;
    } else {
      final step = entries.length / maxPoints;
      sampled = List.generate(
        maxPoints,
        (i) => entries[(i * step).floor().clamp(0, entries.length - 1)],
      );
    }

    final weights = sampled.map((e) => e.weight).toList();
    final minW = weights.reduce((a, b) => a < b ? a : b);
    final maxW = weights.reduce((a, b) => a > b ? a : b);
    final range = maxW - minW;

    if (range == 0) {
      return List.filled(sampled.length, 0.5);
    }

    // Normalize to 0-1 range (inverted: lower weight = lower on chart)
    return weights.map((w) => 1 - ((w - minW) / range)).toList();
  }

  /// Clear any errors
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _weightHistory = [];
    _statistics = WeightStatistics.empty();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
