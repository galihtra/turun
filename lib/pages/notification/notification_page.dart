import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:turun/app/finite_state.dart';
import 'package:turun/data/model/notification/notification_model.dart';
import 'package:turun/data/providers/notification/notification_provider.dart';
import 'package:turun/pages/notification/widgets/notification_card.dart';
import 'package:turun/pages/notification/widgets/notification_empty_state.dart';
import 'package:turun/pages/notification/widgets/notification_filter_chip.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';

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
                                  onTap: () => provider.markAsRead(notification.id),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Color _getFilterColor(NotificationType? type) {
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
}
