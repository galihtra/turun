import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:turun/pages/auth/onboarding/stepper/widgets/onboarding_navigation_button.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';
import 'package:turun/resources/values_app.dart';

class OnboardingStep3Page extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;
  final VoidCallback onBack;
  final Map<String, dynamic>? initialData;

  const OnboardingStep3Page({
    super.key,
    required this.onComplete,
    required this.onBack,
    this.initialData,
  });

  @override
  State<OnboardingStep3Page> createState() => _OnboardingStep3PageState();
}

class _OnboardingStep3PageState extends State<OnboardingStep3Page> {
  final List<String> _selectedGoals = [];

  final List<Map<String, dynamic>> _goalOptions = [
    {'emoji': '👑', 'title': 'Dominate Territories'},
    {'emoji': '🔥', 'title': 'Burn Calories'},
    {'emoji': '🗺️', 'title': 'Map Exploration'},
    {'emoji': '🏆', 'title': 'Climb Leaderboard'},
    {'emoji': '⚡', 'title': 'Boost Stamina'},
    {'emoji': '📍', 'title': 'Hunt Landmarks'},
    {'emoji': '🚀', 'title': 'Improve Pace'},
    {'emoji': '🧘', 'title': 'Stress Relief'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null && widget.initialData!['goals'] != null) {
      _selectedGoals.addAll(List<String>.from(widget.initialData!['goals']));
    }
  }

  void _toggleGoal(String goal) {
    setState(() {
      if (_selectedGoals.contains(goal)) {
        _selectedGoals.remove(goal);
      } else {
        _selectedGoals.add(goal);
      }
    });
  }

  void _handleComplete() {
    widget.onComplete({
      'goals': _selectedGoals,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppGaps.kGap30,
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 1.8,
            ),
            itemCount: _goalOptions.length,
            itemBuilder: (context, index) {
              final goal = _goalOptions[index];
              final isSelected = _selectedGoals.contains(goal['title']);

              return GestureDetector(
                onTap: () => _toggleGoal(goal['title']),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.blueLogo.withValues(alpha: 0.1)
                        : AppColors.blueLight,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.blueLogo : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        goal['emoji'],
                        style: TextStyle(fontSize: 32.sp),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        goal['title'],
                        textAlign: TextAlign.center,
                        style: AppStyles.body3SemiBold.copyWith(
                          color: isSelected
                              ? AppColors.blueLogo
                              : AppColors.deepBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          AppGaps.kGap24,
          // ======================================================================
          // Selected goals count
          // ======================================================================
          if (_selectedGoals.isNotEmpty)
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.blueLight,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.blueLogo,
                    size: 20,
                  ),
                  AppGaps.kGap8,
                  Text(
                    '${_selectedGoals.length} goal${_selectedGoals.length > 1 ? 's' : ''} selected',
                    style: AppStyles.body2Medium.copyWith(
                      color: AppColors.blueLogo,
                    ),
                  ),
                ],
              ),
            ),
          // ======================================================================
          // Navigation Button
          // ======================================================================
          AppGaps.kGap40,
          OnboardingNavigationButton(
            onBack: widget.onBack,
            onNext: _handleComplete,
            nextButtonText: "Let's Go!",
          ),
        ],
      ),
    );
  }
}
