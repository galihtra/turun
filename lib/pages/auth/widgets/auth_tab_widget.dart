import 'package:flutter/material.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthTab extends StatelessWidget {
  final String title;
  final bool active;
  final VoidCallback onTap;

  const AuthTab({
    Key? key,
    required this.title,
    required this.active,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final underlineWidth = (title.length * 9).toDouble();

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: active
                ? AppStyles.body3SemiBold
                    .copyWith(color: AppColors.blueLogo) 
                : AppStyles.body3Regular
                    .copyWith(color: Colors.black54), 
          ),
          SizedBox(height: 8.h),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2, 
            width: active
                ? underlineWidth
                : 0, 
            color: active
                ? AppColors.blueLogo
                : Colors.transparent, 
          ),
        ],
      ),
    );
  }
}
