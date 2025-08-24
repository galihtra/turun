import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:turun/resources/assets_app.dart';
import 'package:turun/resources/colors_app.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final VoidCallback onCenterTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
    required this.onCenterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // panel dasar dengan radius di atas
        Container(
          height: 88,
          decoration: const BoxDecoration(
            color: AppColors.deepBlue,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(
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
          ),
        ),

        // tombol bulat besar di tengah (mengambang)
        Positioned(
          top: -22, // membuatnya “menonjol” ke atas
          child: GestureDetector(
            onTap: onCenterTap,
            child: _CenterActionButton(),
          ),
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
            // jika svg mono-color, bisa aktifkan colorFilter:
            // colorFilter: const ColorFilter.mode(
            //   isActive ? AppColors.iconActive : AppColors.iconInactive,
            //   BlendMode.srcIn,
            // ),
            width: 28,
            height: 28,
          ),
        ),
      ),
    );
  }
}

class _CenterActionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.blueGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.black.withOpacity(0.15),
          width: 10, // ring luar seperti di mockup
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.directions_run_rounded, // ikon lari (bisa diganti asset)
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }
}
