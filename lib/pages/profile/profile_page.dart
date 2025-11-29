import 'package:flutter/material.dart';
import 'package:turun/resources/values_app.dart';

import '../../base_widgets/button/custom_badge_outline_button.dart';
import '../../resources/colors_app.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        children: [
          AppGaps.kGap24,
          Align(
            alignment: AlignmentGeometry.center,
            child: Column(
              children: [
                const Icon(
                  Icons.person_outline,
                  color: AppColors.deepBlue,
                  size: 50,
                ),
                AppGaps.kGap8,
                const CustomBadgeOutlineButton(buttonText: 'Edit Profile'),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.exit_to_app,
                    color: AppColors.blueDark,
                  ),
                  color: AppColors.black,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
