import 'package:flutter/material.dart';

/// Achievement Type
enum AchievementType {
  distance,
  streak,
  runs,
  territory,
  landmark,
  special;

  String get displayName {
    switch (this) {
      case AchievementType.distance:
        return 'Distance';
      case AchievementType.streak:
        return 'Streak';
      case AchievementType.runs:
        return 'Runs';
      case AchievementType.territory:
        return 'Territory';
      case AchievementType.landmark:
        return 'Landmark';
      case AchievementType.special:
        return 'Special';
    }
  }
}

/// Achievement Tier
enum AchievementTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond;

  String get displayName {
    switch (this) {
      case AchievementTier.bronze:
        return 'Bronze';
      case AchievementTier.silver:
        return 'Silver';
      case AchievementTier.gold:
        return 'Gold';
      case AchievementTier.platinum:
        return 'Platinum';
      case AchievementTier.diamond:
        return 'Diamond';
    }
  }

  Color get color {
    switch (this) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
      case AchievementTier.platinum:
        return const Color(0xFFE5E4E2);
      case AchievementTier.diamond:
        return const Color(0xFFB9F2FF);
    }
  }
}

/// Achievement Model
class Achievement {
  final String id;
  final String name;
  final String description;
  final AchievementType type;
  final AchievementTier tier;
  final IconData icon;
  final double targetValue;
  final int points;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.tier,
    required this.icon,
    required this.targetValue,
    required this.points,
  });

  // Predefined achievements
  static const List<Achievement> all = [
    // Distance Achievements
    Achievement(
      id: 'first_km',
      name: 'First Steps',
      description: 'Complete your first kilometer',
      type: AchievementType.distance,
      tier: AchievementTier.bronze,
      icon: Icons.directions_walk,
      targetValue: 1.0,
      points: 10,
    ),
    Achievement(
      id: 'distance_5k',
      name: '5K Runner',
      description: 'Run a total of 5 kilometers',
      type: AchievementType.distance,
      tier: AchievementTier.bronze,
      icon: Icons.directions_run,
      targetValue: 5.0,
      points: 20,
    ),
    Achievement(
      id: 'distance_10k',
      name: '10K Master',
      description: 'Run a total of 10 kilometers',
      type: AchievementType.distance,
      tier: AchievementTier.silver,
      icon: Icons.emoji_events,
      targetValue: 10.0,
      points: 50,
    ),
    Achievement(
      id: 'distance_21k',
      name: 'Half Marathon',
      description: 'Run a total of 21 kilometers',
      type: AchievementType.distance,
      tier: AchievementTier.gold,
      icon: Icons.military_tech,
      targetValue: 21.0975,
      points: 100,
    ),
    Achievement(
      id: 'distance_42k',
      name: 'Marathon Hero',
      description: 'Run a total of 42 kilometers',
      type: AchievementType.distance,
      tier: AchievementTier.platinum,
      icon: Icons.workspace_premium,
      targetValue: 42.195,
      points: 200,
    ),
    Achievement(
      id: 'distance_100k',
      name: 'Ultra Runner',
      description: 'Run a total of 100 kilometers',
      type: AchievementType.distance,
      tier: AchievementTier.diamond,
      icon: Icons.star,
      targetValue: 100.0,
      points: 500,
    ),

    // Streak Achievements
    Achievement(
      id: 'streak_3',
      name: 'Getting Started',
      description: 'Maintain a 3-day running streak',
      type: AchievementType.streak,
      tier: AchievementTier.bronze,
      icon: Icons.local_fire_department,
      targetValue: 3.0,
      points: 15,
    ),
    Achievement(
      id: 'streak_7',
      name: 'Week Warrior',
      description: 'Maintain a 7-day running streak',
      type: AchievementType.streak,
      tier: AchievementTier.silver,
      icon: Icons.whatshot,
      targetValue: 7.0,
      points: 30,
    ),
    Achievement(
      id: 'streak_14',
      name: 'Dedicated Runner',
      description: 'Maintain a 14-day running streak',
      type: AchievementType.streak,
      tier: AchievementTier.gold,
      icon: Icons.local_fire_department,
      targetValue: 14.0,
      points: 75,
    ),
    Achievement(
      id: 'streak_30',
      name: 'Unstoppable',
      description: 'Maintain a 30-day running streak',
      type: AchievementType.streak,
      tier: AchievementTier.platinum,
      icon: Icons.whatshot,
      targetValue: 30.0,
      points: 150,
    ),

    // Runs Count Achievements
    Achievement(
      id: 'runs_1',
      name: 'First Run',
      description: 'Complete your first run',
      type: AchievementType.runs,
      tier: AchievementTier.bronze,
      icon: Icons.flag,
      targetValue: 1.0,
      points: 5,
    ),
    Achievement(
      id: 'runs_10',
      name: 'Regular Runner',
      description: 'Complete 10 runs',
      type: AchievementType.runs,
      tier: AchievementTier.silver,
      icon: Icons.check_circle,
      targetValue: 10.0,
      points: 25,
    ),
    Achievement(
      id: 'runs_50',
      name: 'Experienced Runner',
      description: 'Complete 50 runs',
      type: AchievementType.runs,
      tier: AchievementTier.gold,
      icon: Icons.verified,
      targetValue: 50.0,
      points: 100,
    ),
    Achievement(
      id: 'runs_100',
      name: 'Century Club',
      description: 'Complete 100 runs',
      type: AchievementType.runs,
      tier: AchievementTier.platinum,
      icon: Icons.stars,
      targetValue: 100.0,
      points: 250,
    ),

    // Territory Achievements
    Achievement(
      id: 'territory_1',
      name: 'Territory Hunter',
      description: 'Conquer your first territory',
      type: AchievementType.territory,
      tier: AchievementTier.bronze,
      icon: Icons.flag_circle,
      targetValue: 1.0,
      points: 20,
    ),
    Achievement(
      id: 'territory_5',
      name: 'Area Dominator',
      description: 'Conquer 5 territories',
      type: AchievementType.territory,
      tier: AchievementTier.silver,
      icon: Icons.location_on,
      targetValue: 5.0,
      points: 50,
    ),
    Achievement(
      id: 'territory_10',
      name: 'Map Master',
      description: 'Conquer 10 territories',
      type: AchievementType.territory,
      tier: AchievementTier.gold,
      icon: Icons.public,
      targetValue: 10.0,
      points: 125,
    ),

    // Landmark Achievements
    Achievement(
      id: 'landmark_1',
      name: 'Explorer',
      description: 'Discover your first landmark',
      type: AchievementType.landmark,
      tier: AchievementTier.bronze,
      icon: Icons.place,
      targetValue: 1.0,
      points: 15,
    ),
    Achievement(
      id: 'landmark_5',
      name: 'Tourist',
      description: 'Discover 5 landmarks',
      type: AchievementType.landmark,
      tier: AchievementTier.silver,
      icon: Icons.explore,
      targetValue: 5.0,
      points: 40,
    ),
    Achievement(
      id: 'landmark_10',
      name: 'Adventurer',
      description: 'Discover 10 landmarks',
      type: AchievementType.landmark,
      tier: AchievementTier.gold,
      icon: Icons.landscape,
      targetValue: 10.0,
      points: 100,
    ),
  ];

  static Achievement? findById(String id) {
    try {
      return all.firstWhere((achievement) => achievement.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// User Achievement Progress
class UserAchievement {
  final String userId;
  final String achievementId;
  final double currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  UserAchievement({
    required this.userId,
    required this.achievementId,
    required this.currentProgress,
    required this.isUnlocked,
    this.unlockedAt,
  });

  Achievement? get achievement => Achievement.findById(achievementId);

  double get progress {
    final target = achievement?.targetValue ?? 1.0;
    return (currentProgress / target).clamp(0.0, 1.0);
  }

  int get progressPercentage => (progress * 100).toInt();

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      userId: json['user_id'] as String,
      achievementId: json['achievement_id'] as String,
      currentProgress: (json['current_progress'] as num?)?.toDouble() ?? 0.0,
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.parse(json['unlocked_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'achievement_id': achievementId,
      'current_progress': currentProgress,
      'is_unlocked': isUnlocked,
      'unlocked_at': unlockedAt?.toIso8601String(),
    };
  }

  UserAchievement copyWith({
    String? userId,
    String? achievementId,
    double? currentProgress,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return UserAchievement(
      userId: userId ?? this.userId,
      achievementId: achievementId ?? this.achievementId,
      currentProgress: currentProgress ?? this.currentProgress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
