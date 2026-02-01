import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:turun/base_widgets/dialogs/gamified_dialog.dart';
import 'package:turun/data/services/auth_service.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Notifications', Icons.notifications_active),
                      const Gap(12),
                      _buildNotifications(),
                      const Gap(28),
                      _buildSectionTitle('Privacy & Data', Icons.security),
                      const Gap(12),
                      _buildPrivacyData(),
                      const Gap(40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.blueLogo.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.blueLogo,
            size: 20,
          ),
        ),
        const Gap(12),
        Text(
          title,
          style: AppStyles.title3SemiBold.copyWith(
            color: const Color(0xFF0D1B2A),
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildNotifications() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.notifications,
            title: 'Push Notifications',
            subtitle: 'Enable all notifications',
            value: true,
            onChanged: (value) {},
            iconColor: const Color(0xFFFF6B6B),
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.flag,
            title: 'Territory Alerts',
            subtitle: 'Under attack & conquest notifications',
            value: true,
            onChanged: (value) {},
            iconColor: const Color(0xFF8B5CF6),
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.emoji_events,
            title: 'Achievement Unlocked',
            subtitle: 'Get notified of new achievements',
            value: true,
            onChanged: (value) {},
            iconColor: const Color(0xFFFFD700),
          ),
        ],
      ),
    );
  }



  Widget _buildPrivacyData() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            subtitle: 'Delete my account permanently',
            trailing: Icons.chevron_right,
            onTap: () => _showDeleteAccountDialog(),
            iconColor: const Color(0xFFEF4444),
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.location_on,
            title: 'Location Sharing',
            subtitle: 'Share real-time location',
            value: false,
            onChanged: (value) {},
            iconColor: const Color(0xFFFF6B6B),
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.clear_all,
            title: 'Clear Cache',
            subtitle: 'Free up storage space',
            trailing: Icons.chevron_right,
            onTap: () {
              _showClearCacheDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    IconData? trailing,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.blueLogo).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.blueLogo,
                size: 22,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.body1SemiBold.copyWith(
                      color: const Color(0xFF0D1B2A),
                      fontSize: 15,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const Gap(4),
                    Text(
                      subtitle,
                      style: AppStyles.body2Regular.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              Icon(
                trailing,
                color: Colors.grey.shade400,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.blueLogo).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.blueLogo,
              size: 22,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.body1SemiBold.copyWith(
                    color: const Color(0xFF0D1B2A),
                    fontSize: 15,
                  ),
                ),
                if (subtitle != null) ...[
                  const Gap(4),
                  Text(
                    subtitle,
                    style: AppStyles.body2Regular.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.blueLogo,
            activeTrackColor: AppColors.blueLogo.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: Colors.grey.shade200,
      ),
    );
  }

  void _showClearCacheDialog() {
    GamifiedDialog.show(
      context: context,
      title: 'Clear Cache',
      description: 'This will clear cached data to free up storage space. Your activities and progress will not be affected.',
      icon: Icons.cleaning_services_rounded,
      headerGradient: [
        AppColors.blueLogo,
        AppColors.blueDark,
      ],
      primaryButtonText: 'CLEAR',
      onPrimaryPressed: () {
        // Clear cache logic
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                Gap(12),
                Text('Cache cleared successfully!'),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      secondaryButtonText: 'CANCEL',
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }

  void _showDeleteAccountDialog() {
    bool isDeleting = false;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with gradient
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Animated skull/warning icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.dangerous_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                        const Gap(12),
                        const Text(
                          '⚠️ DANGER ZONE ⚠️',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          'Account Deletion',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'You will lose everything!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const Gap(16),
                        
                        // Stats cards - what will be lost
                        Row(
                          children: [
                            Expanded(
                              child: _buildLossCard(
                                icon: Icons.flag,
                                label: 'Territories',
                                color: const Color(0xFF8B5CF6),
                              ),
                            ),
                            const Gap(8),
                            Expanded(
                              child: _buildLossCard(
                                icon: Icons.emoji_events,
                                label: 'Achievements',
                                color: const Color(0xFFFFD700),
                              ),
                            ),
                          ],
                        ),
                        const Gap(8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildLossCard(
                                icon: Icons.directions_run,
                                label: 'Run History',
                                color: const Color(0xFF10B981),
                              ),
                            ),
                            const Gap(8),
                            Expanded(
                              child: _buildLossCard(
                                icon: Icons.leaderboard,
                                label: 'Rankings',
                                color: const Color(0xFF3B82F6),
                              ),
                            ),
                          ],
                        ),
                        
                        const Gap(20),
                        
                        // Warning text
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFECACA),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Color(0xFFDC2626),
                                size: 20,
                              ),
                              Gap(8),
                              Expanded(
                                child: Text(
                                  'This action is permanent and cannot be undone!',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFDC2626),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const Gap(24),
                        
                        // Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isDeleting ? null : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Keep Account',
                                  style: TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isDeleting
                                    ? null
                                    : () async {
                                        setDialogState(() => isDeleting = true);
                                        
                                        final authService = context.read<AuthService>();
                                        final success = await authService.deleteAccount();
                                        
                                        if (!context.mounted) return;
                                        Navigator.pop(context);
                                        
                                        if (success) {
                                          Navigator.of(context).popUntil((route) => route.isFirst);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Row(
                                                children: [
                                                  Icon(Icons.check_circle, color: Colors.white),
                                                  Gap(12),
                                                  Text('Account deleted successfully'),
                                                ],
                                              ),
                                              backgroundColor: Color(0xFF10B981),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  const Icon(Icons.error, color: Colors.white),
                                                  const Gap(12),
                                                  Text(authService.error ?? 'Failed to delete account'),
                                                ],
                                              ),
                                              backgroundColor: const Color(0xFFEF4444),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFDC2626),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isDeleting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Delete Forever',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLossCard({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const Gap(4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
