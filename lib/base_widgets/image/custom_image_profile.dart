import 'package:flutter/material.dart';
import '../../resources/colors_app.dart';
import '../../resources/styles_app.dart';
import '../../resources/values_app.dart';

class CustomImageProfile extends StatelessWidget {
  final double size;
  final String? title;
  final TextStyle? titleStyle;
  final double spacer;
  final Color? backgroundColor;
  final Widget? placeholder;
  final ImageProvider? image;
  final Widget? editIcon;
  final VoidCallback? onTap;
  final double editIconSize;
  final Alignment editIconAlignment;
  final bool showEditIcon;
  final double borderWidth;
  final Color? borderColor;

  const CustomImageProfile({
    super.key,
    this.size = 120,
    this.backgroundColor,
    this.placeholder,
    this.image,
    this.editIcon,
    this.onTap,
    this.editIconSize = 36,
    this.editIconAlignment = Alignment.bottomRight,
    this.showEditIcon = true,
    this.borderWidth = 2.0,
    this.borderColor,
    this.title,
    this.titleStyle,
    this.spacer = AppSizes.s10,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: editIconAlignment,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor ?? AppColors.blueLight,
                border: Border.all(
                  color: borderColor ?? Colors.transparent,
                  width: borderWidth,
                ),
                image: image != null
                    ? DecorationImage(
                        image: image!,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: image == null
                  ? placeholder ??
                      Icon(
                        Icons.person,
                        size: size * 0.5,
                        color: AppColors.blueLogo,
                      )
                  : null,
            ),
            // ----------------------------------------------
            // Edit Icon
            // ----------------------------------------------
            if (showEditIcon)
              GestureDetector(
                onTap: onTap,
                child: Container(
                  width: editIconSize,
                  height: editIconSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.blueGradient,
                  ),
                  child: editIcon ??
                      Icon(
                        Icons.edit,
                        size: editIconSize * 0.5,
                        color: Colors.white,
                      ),
                ),
              ),
          ],
        ),
        // ----------------------------------------------
        // Spacer
        // ----------------------------------------------
        if (title != null) ...[
          SizedBox(height: spacer),
        ],
        // ----------------------------------------------
        // Title
        // ----------------------------------------------
        if (title != null)
          Text(
            title!,
            style: titleStyle ?? AppStyles.body2Regular,
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
