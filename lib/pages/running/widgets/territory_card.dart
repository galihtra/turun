import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.85;
    final cardHeight = cardWidth * 0.75;
    return Container(
      width: cardWidth,
      height: cardHeight,
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
                ? AppColors.blueLogo.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: isSelected ? 24 : 12,
            offset: Offset(0, isSelected ? 8 : 4),
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
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================== TOP SECTION (IMAGE + INFO) ====================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IMAGE
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.3),
                                      Colors.white.withValues(alpha: 0.1),
                                    ],
                                  )
                                : LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.grey.shade200,
                                      Colors.grey.shade300,
                                    ],
                                  ),
                          ),
                          child: territory.imageUrl != null
                              ? Image.network(
                                  territory.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.location_city_rounded,
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.8)
                                          : AppColors.blueLogo
                                              .withValues(alpha: 0.6),
                                      size: 32.sp,
                                    );
                                  },
                                )
                              : Icon(
                                  Icons.location_city_rounded,
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.8)
                                      : AppColors.blueLogo
                                          .withValues(alpha: 0.6),
                                  size: 32.sp,
                                ),
                        ),
                      ),
                    ),

                    SizedBox(width: 12.w),

                    // INFO - Right side of image
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top Row: Distance & Stars/Difficulty
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Distance (Left)
                              if (distance != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14.sp,
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.9)
                                          : AppColors.blueLogo,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      '${(distance! / 1000).toStringAsFixed(1)}km away',
                                      style: AppStyles.body3SemiBold.copyWith(
                                        color: isSelected
                                            ? Colors.white.withValues(alpha: 0.9)
                                            : AppColors.blueLogo,
                                        fontSize: 11.sp,
                                      ),
                                    ),
                                  ],
                                ),

                              // Stars & Difficulty (Right)
                              if (territory.difficulty != null)
                                Row(
                                  children: [
                                    // Stars - jumlah sesuai difficulty
                                    ...List.generate(
                                      _getStarCount(territory.difficulty!),
                                      (index) => Padding(
                                        padding: EdgeInsets.only(
                                            right: index < _getStarCount(territory.difficulty!) - 1 ? 2.w : 4.w),
                                        child: Icon(
                                          Icons.star,
                                          size: 14.sp,
                                          color: isSelected
                                              ? Colors.amber.shade300
                                              : Colors.amber.shade600,
                                        ),
                                      ),
                                    ),
                                    // Difficulty Badge
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white.withValues(alpha: 0.2)
                                            : _getDifficultyColor(
                                                    territory.difficulty!)
                                                .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6.r),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.white.withValues(alpha: 0.3)
                                              : _getDifficultyColor(
                                                      territory.difficulty!)
                                                  .withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        territory.difficulty!,
                                        style: AppStyles.body3SemiBold.copyWith(
                                          color: isSelected
                                              ? Colors.white
                                              : _getDifficultyColor(
                                                  territory.difficulty!),
                                          fontSize: 10.sp,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),

                          SizedBox(height: 8.h),

                          // Territory Name
                          Text(
                            displayName,
                            style: AppStyles.body1SemiBold.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.deepBlue,
                              fontSize: 15.sp,
                              height: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          SizedBox(height: 6.h),

                          // Reward & Area Size Row
                          Row(
                            children: [
                              _buildInfoChip(
                                icon: Icons.monetization_on,
                                label: '${territory.rewardPoints ?? 100} PTS',
                                color: Colors.amber,
                                isSelected: isSelected,
                              ),
                              SizedBox(width: 6.w),
                              if (territory.areaSizeKm != null)
                                _buildInfoChip(
                                  icon: Icons.square_foot,
                                  label:
                                      '${territory.areaSizeKm!.toStringAsFixed(2)} km²',
                                  color: Colors.purple,
                                  isSelected: isSelected,
                                ),
                            ],
                          ),

                          SizedBox(height: 6.h),

                          // Owner info
                          _buildInfoChip(
                            icon: Icons.person,
                            label: territory.ownerName != null
                                ? 'Owned by ${territory.ownerName!}'
                                : 'No owner',
                            color: territory.ownerName != null
                                ? Colors.green
                                : Colors.grey,
                            isSelected: isSelected,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // ==================== NAVIGATE BUTTON ====================
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onNavigate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSelected ? Colors.white : AppColors.blueLogo,
                      foregroundColor:
                          isSelected ? AppColors.blueLogo : Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 16.w,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: isSelected ? 5 : 2,
                      shadowColor: isSelected
                          ? Colors.white.withValues(alpha: 0.5)
                          : AppColors.blueLogo.withValues(alpha: 0.4),
                    ),
                    icon: Icon(
                      Icons.navigation_rounded,
                      size: 18.sp,
                    ),
                    label: Text(
                      'GO TO LOCATION',
                      style: AppStyles.body2SemiBold.copyWith(
                        fontSize: 13.sp,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.bold,
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

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required MaterialColor color,
    required bool isSelected,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withValues(alpha: 0.2)
            : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.3)
              : color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: isSelected ? Colors.white : color.shade700,
          ),
          SizedBox(width: 5.w),
          Text(
            label,
            style: AppStyles.body3SemiBold.copyWith(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.95)
                  : color.shade700,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  int _getStarCount(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 1;
      case 'medium':
        return 2;
      case 'hard':
        return 3;
      default:
        return 1;
    }
  }
}
