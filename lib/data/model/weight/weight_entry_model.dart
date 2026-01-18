/// Model representing a single weight entry in the user's weight history.
class WeightEntryModel {
  final String id;
  final String userId;
  final double weight;
  final DateTime recordedAt;
  final DateTime createdAt;

  WeightEntryModel({
    required this.id,
    required this.userId,
    required this.weight,
    required this.recordedAt,
    required this.createdAt,
  });

  factory WeightEntryModel.fromJson(Map<String, dynamic> json) {
    return WeightEntryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      weight: (json['weight'] as num).toDouble(),
      recordedAt: DateTime.parse(json['recorded_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'weight': weight,
      'recorded_at': recordedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a new entry for insertion (without id, using current timestamp)
  static Map<String, dynamic> toInsertJson({
    required String userId,
    required double weight,
    DateTime? recordedAt,
  }) {
    return {
      'user_id': userId,
      'weight': weight,
      'recorded_at': (recordedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  WeightEntryModel copyWith({
    String? id,
    String? userId,
    double? weight,
    DateTime? recordedAt,
    DateTime? createdAt,
  }) {
    return WeightEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      weight: weight ?? this.weight,
      recordedAt: recordedAt ?? this.recordedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'WeightEntryModel(id: $id, weight: $weight kg, recordedAt: $recordedAt)';
  }
}

/// Statistics for weight tracking
class WeightStatistics {
  final double? latestWeight;
  final double? previousWeight;
  final double? minWeight;
  final double? maxWeight;
  final double? averageWeight;
  final double? weightChange;
  final int totalEntries;

  WeightStatistics({
    this.latestWeight,
    this.previousWeight,
    this.minWeight,
    this.maxWeight,
    this.averageWeight,
    this.weightChange,
    this.totalEntries = 0,
  });

  /// Calculate trend: positive = gaining, negative = losing, null = no data
  double? get trend => weightChange;

  bool get isGaining => (weightChange ?? 0) > 0;
  bool get isLosing => (weightChange ?? 0) < 0;
  bool get isMaintaining => weightChange == 0;

  factory WeightStatistics.empty() {
    return WeightStatistics(totalEntries: 0);
  }

  factory WeightStatistics.fromEntries(List<WeightEntryModel> entries) {
    if (entries.isEmpty) {
      return WeightStatistics.empty();
    }

    // Sort by date (newest first)
    final sorted = List<WeightEntryModel>.from(entries)
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

    final latest = sorted.first.weight;
    final previous = sorted.length > 1 ? sorted[1].weight : null;
    
    final weights = entries.map((e) => e.weight).toList();
    final min = weights.reduce((a, b) => a < b ? a : b);
    final max = weights.reduce((a, b) => a > b ? a : b);
    final avg = weights.reduce((a, b) => a + b) / weights.length;

    double? change;
    if (previous != null) {
      change = latest - previous;
    }

    return WeightStatistics(
      latestWeight: latest,
      previousWeight: previous,
      minWeight: min,
      maxWeight: max,
      averageWeight: avg,
      weightChange: change,
      totalEntries: entries.length,
    );
  }
}
