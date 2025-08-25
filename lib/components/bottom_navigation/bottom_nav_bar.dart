import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:turun/resources/assets_app.dart';
import 'package:turun/resources/values_app.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _NavItem(
          isActive: currentIndex == 0,
          activePath: AppIcons.homeActive,
          inactivePath: AppIcons.home,
          onTap: () => onChanged(0),
          semantic: 'Home',
        ),
        _NavItem(
          isActive: currentIndex == 1,
          activePath: AppIcons.territoryActive,
          inactivePath: AppIcons.territory,
          onTap: () => onChanged(1),
          semantic: 'Territory',
        ),
        const SizedBox(width: 72),
        _NavItem(
          isActive: currentIndex == 2,
          activePath: AppIcons.historyActive,
          inactivePath: AppIcons.history,
          onTap: () => onChanged(2),
          semantic: 'History',
        ),
        _NavItem(
          isActive: currentIndex == 3,
          activePath: AppIcons.profileActive,
          inactivePath: AppIcons.profile,
          onTap: () => onChanged(3),
          semantic: 'Profile',
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final bool isActive;
  final String activePath;
  final String inactivePath;
  final VoidCallback onTap;
  final String semantic;
  const _NavItem({
    required this.isActive,
    required this.activePath,
    required this.inactivePath,
    required this.onTap,
    required this.semantic,
  });
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semantic,
      button: true,
      selected: isActive,
      child: InkResponse(
        onTap: onTap,
        radius: 28,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          child: SvgPicture.asset(
            isActive ? activePath : inactivePath,
            width: AppDimens.w24,
            height: AppDimens.h24,
          ),
        ),
      ),
    );
  }
}
