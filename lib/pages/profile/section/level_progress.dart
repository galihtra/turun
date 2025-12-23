import 'package:flutter/material.dart';

import '../../../resources/styles_app.dart';

class LevelProgress extends StatelessWidget {
  const LevelProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2B3C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shield,
                    color: Color(0xFFFFD700), size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                'Gold',
                style: AppStyles.title3SemiBold.copyWith(
                  color: const Color(0xFF1A2B3C),
                ),
              ),
              const Spacer(),
              Text(
                '2500 Points',
                style: AppStyles.label2Medium.copyWith(
                  color: const Color(0xFF8896A6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              value: 0.6,
              minHeight: 8,
              backgroundColor: Color(0xFFE8EDF2),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLevelBadge('Silver', Icons.shield, true, false),
              _buildLevelConnector(true),
              _buildLevelBadge('Gold', Icons.shield, true, true),
              _buildLevelConnector(false),
              _buildLevelBadge('Diamond', Icons.shield, false, false),
              _buildLevelConnector(false),
              _buildLevelBadge('Platinum', Icons.shield, false, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge(
      String label, IconData icon, bool achieved, bool current) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: achieved ? const Color(0xFF1A2B3C) : const Color(0xFFE8EDF2),
            shape: BoxShape.circle,
            border: current
                ? Border.all(color: const Color(0xFF4A90E2), width: 3)
                : null,
          ),
          child: Icon(
            icon,
            size: 20,
            color: achieved ? const Color(0xFFFFD700) : const Color(0xFFB0BEC5),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: achieved ? const Color(0xFF1A2B3C) : const Color(0xFFB0BEC5),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelConnector(bool achieved) {
    return Container(
      width: 20,
      height: 2,
      color: achieved ? const Color(0xFF4A90E2) : const Color(0xFFE8EDF2),
      margin: const EdgeInsets.only(bottom: 24),
    );
  }
}