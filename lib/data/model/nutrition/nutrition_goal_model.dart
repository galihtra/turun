/// Model untuk target nutrisi user
/// Menyimpan data goal, BMR, TDEE, dan daily calories
class NutritionGoalModel {
  final String id;
  final String userId;
  final NutritionGoalType goalType;
  final double? targetWeight;
  final double dailyCalories;
  final double bmr;
  final double tdee;
  final int streak;
  final DateTime createdAt;
  final DateTime updatedAt;

  NutritionGoalModel({
    required this.id,
    required this.userId,
    required this.goalType,
    this.targetWeight,
    required this.dailyCalories,
    required this.bmr,
    required this.tdee,
    this.streak = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NutritionGoalModel.fromJson(Map<String, dynamic> json) {
    return NutritionGoalModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      goalType: NutritionGoalType.fromString(json['goal_type'] as String),
      targetWeight: json['target_weight'] != null
          ? (json['target_weight'] as num).toDouble()
          : null,
      dailyCalories: (json['daily_calories'] as num).toDouble(),
      bmr: (json['bmr'] as num).toDouble(),
      tdee: (json['tdee'] as num).toDouble(),
      streak: json['streak'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'goal_type': goalType.value,
      'target_weight': targetWeight,
      'daily_calories': dailyCalories,
      'bmr': bmr,
      'tdee': tdee,
      'streak': streak,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Hitung BMR menggunakan Mifflin-St Jeor Equation
  /// Men:   BMR = 10W + 6.25H - 5A + 5
  /// Women: BMR = 10W + 6.25H - 5A - 161
  static double calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
  }) {
    final genderFactor = gender.toLowerCase() == 'male' ? 5 : -161;
    return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + genderFactor;
  }

  /// Hitung TDEE berdasarkan activity level
  /// Untuk runner, gunakan moderate activity (1.55)
  static double calculateTDEE(double bmr, {double activityMultiplier = 1.55}) {
    return bmr * activityMultiplier;
  }

  /// Hitung daily calories berdasarkan goal
  static double calculateDailyCalories(double tdee, NutritionGoalType goal) {
    switch (goal) {
      case NutritionGoalType.weightLoss:
        return tdee - 500; // Defisit 500 kkal untuk turun ~0.5kg/minggu
      case NutritionGoalType.bulking:
        return tdee + 300; // Surplus 300 kkal untuk bulking clean
      case NutritionGoalType.maintain:
        return tdee; // Maintain
    }
  }
}

enum NutritionGoalType {
  weightLoss('weight_loss'),
  bulking('bulking'),
  maintain('maintain');

  final String value;
  const NutritionGoalType(this.value);

  static NutritionGoalType fromString(String value) {
    return NutritionGoalType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NutritionGoalType.maintain,
    );
  }

  String get displayName {
    switch (this) {
      case NutritionGoalType.weightLoss:
        return 'Weight Loss';
      case NutritionGoalType.bulking:
        return 'Bulking';
      case NutritionGoalType.maintain:
        return 'Maintain';
    }
  }

  String get description {
    switch (this) {
      case NutritionGoalType.weightLoss:
        return 'Burn fat, get leaner, and improve metabolic health';
      case NutritionGoalType.bulking:
        return 'Build muscle with high protein and calorie surplus';
      case NutritionGoalType.maintain:
        return 'Maintain current weight with balanced nutrition';
    }
  }

  String get emoji {
    switch (this) {
      case NutritionGoalType.weightLoss:
        return '📉';
      case NutritionGoalType.bulking:
        return '💪';
      case NutritionGoalType.maintain:
        return '⚖️';
    }
  }
}
