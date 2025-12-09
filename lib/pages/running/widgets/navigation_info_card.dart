import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';
import 'package:turun/resources/values_app.dart';

class NavigationInfoCard extends StatefulWidget {
  final String destinationName;
  final String? distanceText;
  final String? durationText;
  final bool isLoadingRoute;
  final VoidCallback onStop;
  final VoidCallback? onStartRunning;

  const NavigationInfoCard({
    super.key,
    required this.destinationName,
    this.distanceText,
    this.durationText,
    this.isLoadingRoute = false,
    required this.onStop,
    this.onStartRunning,
  });

  @override
  State<NavigationInfoCard> createState() => _NavigationInfoCardState();
}

class _NavigationInfoCardState extends State<NavigationInfoCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true; // Start expanded
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward(); // Start expanded
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.blue.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 5),
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: Colors.blue.shade100,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ==================== MINIMIZED HEADER ====================
              Row(
                children: [
                  // Icon with gradient background
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      gradient: AppColors.blueGradient,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blueLogo.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.navigation,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                  AppGaps.kGap12,

                  // Destination name + quick info (always visible)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.destinationName,
                          style: AppStyles.body1SemiBold.copyWith(
                            color: AppColors.deepBlue,
                            fontSize: 14.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!_isExpanded && !widget.isLoadingRoute) ...[
                          AppGaps.kGap4,
                          Text(
                            '${widget.distanceText ?? "---"} • ${widget.durationText ?? "---"}',
                            style: AppStyles.body3Regular.copyWith(
                              color: AppColors.grey.shade600,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // LIVE indicator (always visible)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Colors.green.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        AppGaps.kGap4,
                        Text(
                          'LIVE',
                          style: AppStyles.body3SemiBold.copyWith(
                            color: Colors.green.shade700,
                            fontSize: 9.sp,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  AppGaps.kGap8,

                  // Expand/Collapse button
                  InkWell(
                    onTap: _toggleExpand,
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: AppColors.blueLogo.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 20.sp,
                        color: AppColors.blueLogo,
                      ),
                    ),
                  ),
                ],
              ),

              // ==================== EXPANDABLE CONTENT ====================
              SizeTransition(
                sizeFactor: _expandAnimation,
                child: Column(
                  children: [
                    AppGaps.kGap16,

                    // ==================== ROUTE INFO ====================
                    if (widget.isLoadingRoute)
                      // Loading state
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 32.w,
                                  height: 32.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.blueLogo,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.route,
                                  color:
                                      AppColors.blueLogo.withValues(alpha: 0.5),
                                  size: 16.sp,
                                ),
                              ],
                            ),
                            AppGaps.kGap12,
                            Text(
                              'Calculating route...',
                              style: AppStyles.body2Regular.copyWith(
                                color: AppColors.grey.shade700,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      // Distance and time info
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Colors.blue.shade100,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Distance
                            Expanded(
                              child: _buildInfoItem(
                                icon: Icons.straighten_rounded,
                                label: 'Distance',
                                value: widget.distanceText ?? '---',
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade400,
                                    Colors.blue.shade600,
                                  ],
                                ),
                              ),
                            ),

                            // Divider
                            Container(
                              width: 1.5,
                              height: 50.h,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.blue.shade100,
                                    Colors.blue.shade300,
                                    Colors.blue.shade100,
                                  ],
                                ),
                              ),
                              margin: EdgeInsets.symmetric(horizontal: 12.w),
                            ),

                            // Duration
                            Expanded(
                              child: _buildInfoItem(
                                icon: Icons.access_time_rounded,
                                label: 'Est. Time',
                                value: widget.durationText ?? '---',
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orange.shade400,
                                    Colors.orange.shade600,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    AppGaps.kGap12,

                    // ==================== ACTION BUTTONS ====================
                    Row(
                      children: [
                        if (widget.onStartRunning != null) AppGaps.kGap8,

                        // Stop button
                        Expanded(
                          flex: widget.onStartRunning != null ? 1 : 1,
                          child: ElevatedButton.icon(
                            onPressed: widget.onStop,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 2,
                              shadowColor: AppColors.red.withValues(alpha: 0.4),
                            ),
                            icon: Icon(Icons.stop_rounded, size: 18.sp),
                            label: Text(
                              'Stop',
                              style: AppStyles.body2SemiBold.copyWith(
                                color: Colors.white,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Gradient gradient,
  }) {
    return Column(
      children: [
        // Icon with gradient background
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: (gradient.colors.first).withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 16.sp,
            color: Colors.white,
          ),
        ),
        AppGaps.kGap6,

        // Label
        Text(
          label,
          style: AppStyles.body3Regular.copyWith(
            color: AppColors.grey.shade600,
            fontSize: 10.sp,
          ),
        ),
        AppGaps.kGap4,

        // Value
        Text(
          value,
          style: AppStyles.title3SemiBold.copyWith(
            color: AppColors.deepBlue,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
