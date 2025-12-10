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
                ? AppColors.blueLogo.withOpacity(0.4)
                : Colors.black.withOpacity(0.1),
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
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                          width: 75.w,
                          height: 75.w,
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

                    AppGaps.kGap12,

                    // INFO
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stars & Difficulty Badge Row - Top Right
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (territory.difficulty != null) ...[
                                // Stars
                                Row(
                                  children: List.generate(
                                    3,
                                    (index) => Padding(
                                      padding: EdgeInsets.only(
                                          right: index < 2 ? 2.w : 0),
                                      child: Icon(
                                        Icons.star,
                                        size: 16.sp,
                                        color: _getDifficultyStarColor(
                                          territory.difficulty!,
                                          index,
                                          isSelected,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                // Difficulty Badge
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.2)
                                        : _getDifficultyColor(
                                                territory.difficulty!)
                                            .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8.r),
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
                                      fontSize: 11.sp,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),

                          AppGaps.kGap8,

                          // Distance
                          if (distance != null) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : AppColors.blueLogo.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14.sp,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.blueLogo,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${(distance! / 1000).toStringAsFixed(1)}km',
                                    style: AppStyles.body3SemiBold.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.blueLogo,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AppGaps.kGap8,
                          ],
                          // Territory Name
                          Text(
                            displayName,
                            style: AppStyles.body1SemiBold.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.deepBlue,
                              fontSize: 16.sp,
                              height: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          AppGaps.kGap8,
                          Row(
                            children: [
                              _buildInfoChip(
                                icon: Icons.monetization_on,
                                label: '${territory.rewardPoints ?? 100} PTS',
                                color: Colors.amber,
                                isSelected: isSelected,
                              ),
                              AppGaps.kGap6,
                              // Area Size
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

                          AppGaps.kGap6,
  
                          // Owner
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

                AppGaps.kGap6,
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
                        vertical: 10.h,
                        horizontal: 14.w,
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
                      size: 16.sp,
                    ),
                    label: Text(
                      'Navigate to Location',
                      style: AppStyles.body2SemiBold.copyWith(
                          fontSize: 13.sp,
                          letterSpacing: 0.2,
                          color:
                              isSelected ? AppColors.blueLogo : Colors.white),
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

  Color _getDifficultyStarColor(String difficulty, int index, bool isSelected) {
    if (isSelected) {
      return Colors.amber.shade300;
    }

    switch (difficulty.toLowerCase()) {
      case 'easy':
        return index < 1 ? Colors.amber.shade600 : Colors.grey.shade300;
      case 'medium':
        return index < 2 ? Colors.amber.shade600 : Colors.grey.shade300;
      case 'hard':
        return Colors.amber.shade600;
      default:
        return Colors.grey.shade300;
    }
  }
}
