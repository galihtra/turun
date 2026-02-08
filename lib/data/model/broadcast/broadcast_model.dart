/// Types of actions available for broadcasts
enum BroadcastActionType {
  none,
  link,    // Opens external URL in browser
  survey,  // Opens survey form
  inApp,   // Navigates to in-app screen
}

/// Icon identifiers for broadcasts
enum BroadcastIconName {
  megaphone,
  gift,
  star,
  survey,
  alert,
  trophy,
  heart,
  lightning,
}

/// Model representing a broadcast announcement
class BroadcastModel {
  final String id;
  final String title;
  final String? subtitle;
  final String? description;
  
  // Action configuration
  final BroadcastActionType actionType;
  final String? actionUrl;
  final String? actionLabel;
  
  // Visual configuration
  final String? imageUrl;
  final BroadcastIconName? iconName;
  final String? backgroundColor; // Hex color
  
  // Targeting
  final String targetAudience;
  
  // Scheduling
  final int priority;
  final bool isActive;
  final DateTime startDate;
  final DateTime? endDate;
  
  // Tracking (local state)
  final bool isViewed;
  final bool isDismissed;
  
  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;

  BroadcastModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.description,
    this.actionType = BroadcastActionType.none,
    this.actionUrl,
    this.actionLabel,
    this.imageUrl,
    this.iconName,
    this.backgroundColor,
    this.targetAudience = 'all',
    this.priority = 0,
    this.isActive = true,
    required this.startDate,
    this.endDate,
    this.isViewed = false,
    this.isDismissed = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BroadcastModel.fromJson(Map<String, dynamic> json) {
    return BroadcastModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String?,
      actionType: _parseActionType(json['action_type'] as String?),
      actionUrl: json['action_url'] as String?,
      actionLabel: json['action_label'] as String?,
      imageUrl: json['image_url'] as String?,
      iconName: _parseIconName(json['icon_name'] as String?),
      backgroundColor: json['background_color'] as String?,
      targetAudience: json['target_audience'] as String? ?? 'all',
      priority: json['priority'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date'] as String) 
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'action_type': actionType.name,
      'action_url': actionUrl,
      'action_label': actionLabel,
      'image_url': imageUrl,
      'icon_name': iconName?.name,
      'background_color': backgroundColor,
      'target_audience': targetAudience,
      'priority': priority,
      'is_active': isActive,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  BroadcastModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    BroadcastActionType? actionType,
    String? actionUrl,
    String? actionLabel,
    String? imageUrl,
    BroadcastIconName? iconName,
    String? backgroundColor,
    String? targetAudience,
    int? priority,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    bool? isViewed,
    bool? isDismissed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BroadcastModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      actionType: actionType ?? this.actionType,
      actionUrl: actionUrl ?? this.actionUrl,
      actionLabel: actionLabel ?? this.actionLabel,
      imageUrl: imageUrl ?? this.imageUrl,
      iconName: iconName ?? this.iconName,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      targetAudience: targetAudience ?? this.targetAudience,
      priority: priority ?? this.priority,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isViewed: isViewed ?? this.isViewed,
      isDismissed: isDismissed ?? this.isDismissed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if the broadcast should be displayed based on scheduling
  bool get isScheduledToShow {
    final now = DateTime.now();
    final afterStart = now.isAfter(startDate) || now.isAtSameMomentAs(startDate);
    final beforeEnd = endDate == null || now.isBefore(endDate!);
    return isActive && afterStart && beforeEnd;
  }

  /// Check if the broadcast has an action
  bool get hasAction => actionType != BroadcastActionType.none && actionUrl != null;

  /// Get icon emoji for display
  String get iconEmoji {
    switch (iconName) {
      case BroadcastIconName.megaphone:
        return '📢';
      case BroadcastIconName.gift:
        return '🎁';
      case BroadcastIconName.star:
        return '⭐';
      case BroadcastIconName.survey:
        return '📝';
      case BroadcastIconName.alert:
        return '⚠️';
      case BroadcastIconName.trophy:
        return '🏆';
      case BroadcastIconName.heart:
        return '❤️';
      case BroadcastIconName.lightning:
        return '⚡';
      default:
        return '📢';
    }
  }

  static BroadcastActionType _parseActionType(String? type) {
    switch (type) {
      case 'link':
        return BroadcastActionType.link;
      case 'survey':
        return BroadcastActionType.survey;
      case 'in_app':
        return BroadcastActionType.inApp;
      default:
        return BroadcastActionType.none;
    }
  }

  static BroadcastIconName? _parseIconName(String? name) {
    switch (name) {
      case 'megaphone':
        return BroadcastIconName.megaphone;
      case 'gift':
        return BroadcastIconName.gift;
      case 'star':
        return BroadcastIconName.star;
      case 'survey':
        return BroadcastIconName.survey;
      case 'alert':
        return BroadcastIconName.alert;
      case 'trophy':
        return BroadcastIconName.trophy;
      case 'heart':
        return BroadcastIconName.heart;
      case 'lightning':
        return BroadcastIconName.lightning;
      default:
        return null;
    }
  }
}
