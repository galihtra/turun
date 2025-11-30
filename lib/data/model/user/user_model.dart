class UserModel {
  final String id;
  final String? email;
  final String? fullName;
  final String? username;
  final DateTime? birthDate;
  final String? gender;
  final String? avatarUrl;
  final double? weight;
  final double? height;
  final String? profileColor;
  final List<String>? goals;
  final int totalPoints;
  final bool hasCompletedOnboarding;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    this.email,
    this.fullName,
    this.username,
    this.birthDate,
    this.gender,
    this.avatarUrl,
    this.weight,
    this.height,
    this.profileColor,
    this.goals,
    this.totalPoints = 0,
    this.hasCompletedOnboarding = false,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      fullName: json['full_name'] as String?,
      username: json['username'] as String?,
      birthDate: json['birth_date'] != null 
          ? DateTime.parse(json['birth_date'] as String) 
          : null,
      gender: json['gender'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      profileColor: json['profile_color'] as String? ?? '#0000FF',
      goals: json['goals'] != null 
          ? List<String>.from(json['goals'] as List) 
          : null,
      totalPoints: json['total_points'] as int? ?? 0,
      hasCompletedOnboarding: json['has_completed_onboarding'] as bool? ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'username': username,
      'birth_date': birthDate?.toIso8601String(),
      'gender': gender,
      'avatar_url': avatarUrl,
      'weight': weight,
      'height': height,
      'profile_color': profileColor,
      'goals': goals,
      'total_points': totalPoints,
      'has_completed_onboarding': hasCompletedOnboarding,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? username,
    DateTime? birthDate,
    String? gender,
    String? avatarUrl,
    double? weight,
    double? height,
    String? profileColor,
    List<String>? goals,
    int? totalPoints,
    bool? hasCompletedOnboarding,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      profileColor: profileColor ?? this.profileColor,
      goals: goals ?? this.goals,
      totalPoints: totalPoints ?? this.totalPoints,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}