enum NotificationType {
  underAttack,      // ⚠️ Wilayah sedang diserang
  territoryLost,    // ❌ Wilayah hilang
  rivalActivity,    // 👥 Aktivitas rival
  opportunity,      // 🛡️ Peluang claim territory
  missionComplete,  // 🏅 Misi selesai
  levelUp,          // 🆙 Naik level
  inactiveReminder, // 💤 Pengingat aktivitas
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final int? territoryId;
  final String? territoryName;
  final String? rivalUsername;
  final int? rewardPoints;
  final int? newLevel;
  final Map<String, dynamic>? extraData;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.territoryId,
    this.territoryName,
    this.rivalUsername,
    this.rewardPoints,
    this.newLevel,
    this.extraData,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Parse territory_id - handle both String and int from Supabase
    int? parsedTerritoryId;
    if (json['territory_id'] != null) {
      if (json['territory_id'] is int) {
        parsedTerritoryId = json['territory_id'] as int;
      } else if (json['territory_id'] is String) {
        parsedTerritoryId = int.tryParse(json['territory_id'] as String);
      }
    }

    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: _parseNotificationType(json['type'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      territoryId: parsedTerritoryId,
      territoryName: json['territory_name'] as String?,
      rivalUsername: json['rival_username'] as String?,
      rewardPoints: json['reward_points'] as int?,
      newLevel: json['new_level'] as int?,
      extraData: json['extra_data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type.name,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'territory_id': territoryId,
      'territory_name': territoryName,
      'rival_username': rivalUsername,
      'reward_points': rewardPoints,
      'new_level': newLevel,
      'extra_data': extraData,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    int? territoryId,
    String? territoryName,
    String? rivalUsername,
    int? rewardPoints,
    int? newLevel,
    Map<String, dynamic>? extraData,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      territoryId: territoryId ?? this.territoryId,
      territoryName: territoryName ?? this.territoryName,
      rivalUsername: rivalUsername ?? this.rivalUsername,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      newLevel: newLevel ?? this.newLevel,
      extraData: extraData ?? this.extraData,
    );
  }

  static NotificationType _parseNotificationType(String type) {
    switch (type) {
      case 'underAttack':
        return NotificationType.underAttack;
      case 'territoryLost':
        return NotificationType.territoryLost;
      case 'rivalActivity':
        return NotificationType.rivalActivity;
      case 'opportunity':
        return NotificationType.opportunity;
      case 'missionComplete':
        return NotificationType.missionComplete;
      case 'levelUp':
        return NotificationType.levelUp;
      case 'inactiveReminder':
        return NotificationType.inactiveReminder;
      default:
        return NotificationType.opportunity;
    }
  }
}
