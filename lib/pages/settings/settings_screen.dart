import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
    _loadAppVersion();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Running Preferences', Icons.directions_run),
                      const Gap(12),
                      _buildRunningPreferences(),

                      const Gap(28),
                      _buildSectionTitle('Notifications', Icons.notifications_active),
                      const Gap(12),
                      _buildNotifications(),

                      const Gap(28),
                      _buildSectionTitle('Map & Display', Icons.map),
                      const Gap(12),
                      _buildMapDisplay(),

                      const Gap(28),
                      _buildSectionTitle('Privacy & Data', Icons.security),
                      const Gap(12),
                      _buildPrivacyData(),

                      const Gap(28),
                      _buildSectionTitle('About & Support', Icons.info),
                      const Gap(12),
                      _buildAboutSupport(),

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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.blueLogo,
            AppColors.blueLogo.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueLogo.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 28,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: AppStyles.title2SemiBold.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const Gap(4),
                Text(
                  'Customize your running experience',
                  style: AppStyles.body2Regular.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildRunningPreferences() {
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
            icon: Icons.straighten,
            title: 'Units of Measurement',
            subtitle: 'Kilometers, Kilograms',
            trailing: Icons.chevron_right,
            onTap: () {
              // Navigate to units settings
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.pause_circle,
            title: 'Auto-pause',
            subtitle: 'Pause when you stop moving',
            value: true,
            onChanged: (value) {},
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.gps_fixed,
            title: 'GPS Accuracy',
            subtitle: 'Best for Navigation',
            trailing: Icons.chevron_right,
            onTap: () {},
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.volume_up,
            title: 'Voice Coach',
            subtitle: 'Audio feedback during runs',
            value: false,
            onChanged: (value) {},
          ),
        ],
      ),
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
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.leaderboard,
            title: 'Leaderboard Updates',
            subtitle: 'Weekly ranking changes',
            value: false,
            onChanged: (value) {},
            iconColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildMapDisplay() {
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
            icon: Icons.map,
            title: 'Map Style',
            subtitle: 'Standard',
            trailing: Icons.chevron_right,
            onTap: () {},
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.route,
            title: 'Show Route Lines',
            subtitle: 'Display your running path',
            value: true,
            onChanged: (value) {},
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'System default',
            value: false,
            onChanged: (value) {},
            iconColor: const Color(0xFF2563EB),
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.brightness_high,
            title: 'Keep Screen On',
            subtitle: 'Stay awake during runs',
            value: true,
            onChanged: (value) {},
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
            icon: Icons.visibility,
            title: 'Activity Visibility',
            subtitle: 'Public',
            trailing: Icons.chevron_right,
            onTap: () {},
            iconColor: const Color(0xFF8B5CF6),
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
            icon: Icons.download,
            title: 'Export Data',
            subtitle: 'Download all your running data',
            trailing: Icons.chevron_right,
            onTap: () {},
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

  Widget _buildAboutSupport() {
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
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: _appVersion.isEmpty ? 'Loading...' : _appVersion,
            trailing: null,
            iconColor: AppColors.blueLogo,
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.description,
            title: 'Terms of Service',
            trailing: Icons.open_in_new,
            onTap: () async {
              final url = Uri.parse('https://turun.app/terms');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            trailing: Icons.open_in_new,
            onTap: () async {
              final url = Uri.parse('https://turun.app/privacy');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.help_outline,
            title: 'Help & FAQ',
            trailing: Icons.chevron_right,
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.star,
            title: 'Rate TuRun',
            subtitle: 'Support us with 5 stars ⭐',
            trailing: Icons.chevron_right,
            onTap: () {},
            iconColor: const Color(0xFFFFD700),
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.share,
            title: 'Share App',
            subtitle: 'Tell your friends about TuRun',
            trailing: Icons.chevron_right,
            onTap: () {
              Share.share(
                'Check out TuRun - Track, Unlocked, Run! 🏃\nhttps://turun.app',
                subject: 'Join me on TuRun!',
              );
            },
            iconColor: const Color(0xFF10B981),
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
            activeColor: AppColors.blueLogo,
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.blueLogo.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.clear_all,
                color: AppColors.blueLogo,
                size: 24,
              ),
            ),
            const Gap(12),
            const Text(
              'Clear Cache',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'This will clear cached data to free up storage space. Your activities and progress will not be affected.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueLogo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
