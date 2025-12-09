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
      width: 290.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.blueLogo,
                  AppColors.blueLogo.withBlue(255),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.blueLogo.withOpacity(0.4)
                : Colors.black.withOpacity(0.08),
            blurRadius: isSelected ? 20 : 10,
            offset: Offset(0, isSelected ? 6 : 3),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          splashColor: isSelected
              ? Colors.white.withValues(alpha: 0.2)
              : AppColors.blueLogo.withValues(alpha: 0.1),
          highlightColor: isSelected
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.blueLogo.withValues(alpha: 0.05),
          child: Padding(
            padding: EdgeInsets.all(18.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================== HEADER ====================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Territory name
                    Expanded(
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : AppColors.blueLogo.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.3)
                                    : AppColors.blueLogo.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.location_city_rounded,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.blueLogo,
                              size: 18.sp,
                            ),
                          ),
                          AppGaps.kGap8,
                          Expanded(
                            child: Text(
                              displayName,
                              style: AppStyles.body1SemiBold.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.deepBlue,
                                fontSize: 15.sp,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppGaps.kGap8,
                    // Status badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: territory.isOwned
                            ? (isSelected
                                ? LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.3),
                                      Colors.white.withValues(alpha: 0.2),
                                    ],
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.blue.shade50,
                                      Colors.blue.shade100,
                                    ],
                                  ))
                            : (isSelected
                                ? LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.3),
                                      Colors.white.withValues(alpha: 0.2),
                                    ],
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.grey.shade100,
                                      Colors.grey.shade200,
                                    ],
                                  )),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: territory.isOwned
                              ? (isSelected
                                  ? Colors.white.withValues(alpha: 0.4)
                                  : Colors.blue.shade200)
                              : (isSelected
                                  ? Colors.white.withValues(alpha: 0.4)
                                  : Colors.grey.shade300),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            territory.isOwned
                                ? Icons.verified_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 12.sp,
                            color: territory.isOwned
                                ? (isSelected
                                    ? Colors.white
                                    : Colors.blue.shade700)
                                : (isSelected
                                    ? Colors.white
                                    : Colors.grey.shade700),
                          ),
                          AppGaps.kGap4,
                          Text(
                            territory.isOwned ? 'Owned' : 'Available',
                            style: AppStyles.body3SemiBold.copyWith(
                              color: territory.isOwned
                                  ? (isSelected
                                      ? Colors.white
                                      : Colors.blue.shade700)
                                  : (isSelected
                                      ? Colors.white
                                      : Colors.grey.shade700),
                              fontSize: 10.sp,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                AppGaps.kGap12,
                
                // ==================== DETAILS ====================
                // Region
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.place_rounded,
                        size: 14.sp,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.9)
                            : AppColors.grey.shade700,
                      ),
                      AppGaps.kGap6,
                      Flexible(
                        child: Text(
                          displayRegion,
                          style: AppStyles.body3Regular.copyWith(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.9)
                                : AppColors.grey.shade700,
                            fontSize: 12.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Distance if available
                if (distance != null) ...[
                  AppGaps.kGap8,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.orange.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.straighten_rounded,
                          size: 14.sp,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.9)
                              : Colors.orange.shade700,
                        ),
                        AppGaps.kGap6,
                        Text(
                          '${(distance! / 1000).toStringAsFixed(2)} km away',
                          style: AppStyles.body3SemiBold.copyWith(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.9)
                                : Colors.orange.shade700,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const Spacer(),
                
                AppGaps.kGap12,
                
                // ==================== NAVIGATE BUTTON ====================
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onNavigate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSelected ? Colors.white : AppColors.blueLogo,
                      foregroundColor:
                          isSelected ? AppColors.blueLogo : Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: isSelected ? 5 : 2,
                      shadowColor: isSelected
                          ? Colors.white.withValues(alpha: 0.5)
                          : AppColors.blueLogo.withValues(alpha: 0.3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.navigation_rounded,
                          size: 18.sp,
                        ),
                        AppGaps.kGap8,
                        Text(
                          'Go to Location',
                          style: AppStyles.body2SemiBold.copyWith(
                            color: isSelected
                                ? AppColors.blueLogo
                                : Colors.white,
                            fontSize: 14.sp,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
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