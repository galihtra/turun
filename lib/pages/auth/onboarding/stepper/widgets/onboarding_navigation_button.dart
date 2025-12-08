import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:turun/base_widgets/button/gradient_button.dart';
import 'package:turun/resources/colors_app.dart';

class OnboardingNavigationButton extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  final String nextButtonText;

  const OnboardingNavigationButton({
    super.key,
    required this.onBack,
    required this.onNext,
    this.nextButtonText = 'Next',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onBack,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
              side: const BorderSide(color: AppColors.blueLogo),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.blueLogo,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          flex: 3,
          child: GradientButton(
            text: nextButtonText,
            onTap: onNext,
          ),
        ),
      ],
    );
  }
}