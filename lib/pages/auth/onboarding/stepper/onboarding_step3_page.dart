import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:turun/base_widgets/button/gradient_button.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';

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
          SizedBox(height: 32.h),

          // Goals Grid
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
                        ? AppColors.blueLogo.withOpacity(0.1)
                        : AppColors.blueLight,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.blueLogo
                          : Colors.transparent,
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

          SizedBox(height: 24.h),

          // Selected goals count
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
                  SizedBox(width: 8.w),
                  Text(
                    '${_selectedGoals.length} goal${_selectedGoals.length > 1 ? 's' : ''} selected',
                    style: AppStyles.body2Medium.copyWith(
                      color: AppColors.blueLogo,
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 40.h),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    side: const BorderSide(color: AppColors.blueLogo),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: AppColors.blueLogo,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                flex: 3,
                child: GradientButton(
                  text: "Let's Go",
                  onTap: _handleComplete,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}