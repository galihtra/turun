import 'package:flutter/material.dart';

import '../../resources/colors_app.dart';
import '../../resources/styles_app.dart';

AppBar normalAppBar(String title, {bool automaticallyImplyLeading = true}) {
  return AppBar(
    elevation: 1,
    automaticallyImplyLeading: true,
    title: Text(
      title,
    ),
  );
}

class IosAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData? backIcon;
  final Color? backgroundColor;
  final double elevation;
  final void Function()? onBackTap;
  final List<Widget>? actions;
  final bool? centerTitle;
  final Color? txtColor;
  final bool dontShowBackButton;

  const IosAppBar({
    super.key,
    required this.title,
    this.backIcon,
    this.backgroundColor,
    this.elevation = 0.8,
    this.onBackTap,
    this.actions,
    this.centerTitle,
    this.txtColor,  this.dontShowBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: actions,
      centerTitle: centerTitle ?? false,
      titleSpacing: 0,
      elevation: elevation,
      title: Text(
        title,
        style: AppStyles.label1Medium.copyWith(
          color: txtColor ?? AppColors.black,
        ),
      ),
      leading: 
      dontShowBackButton == false ?
      IconButton(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        icon: Icon(
          backIcon ?? Icons.arrow_back_ios_rounded,
          size: 20,
          color: txtColor ?? AppColors.black,
        ),
        onPressed: onBackTap ??
            () {
              Navigator.pop(context);
            },
      ) : const SizedBox.shrink(),
      backgroundColor: backgroundColor,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomBigAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color? backgroundColor;
  final List<Widget>? actions;

  const CustomBigAppBar(
      {super.key, required this.title, this.backgroundColor, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 24,
      title: Text(
        title,
        style: AppStyles.title1SemiBold,
      ),
      centerTitle: false,
      backgroundColor: backgroundColor,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
