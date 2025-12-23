import 'package:flutter/material.dart';

import '../../../resources/styles_app.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(context, Icons.directions_run, 'Total Runs', '10', null,
            const Color(0xFF4A90E2)),
        _buildStatCard(context, Icons.crop_square, 'Total Area', '450', 'km²',
            const Color(0xFF4A90E2)),
        _buildStatCard(context, Icons.timeline, 'Total Distance', '24', 'km',
            const Color(0xFF4A90E2)),
        _buildStatCard(context, Icons.access_time, 'Total Duration', '01:30:15',
            null, const Color(0xFF4A90E2)),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String title,
    String value, [
    String? unit,
    Color color = const Color(0xFF4A90E2),
  ]) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppStyles.label3Medium.copyWith(
                    color: const Color(0xFF8896A6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
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
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: AppStyles.label3Medium.copyWith(
                      color: const Color(0xFF8896A6),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}