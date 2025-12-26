import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:turun/data/model/notification/notification_model.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : AppColors.blueLight,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: notification.isRead
                ? AppColors.grey[200]!
                : _getTypeColor().withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _getTypeColor().withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Accent gradient overlay
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 4.w,
                height: 100.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _getTypeColor(),
                      _getTypeColor().withOpacity(0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    bottomLeft: Radius.circular(16.r),
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  _buildIcon(),
                  SizedBox(width: 12.w),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: AppStyles.label1SemiBold.copyWith(
                                  color: AppColors.black[900],
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8.w,
                                height: 8.h,
                                decoration: BoxDecoration(
                                  color: _getTypeColor(),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          notification.message,
                          style: AppStyles.body3Regular.copyWith(
                            color: AppColors.black[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getTypeColor(),
            _getTypeColor().withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: _getTypeColor().withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        _getTypeIcon(),
        color: Colors.white,
        size: 24.sp,
      ),
    );
  }

  Color _getTypeColor() {
    switch (notification.type) {
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

  IconData _getTypeIcon() {
    switch (notification.type) {
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
