import 'package:flutter/material.dart';

import '../../../resources/colors_app.dart';
import '../../../resources/styles_app.dart';

class ProfileHeader extends StatelessWidget {
  final String username;
  final String? profileImageUrl;
  final VoidCallback onEditProfile;

  const ProfileHeader({
    super.key,
    required this.username,
    this.profileImageUrl,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD6E4F0),
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: ClipOval(
              child: profileImageUrl != null && profileImageUrl!.isNotEmpty
                  ? Image.network(
                      profileImageUrl!,
                      fit: BoxFit.cover,
                      width: 110,
                      height: 110,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.grey.shade400,
                        );
                      },
                    )
                  : Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.grey.shade400,
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          username,
          style: AppStyles.title2SemiBold.copyWith(color: AppColors.black),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: onEditProfile,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: Color(0xFF5B7C99), width: 1.5),
            ),
          ),
          child: Text(
            'Edit Profile',
            style: AppStyles.label2Medium.copyWith(
              color: AppColors.blueDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
