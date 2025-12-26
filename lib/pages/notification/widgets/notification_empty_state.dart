import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';

class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated bell icon
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.blue[200]!,
                  AppColors.blue[100]!,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none,
              size: 64.sp,
              color: AppColors.blue[600],
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Belum Ada Notifikasi',
            style: AppStyles.title2SemiBold.copyWith(
              color: AppColors.black[800],
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48.w),
            child: Text(
              'Kamu akan mendapatkan notifikasi untuk achievement, challenge, dan update terbaru di sini',
              style: AppStyles.body3Regular.copyWith(
                color: AppColors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
