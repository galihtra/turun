/// Model untuk log makanan harian
/// Menyimpan data meal (breakfast/lunch/dinner) dengan analisa AI
class MealLogModel {
  final String id;
  final String userId;
  final MealType mealType;
  final String foodName;
  final int calories;
  final int targetCalories;
  final String? imageUrl;
  final String? aiAnalysis;
  final MealStatus status;
  final DateTime loggedAt;
  final DateTime createdAt;

  MealLogModel({
    required this.id,
    required this.userId,
    required this.mealType,
    required this.foodName,
    required this.calories,
    required this.targetCalories,
    this.imageUrl,
    this.aiAnalysis,
    required this.status,
    required this.loggedAt,
    required this.createdAt,
  });

  factory MealLogModel.fromJson(Map<String, dynamic> json) {
    return MealLogModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      mealType: MealType.fromString(json['meal_type'] as String),
      foodName: json['food_name'] as String,
      calories: json['calories'] as int,
      targetCalories: json['target_calories'] as int,
      imageUrl: json['image_url'] as String?,
      aiAnalysis: json['ai_analysis'] as String?,
      status: MealStatus.fromString(json['status'] as String),
      loggedAt: DateTime.parse(json['logged_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'meal_type': mealType.value,
      'food_name': foodName,
      'calories': calories,
      'target_calories': targetCalories,
      'image_url': imageUrl,
      'ai_analysis': aiAnalysis,
      'status': status.value,
      'logged_at': loggedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Cek apakah meal sudah completed
  bool get isCompleted => status != MealStatus.empty;

  /// Hitung persentase dari target
  double get percentageOfTarget =>
      targetCalories > 0 ? calories / targetCalories : 0.0;
}

enum MealType {
  breakfast('breakfast', 0.30), // 30% dari total kalori
  lunch('lunch', 0.40), // 40% dari total kalori
  dinner('dinner', 0.30); // 30% dari total kalori

  final String value;
  final double percentage;
  const MealType(this.value, this.percentage);

  static MealType fromString(String value) {
    return MealType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MealType.breakfast,
    );
  }

  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
    }
  }

  String get emoji {
    switch (this) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
    }
  }

  String get scheduledTime {
    switch (this) {
      case MealType.breakfast:
        return '7:00 AM';
      case MealType.lunch:
        return '12:00 PM';
      case MealType.dinner:
        return '7:00 PM';
    }
  }

  /// Dapatkan target kalori untuk meal type berdasarkan total daily calories
  int getTargetCalories(double dailyCalories) {
    return (dailyCalories * percentage).round();
  }
}

enum MealStatus {
  empty('empty'),
  pass('pass'),
  over('over'),
  under('under');

  final String value;
  const MealStatus(this.value);

  static MealStatus fromString(String value) {
    return MealStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MealStatus.empty,
    );
  }

  /// Tentukan status berdasarkan kalori aktual vs target
  static MealStatus fromCalories(int actual, int target) {
    if (actual == 0) return MealStatus.empty;

    final ratio = actual / target;
    if (ratio >= 0.85 && ratio <= 1.15) {
      return MealStatus.pass; // Dalam range ±15%
    } else if (ratio > 1.15) {
      return MealStatus.over;
    } else {
      return MealStatus.under;
    }
  }

  String get emoji {
    switch (this) {
      case MealStatus.empty:
        return '⬜';
      case MealStatus.pass:
        return '✅';
      case MealStatus.over:
        return '⚠️';
      case MealStatus.under:
        return '📉';
    }
  }

  String get message {
    switch (this) {
      case MealStatus.empty:
        return 'Tap to scan meal';
      case MealStatus.pass:
        return 'Great job! On target';
      case MealStatus.over:
        return 'Over target';
      case MealStatus.under:
        return 'Under target';
    }
  }
}
