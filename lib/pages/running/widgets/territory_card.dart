import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';
import 'package:turun/resources/values_app.dart';

import '../../../data/model/territory/territory_model.dart';

class TerritoryCard extends StatelessWidget {
  final Territory territory;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onNavigate;
  final double? distance;

  const TerritoryCard({
    super.key,
    required this.territory,
    required this.isSelected,
    required this.onTap,
    required this.onNavigate,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = territory.name ?? 'Territory #${territory.id}';
    final displayRegion = territory.region ?? 'Unknown Region';

    return Container(
      width: 280.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        gradient: isSelected
            ? AppColors.blueGradient
            : const LinearGradient(
                colors: [Colors.white, Colors.white],
              ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.blueLogo.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: isSelected ? 12 : 8,
            offset: Offset(0, isSelected ? 4 : 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: AppStyles.body1SemiBold.copyWith(
                          color: isSelected ? Colors.white : AppColors.deepBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: territory.isOwned
                            ? (isSelected
                                ? Colors.white.withOpacity(0.2)
                                : AppColors.blue.withOpacity(0.1))
                            : (isSelected
                                ? Colors.white.withOpacity(0.2)
                                : AppColors.grey.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        territory.isOwned ? 'Owned' : 'Available',
                        style: AppStyles.body3SemiBold.copyWith(
                          color: territory.isOwned
                              ? (isSelected ? Colors.white : AppColors.blue)
                              : (isSelected ? Colors.white : AppColors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
                AppGaps.kGap8,
                // Region
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14.sp,
                      color:
                          isSelected ? Colors.white70 : AppColors.grey.shade600,
                    ),
                    AppGaps.kGap4,
                    Expanded(
                      child: Text(
                        displayRegion,
                        style: AppStyles.body3Regular.copyWith(
                          color: isSelected
                              ? Colors.white70
                              : AppColors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                AppGaps.kGap12,
                // Distance if available
                if (distance != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.straighten,
                        size: 14.sp,
                        color: isSelected
                            ? Colors.white70
                            : AppColors.grey.shade600,
                      ),
                      AppGaps.kGap4,
                      Text(
                        '${(distance! / 1000).toStringAsFixed(2)} km away',
                        style: AppStyles.body3Regular.copyWith(
                          color: isSelected
                              ? Colors.white70
                              : AppColors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  AppGaps.kGap12,
                ],
                // Navigate button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onNavigate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSelected ? Colors.white : AppColors.blueLogo,
                      foregroundColor:
                          isSelected ? AppColors.blueLogo : Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    icon: Icon(Icons.navigation, size: 16.sp),
                    label: Text(
                      'Go to Location',
                      style: AppStyles.body2SemiBold.copyWith(
                        color: isSelected ? AppColors.blueLogo : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}