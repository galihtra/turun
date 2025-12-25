import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turun/app/custom_transition.dart';
import 'package:turun/app/finite_state.dart';
import 'package:turun/pages/profile/section/level_progress.dart';
import 'package:turun/resources/values_app.dart';

import '../../../data/providers/user/user_provider.dart';
import '../../../data/providers/achievement/achievement_provider.dart';
import '../../../data/services/auth_service.dart';
import '../../../resources/colors_app.dart';
import '../../../resources/styles_app.dart';
import '../../../app/app_dialog.dart';
import '../../../app/app_logger.dart';
import '../section/action_buttons.dart';
import '../section/best_records.dart';
import '../section/profile_header.dart';
import '../section/stats_grid.dart';
import '../section/weight_tracking.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final achievementProvider =
        Provider.of<AchievementProvider>(context, listen: false);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    if (currentUserId != null) {
      AppLogger.info(
          LogLabel.provider, 'Loading profile data for user: $currentUserId');
      await Future.wait([
        userProvider.loadUserData(currentUserId),
        achievementProvider.loadUserAchievements(),
      ]);
    } else {
      AppLogger.warning(LogLabel.auth, 'No authenticated user found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            // Show loading state
            if (userProvider.isLoading && userProvider.currentUser == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Show error state
            if (userProvider.error != null &&
                userProvider.currentUser == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load profile',
                      style: AppStyles.title3SemiBold.copyWith(
                        color: AppColors.deepBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userProvider.error ?? 'Unknown error',
                      style: AppStyles.body2Regular.copyWith(
                        color: AppColors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadUserData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final user = userProvider.currentUser;

            return SingleChildScrollView(
              child: Column(
                children: [
                  // ProfileHeader tanpa padding (banner full width)
                  ProfileHeader(
                    username: user?.username ?? user?.fullName ?? 'User',
                    profileImageUrl: user?.avatarUrl,
                    onEditProfile: () async {
                      final result = await Navigator.push(
                        context,
                        SlidePageRoute(
                          page: const ProfileEditScreen(),
                        ),
                      );

                      // Reload user data if profile was updated
                      if (result == true && mounted) {
                        _loadUserData();
                      }
                    },
                  ),
                  AppGaps.kGap24,
                  // Content dengan padding horizontal
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const LevelProgress(),
                        AppGaps.kGap24,
                        ActionButtons(
                          onLogout: _isLoggingOut
                              ? null
                              : () => _showLogoutDialog(context),
                        ),
                        AppGaps.kGap24,
                        const StatsGrid(),
                        AppGaps.kGap24,
                        const WeightTracking(),
                        AppGaps.kGap24,
                        const BestRecords(),
                        AppGaps.kGap24,
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.logout,
                      color: Colors.red.shade400,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Logout',
                    style: AppStyles.title3SemiBold.copyWith(
                      color: AppColors.deepBlue,
                    ),
                  ),
                ],
              ),
              content: Text(
                'Are you sure you want to logout?',
                style: AppStyles.body2Regular.copyWith(
                  color: AppColors.grey.shade700,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isLoggingOut
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    'Cancel',
                    style: AppStyles.body2SemiBold.copyWith(
                      color: _isLoggingOut
                          ? AppColors.grey.shade400
                          : AppColors.grey.shade600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isLoggingOut
                      ? null
                      : () async {
                          // ✅ Set loading state in both dialog and page
                          setDialogState(() => _isLoggingOut = true);
                          setState(() => _isLoggingOut = true);

                          // Close dialog
                          Navigator.of(dialogContext).pop();

                          // Execute logout
                          await _handleLogout(context);

                          // Reset loading state
                          if (mounted) {
                            setState(() => _isLoggingOut = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLoggingOut
                        ? Colors.red.shade200
                        : Colors.red.shade400,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoggingOut
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Logout',
                          style: AppStyles.body2SemiBold.copyWith(
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);

    AppLogger.debug(LogLabel.auth, 'Logout button pressed');

    // ✅ Double-check if already logging out
    if (authService.state.isLoading) {
      AppLogger.warning(LogLabel.auth,
          'Logout already in progress, skipping duplicate request');
      return;
    }

    final success = await authService.signOut();

    if (!context.mounted) return;

    if (success) {
      AppDialog.toastSuccess('Logged out successfully!');
    } else {
      AppDialog.toastError(authService.error ?? 'Failed to logout');
    }
  }
}
