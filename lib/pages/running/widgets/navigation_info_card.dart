import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';
import 'package:turun/resources/values_app.dart';

class NavigationInfoCard extends StatelessWidget {
  final String destinationName;
  final String? distanceText;
  final String? durationText;
  final bool isLoadingRoute;
  final VoidCallback onStop;

  const NavigationInfoCard({
    super.key,
    required this.destinationName,
    this.distanceText,
    this.durationText,
    this.isLoadingRoute = false,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Destination name
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.blueLogo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.location_on,
                  color: AppColors.blueLogo,
                  size: 20.sp,
                ),
              ),
              AppGaps.kGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Navigating to',
                      style: AppStyles.body3Regular.copyWith(
                        color: AppColors.grey.shade600,
                      ),
                    ),
                    Text(
                      destinationName,
                      style: AppStyles.body1SemiBold.copyWith(
                        color: AppColors.deepBlue,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppGaps.kGap16,
          
          // ✅ Show loading or distance/time info
          if (isLoadingRoute)
            // Loading state
            Container(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Column(
                children: [
                  SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.blueLogo,
                    ),
                  ),
                  AppGaps.kGap8,
                  Text(
                    'Calculating route...',
                    style: AppStyles.body3Regular.copyWith(
                      color: AppColors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          else
            // Distance and time info
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.straighten,
                    label: 'Distance',
                    value: distanceText ?? '--- m',
                  ),
                ),
                Container(
                  width: 1,
                  height: 40.h,
                  color: AppColors.grey.shade300,
                  margin: EdgeInsets.symmetric(horizontal: 12.w),
                ),
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.access_time,
                    label: 'Est. Time',
                    value: durationText ?? '--- min',
                  ),
                ),
              ],
            ),
          
          AppGaps.kGap16,
          // Stop navigation button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onStop,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              icon: Icon(Icons.close, size: 18.sp),
              label: Text(
                'Stop Navigation',
                style: AppStyles.body2SemiBold.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: AppColors.blueLogo,
        ),
        AppGaps.kGap4,
        Text(
          label,
          style: AppStyles.body3Regular.copyWith(
            color: AppColors.grey.shade600,
          ),
        ),
        AppGaps.kGap4,
        Text(
          value,
          style: AppStyles.title3SemiBold.copyWith(
            color: AppColors.deepBlue,
          ),
        ),
      ],
    );
  }
}