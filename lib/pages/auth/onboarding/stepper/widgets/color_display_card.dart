import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:turun/app/extensions.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';

class ColorDisplayCard extends StatelessWidget {
  final Color selectedColor;
  final VoidCallback onTap;

  const ColorDisplayCard({
    super.key,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Territory Color',
          style: AppStyles.body1SemiBold.copyWith(
            color: AppColors.deepBlue,
          ),
        ),
        SizedBox(height: 16.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.blueLight,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.blueLogo.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                // Color Preview Circle
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: selectedColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: selectedColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Color',
                        style: AppStyles.body3Regular.copyWith(
                          color: AppColors.deepBlue.withValues(alpha: 0.6),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        selectedColor.toHex(), // ✅ Use extension
                        style: AppStyles.body1SemiBold.copyWith(
                          color: AppColors.deepBlue,
                          fontFamily: 'monospace',
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Tap to change',
                        style: AppStyles.body3Regular.copyWith(
                          color: AppColors.blueLogo,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.edit,
                  color: AppColors.blueLogo,
                  size: 24.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
