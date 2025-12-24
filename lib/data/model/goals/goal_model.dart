/// Model for user running goals
class Goal {
  final int id;
  final String userId;
  final GoalType type; // distance or calories
  final double targetValue; // in km or kcal
  final double currentValue; // current progress
  final GoalUnit unit; // km, mile, kcal
  final GoalPeriod period; // daily, weekly, monthly
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Goal({
    required this.id,
    required this.userId,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    required this.unit,
    required this.period,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate progress percentage
  double get progressPercentage {
    if (targetValue <= 0) return 0.0;
    return (currentValue / targetValue * 100).clamp(0.0, 100.0);
  }

  /// Check if goal is completed
  bool get isCompleted => currentValue >= targetValue;

  /// Remaining value to reach goal
  double get remainingValue {
    return (targetValue - currentValue).clamp(0.0, double.infinity);
  }

  /// Get period label
  String get periodLabel {
    switch (period) {
      case GoalPeriod.daily:
        return 'Today';
      case GoalPeriod.weekly:
        return 'This Week';
      case GoalPeriod.monthly:
        return 'This Month';
    }
  }

  /// Format target value for display
  String get formattedTarget {
    if (type == GoalType.distance) {
      return unit == GoalUnit.mile
          ? '${targetValue.toStringAsFixed(1)} Miles'
          : '${targetValue.toStringAsFixed(1)} Km';
    } else {
      return '${targetValue.toStringAsFixed(0)} kcal';
    }
  }

  /// Format current value for display
  String get formattedCurrent {
    if (type == GoalType.distance) {
      return unit == GoalUnit.mile
          ? '${currentValue.toStringAsFixed(1)} Miles'
          : '${currentValue.toStringAsFixed(1)} Km';
    } else {
      return '${currentValue.toStringAsFixed(0)} kcal';
    }
  }

  /// Create from JSON (Supabase response)
  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      type: GoalType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => GoalType.distance,
      ),
      targetValue: (json['target_value'] as num).toDouble(),
      currentValue: (json['current_value'] as num?)?.toDouble() ?? 0.0,
      unit: GoalUnit.values.firstWhere(
        (e) => e.name == json['unit'],
        orElse: () => GoalUnit.km,
      ),
      period: GoalPeriod.values.firstWhere(
        (e) => e.name == json['period'],
        orElse: () => GoalPeriod.daily,
      ),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'target_value': targetValue,
      'current_value': currentValue,
      'unit': unit.name,
      'period': period.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with
  Goal copyWith({
    int? id,
    String? userId,
    GoalType? type,
    double? targetValue,
    double? currentValue,
    GoalUnit? unit,
    GoalPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Goal type enum
enum GoalType {
  distance, // Total distance goal
  calories, // Total calories burned goal
}

/// Goal unit enum
enum GoalUnit {
  km, // Kilometers
  mile, // Miles
  kcal, // Kilocalories
}

/// Goal period enum
enum GoalPeriod {
  daily, // Daily goal
  weekly, // Weekly goal
  monthly, // Monthly goal
}
