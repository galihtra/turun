import 'package:flutter/material.dart';

import '../../resources/colors_app.dart';
import '../../resources/styles_app.dart';
import '../../resources/values_app.dart';

class CustomBadgeOutlineButton extends StatelessWidget {
  final String buttonText;
  final IconData? iconData;
  final VoidCallback? onPressed;

  const CustomBadgeOutlineButton({
    super.key,
    required this.buttonText,
    this.iconData,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.w16,
          vertical: AppDimens.h2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.r30),
          side: const BorderSide(color: AppColors.deepBlue, width: 1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            buttonText,
            style: AppStyles.body2Regular.copyWith(color: AppColors.deepBlue),
          ),
          if (iconData != null) ...[
            AppGaps.kGap8,
            Icon(
              iconData,
              size: 14,
              color: AppColors.deepBlue,
            ),
          ],
        ],
      ),
    );
  }
}
