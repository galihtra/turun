import 'package:flutter/material.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';

class ImageSourceItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color? color;

  const ImageSourceItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? AppColors.deepBlue;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: itemColor.withValues(alpha: 0.15),
              child: Icon(icon, color: itemColor, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: AppStyles.body1SemiBold.copyWith(
                color: itemColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}