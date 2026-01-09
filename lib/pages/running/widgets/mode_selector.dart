import 'package:flutter/material.dart';
import 'package:turun/data/model/running/run_mode.dart';
import 'package:turun/resources/values_app.dart';

class ModeSelector extends StatelessWidget {
  final RunMode currentMode;
  final Function(RunMode) onModeChanged;

  const ModeSelector({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimens.h45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.r30),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildModeButton(
            label: "Territory",
            icon: Icons.flag,
            isSelected: currentMode == RunMode.territory,
            onTap: () => onModeChanged(RunMode.territory),
          ),
          _buildModeButton(
            label: "Landmark",
            icon: Icons.explore,
            isSelected: currentMode == RunMode.landmark,
            onTap: () => onModeChanged(RunMode.landmark),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                  )
                : null,
            borderRadius: BorderRadius.circular(AppDimens.r30),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.black54,
                  size: AppSizes.s18,
                ),
                AppGaps.kGap5,
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
