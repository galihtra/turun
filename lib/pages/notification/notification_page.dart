import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:turun/app/finite_state.dart';
import 'package:turun/data/model/notification/notification_model.dart';
import 'package:turun/data/model/running/run_mode.dart';
import 'package:turun/data/providers/notification/notification_provider.dart';
import 'package:turun/data/providers/running/running_provider.dart';
import 'package:turun/pages/notification/widgets/notification_card.dart';
import 'package:turun/pages/notification/widgets/notification_empty_state.dart';
import 'package:turun/pages/notification/widgets/notification_filter_chip.dart';
import 'package:turun/pages/running/running_page.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';

import '../../resources/values_app.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  NotificationType? selectedFilter;
  final List<Map<String, dynamic>> filters = [
    {'label': 'Semua', 'type': null},
    {'label': 'Under Attack', 'type': NotificationType.underAttack},
    {'label': 'Territory Lost', 'type': NotificationType.territoryLost},
    {'label': 'Rival Activity', 'type': NotificationType.rivalActivity},
    {'label': 'Opportunity', 'type': NotificationType.opportunity},
    {'label': 'Mission', 'type': NotificationType.missionComplete},
    {'label': 'Level Up', 'type': NotificationType.levelUp},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NotificationProvider>();
      // Subscribe first before fetching to avoid duplicate notifications
      provider.subscribeToNotifications();
      provider.fetchNotifications();
    });
  }

  void _handleNotificationTap(NotificationModel notification) {
    final provider = context.read<NotificationProvider>();
    
    // Mark as read
    provider.markAsRead(notification.id);
    
    // Show detail bottom sheet
    _showNotificationDetail(notification);
  }

  void _showNotificationDetail(NotificationModel notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetailSheet(notification),
    );
  }

  Widget _buildDetailSheet(NotificationModel notification) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          
          // Icon and Title
          Row(
            children: [
              Container(
                width: 56.w,
                height: 56.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getTypeColor(notification.type),
                      _getTypeColor(notification.type).withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  _getTypeIcon(notification.type),
                  color: Colors.white,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: AppStyles.title3SemiBold.copyWith(
                        color: AppColors.black[900],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _formatTime(notification.createdAt),
                      style: AppStyles.label3Regular.copyWith(
                        color: AppColors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          
          // Full message
          Text(
            notification.message,
            style: AppStyles.body2Regular.copyWith(
              color: AppColors.black[700],
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.h),
          
          // Territory info if available
          if (notification.territoryName != null) ...[
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.grey[100],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: _getTypeColor(notification.type),
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Territory',
                          style: AppStyles.label3Regular.copyWith(
                            color: AppColors.grey[600],
                          ),
                        ),
                        Text(
                          notification.territoryName!,
                          style: AppStyles.label1SemiBold.copyWith(
                            color: AppColors.black[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],
          
          // Action buttons
          Row(
            children: [
              // Close button
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    side: BorderSide(color: AppColors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Tutup',
                    style: AppStyles.label1SemiBold.copyWith(
                      color: AppColors.grey[700],
                    ),
                  ),
                ),
              ),
              
              // Navigate button if territory is available
              if (notification.territoryId != null) ...[
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToTerritory(notification.territoryId!);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getTypeColor(notification.type),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_run_rounded,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Pergi',
                          style: AppStyles.label1SemiBold.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8.h),
        ],
      ),
    );
  }

  Future<void> _navigateToTerritory(int territoryId) async {
    final runningProvider = context.read<RunningProvider>();
    
    // Make sure territories are loaded
    if (runningProvider.territories.isEmpty) {
      await runningProvider.loadTerritories();
    }
    
    // Find the territory
    final territoryIndex = runningProvider.territories.indexWhere(
      (t) => t.id == territoryId,
    );
    
    if (territoryIndex == -1) {
      // Territory not found, just open RunningPage
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RunningPage()),
        );
      }
      return;
    }
    
    final territory = runningProvider.territories[territoryIndex];
    
    // Switch to territory mode and select the territory
    runningProvider.switchMode(RunMode.territory);
    runningProvider.selectTerritory(territory);
    
    // Start navigation to the territory
    runningProvider.startNavigation(territory);
    
    // Navigate to RunningPage
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RunningPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        final notifications = provider.getNotificationsByType(selectedFilter);
        final unreadCount = provider.unreadCount;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBar(
            title: Text(
              'Notifikasi',
              style: AppStyles.title2SemiBold.copyWith(
                color: AppColors.black[900],
              ),
            ),
            backgroundColor: AppColors.backgroundColor,
            elevation: 0,
            centerTitle: false,
            actions: [
              if (unreadCount > 0)
                TextButton(
                  onPressed: () => provider.markAllAsRead(),
                  child: Text(
                    'Tandai Semua',
                    style: AppStyles.label3SemiBold.copyWith(
                      color: AppColors.blue[600],
                    ),
                  ),
                ),
            ],
          ),
          body: provider.state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Header with unread count
                    if (unreadCount > 0)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              AppColors.blue[50]!,
                              AppColors.purple[50]!,
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: AppColors.blue[600],
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$unreadCount',
                                style: AppStyles.label3SemiBold.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Notifikasi belum dibaca',
                              style: AppStyles.label2Medium.copyWith(
                                color: AppColors.black[700],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Filter chips
                    Container(
                      height: 50.h,
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        itemCount: filters.length,
                        separatorBuilder: (context, index) => SizedBox(width: 8.w),
                        itemBuilder: (context, index) {
                          final filter = filters[index];
                          final filterType = filter['type'] as NotificationType?;
                          final filterLabel = filter['label'] as String;

                          return NotificationFilterChip(
                            label: filterLabel,
                            isSelected: selectedFilter == filterType,
                            onTap: () => setState(() => selectedFilter = filterType),
                            selectedColor: _getFilterColor(filterType),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // Notifications list
                    Expanded(
                      child: notifications.isEmpty
                          ? const NotificationEmptyState()
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                              itemCount: notifications.length,
                              itemBuilder: (context, index) {
                                final notification = notifications[index];
                                return NotificationCard(
                                  notification: notification,
                                  onTap: () => _handleNotificationTap(notification),
                                );
                              },
                            ),
                    ),
                    AppGaps.kGap100,
                  ],
                ),
        );
      },
    );
  }

  Color _getTypeColor(NotificationType? type) {
    if (type == null) return AppColors.blue[600]!;

    switch (type) {
      case NotificationType.underAttack:
        return AppColors.red[500]!;
      case NotificationType.territoryLost:
        return AppColors.red[700]!;
      case NotificationType.rivalActivity:
        return AppColors.purple[400]!;
      case NotificationType.opportunity:
        return AppColors.green[500]!;
      case NotificationType.missionComplete:
        return AppColors.yellow[500]!;
      case NotificationType.levelUp:
        return AppColors.orange[500]!;
      case NotificationType.inactiveReminder:
        return AppColors.grey[600]!;
    }
  }

  Color _getFilterColor(NotificationType? type) => _getTypeColor(type);

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.underAttack:
        return Icons.warning_amber_rounded;
      case NotificationType.territoryLost:
        return Icons.cancel_rounded;
      case NotificationType.rivalActivity:
        return Icons.people_alt_rounded;
      case NotificationType.opportunity:
        return Icons.shield_outlined;
      case NotificationType.missionComplete:
        return Icons.emoji_events_rounded;
      case NotificationType.levelUp:
        return Icons.arrow_circle_up_rounded;
      case NotificationType.inactiveReminder:
        return Icons.bedtime_rounded;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} minggu yang lalu';
    } else {
      return '${(difference.inDays / 30).floor()} bulan yang lalu';
    }
  }
}
