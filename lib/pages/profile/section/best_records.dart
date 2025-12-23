import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../resources/styles_app.dart';

class BestRecords extends StatelessWidget {
  const BestRecords({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Best Records',
            style: AppStyles.title2SemiBold.copyWith(
              color: const Color(0xFF1A2B3C),
            ),
          ),
        ),
        _buildRecordCard(context, Icons.polyline, 'LONGEST DISTANCE', '90',
            'km', const Color(0xFF4A90E2)),
        const SizedBox(height: 12),
        _buildRecordCard(context, Icons.speed, 'BEST PACE', '0.0', 'min/km',
            const Color(0xFF4A90E2)),
        const SizedBox(height: 12),
        _buildRecordCard(context, Icons.timer_outlined, 'LONGEST DURATION',
            '01:30:15', null, const Color(0xFF4A90E2)),
      ],
    );
  }

  Widget _buildRecordCard(BuildContext context, IconData icon, String title,
      String value, String? unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.label2SemiBold.copyWith(
                    color: const Color(0xFF4A90E2),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: AppStyles.title1SemiBold.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A2B3C),
                        height: 1,
                      ),
                    ),
                    if (unit != null) ...[
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          unit,
                          style: AppStyles.label3Medium.copyWith(
                            color: const Color(0xFF8896A6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}