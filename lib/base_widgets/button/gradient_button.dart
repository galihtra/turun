import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  
  const GradientButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h, 
      margin: EdgeInsets.symmetric(horizontal: 8.w), 
      decoration: BoxDecoration(
        gradient: AppColors.blueGradient,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24.r), 
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: AppStyles.title2SemiBold.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
