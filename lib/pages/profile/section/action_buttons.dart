import 'package:flutter/material.dart';

import '../../../resources/styles_app.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback? onLogout; // ✅ FIXED: Changed to nullable

  const ActionButtons({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context,
          Icons.settings_outlined,
          'Settings',
          const Color(0xFF4A90E2),
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settings coming soon!')),
            );
          },
        ),
        _buildActionButton(
          context,
          Icons.share_outlined,
          'Share',
          const Color(0xFF4A90E2),
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Share coming soon!')),
            );
          },
        ),
        _buildActionButton(
          context,
          Icons.logout,
          'Logout',
          Colors.red.shade400,
          onLogout, // ✅ Can be null now
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback? onTap, // ✅ FIXED: Changed to nullable
  ) {
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0, // ✅ Visual feedback when disabled
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppStyles.label3SemiBold.copyWith(
                color: const Color(0xFF1A2B3C),
              ),
            )
          ],
        ),
      ),
    );
  }
}