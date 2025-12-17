import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turun/app/custom_transition.dart';
import 'package:turun/app/finite_state.dart';
import 'package:turun/resources/values_app.dart';
import '../../../data/providers/user/user_provider.dart';
import '../../../data/services/auth_service.dart';
import '../../../resources/colors_app.dart';
import '../../../resources/styles_app.dart';
import '../../../app/app_dialog.dart';
import '../../../app/app_logger.dart';
import '../section/profile_header.dart';
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
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    if (currentUserId != null) {
      AppLogger.info(
          LogLabel.provider, 'Loading profile data for user: $currentUserId');
      await userProvider.loadUserData(currentUserId);
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
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
                  const LevelProgressSection(),
                  AppGaps.kGap24,
                  ActionButtons(
                    onLogout:
                        _isLoggingOut ? null : () => _showLogoutDialog(context),
                  ),
                  AppGaps.kGap24,
                  const StatsGrid(),
                  AppGaps.kGap24,
                  const WeightTrackingCard(),
                  AppGaps.kGap24,
                  const BestRecordsSection(),
                  AppGaps.kGap24,
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
      barrierDismissible: false, // ✅ Prevent dismiss by tapping outside
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

class ActionButtons extends StatelessWidget {
  final VoidCallback? onLogout; // ✅ FIXED: Changed to nullable

  const ActionButtons({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context,
          Icons.settings_outlined,
          'Settings',
          const Color(0xFF4A90E2),
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settings coming soon!')),
            );
          },
        ),
        _buildActionButton(
          context,
          Icons.share_outlined,
          'Share',
          const Color(0xFF4A90E2),
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Share coming soon!')),
            );
          },
        ),
        _buildActionButton(
          context,
          Icons.logout,
          'Logout',
          Colors.red.shade400,
          onLogout, // ✅ Can be null now
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback? onTap, // ✅ FIXED: Changed to nullable
  ) {
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0, // ✅ Visual feedback when disabled
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppStyles.label3SemiBold.copyWith(
                color: const Color(0xFF1A2B3C),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LevelProgressSection extends StatelessWidget {
  const LevelProgressSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2B3C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shield,
                    color: Color(0xFFFFD700), size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                'Gold',
                style: AppStyles.title3SemiBold.copyWith(
                  color: const Color(0xFF1A2B3C),
                ),
              ),
              const Spacer(),
              Text(
                '2500 Points',
                style: AppStyles.label2Medium.copyWith(
                  color: const Color(0xFF8896A6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              value: 0.6,
              minHeight: 8,
              backgroundColor: Color(0xFFE8EDF2),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLevelBadge('Silver', Icons.shield, true, false),
              _buildLevelConnector(true),
              _buildLevelBadge('Gold', Icons.shield, true, true),
              _buildLevelConnector(false),
              _buildLevelBadge('Diamond', Icons.shield, false, false),
              _buildLevelConnector(false),
              _buildLevelBadge('Platinum', Icons.shield, false, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge(
      String label, IconData icon, bool achieved, bool current) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: achieved ? const Color(0xFF1A2B3C) : const Color(0xFFE8EDF2),
            shape: BoxShape.circle,
            border: current
                ? Border.all(color: const Color(0xFF4A90E2), width: 3)
                : null,
          ),
          child: Icon(
            icon,
            size: 20,
            color: achieved ? const Color(0xFFFFD700) : const Color(0xFFB0BEC5),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: achieved ? const Color(0xFF1A2B3C) : const Color(0xFFB0BEC5),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelConnector(bool achieved) {
    return Container(
      width: 20,
      height: 2,
      color: achieved ? const Color(0xFF4A90E2) : const Color(0xFFE8EDF2),
      margin: const EdgeInsets.only(bottom: 24),
    );
  }
}

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(context, Icons.directions_run, 'Total Runs', '10', null,
            const Color(0xFF4A90E2)),
        _buildStatCard(context, Icons.crop_square, 'Total Area', '450', 'km²',
            const Color(0xFF4A90E2)),
        _buildStatCard(context, Icons.timeline, 'Total Distance', '24', 'km',
            const Color(0xFF4A90E2)),
        _buildStatCard(context, Icons.access_time, 'Total Duration', '01:30:15',
            null, const Color(0xFF4A90E2)),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String title,
    String value, [
    String? unit,
    Color color = const Color(0xFF4A90E2),
  ]) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppStyles.label3Medium.copyWith(
                    color: const Color(0xFF8896A6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppStyles.title1SemiBold.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A2B3C),
                  height: 1,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: AppStyles.label3Medium.copyWith(
                      color: const Color(0xFF8896A6),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class WeightTrackingCard extends StatelessWidget {
  const WeightTrackingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weight',
                style: AppStyles.title3SemiBold.copyWith(
                  color: const Color(0xFF1A2B3C),
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add weight coming soon!')),
                  );
                },
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'ADD',
                  style: AppStyles.label2SemiBold.copyWith(
                    color: const Color(0xFF4A90E2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '0.0',
                style: AppStyles.heading2SemiBold.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A2B3C),
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'kg',
                  style: AppStyles.title3Medium.copyWith(
                    color: const Color(0xFF8896A6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Last 30 days',
            style: AppStyles.label3Regular.copyWith(
              color: const Color(0xFFB0BEC5),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 100,
            child: CustomPaint(
              painter: WeightChartPainter(),
              size: const Size(double.infinity, 100),
            ),
          ),
        ],
      ),
    );
  }
}

class WeightChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4A90E2)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final points = [
      0.6,
      0.65,
      0.55,
      0.7,
      0.6,
      0.5,
      0.55,
      0.45,
      0.4,
      0.35,
      0.3,
      0.2
    ];

    path.moveTo(0, size.height * points[0]);

    for (int i = 0; i < points.length; i++) {
      final x = (size.width / (points.length - 1)) * i;
      final y = size.height * points[i];

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (size.width / (points.length - 1)) * (i - 1);
        final prevY = size.height * points[i - 1];
        final cpX = (prevX + x) / 2;

        path.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BestRecordsSection extends StatelessWidget {
  const BestRecordsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Best Records',
            style: AppStyles.title2SemiBold.copyWith(
              color: const Color(0xFF1A2B3C),
            ),
          ),
        ),
        _buildRecordCard(context, Icons.polyline, 'LONGEST DISTANCE', '90',
            'km', const Color(0xFF4A90E2)),
        const SizedBox(height: 12),
        _buildRecordCard(context, Icons.speed, 'BEST PACE', '0.0', 'min/km',
            const Color(0xFF4A90E2)),
        const SizedBox(height: 12),
        _buildRecordCard(context, Icons.timer_outlined, 'LONGEST DURATION',
            '01:30:15', null, const Color(0xFF4A90E2)),
      ],
    );
  }

  Widget _buildRecordCard(BuildContext context, IconData icon, String title,
      String value, String? unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.label2SemiBold.copyWith(
                    color: const Color(0xFF4A90E2),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: AppStyles.title1SemiBold.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A2B3C),
                        height: 1,
                      ),
                    ),
                    if (unit != null) ...[
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          unit,
                          style: AppStyles.label3Medium.copyWith(
                            color: const Color(0xFF8896A6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
