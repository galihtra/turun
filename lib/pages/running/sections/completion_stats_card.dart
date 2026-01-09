import 'package:flutter/material.dart';
import 'package:turun/data/model/running/run_session_model.dart';
import 'package:turun/resources/colors_app.dart';

import '../widgets/completion_stat_item.dart';

class CompletionStatsCard extends StatelessWidget {
  final RunSession session;

  const CompletionStatsCard({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          CompletionStatItem(
            icon: Icons.straighten_rounded,
            label: 'Distance',
            value: session.formattedDistance,
            color: AppColors.blueLogo,
          ),
          const Divider(height: 32),
          CompletionStatItem(
            icon: Icons.timer_rounded,
            label: 'Duration',
            value: session.formattedDuration,
            color: AppColors.cyan,
          ),
          const Divider(height: 32),
          CompletionStatItem(
            icon: Icons.speed_rounded,
            label: 'Average Pace',
            value: session.formattedPace,
            color: AppColors.green[500]!,
          ),
          const Divider(height: 32),
          CompletionStatItem(
            icon: Icons.directions_run_rounded,
            label: 'Average Speed',
            value: session.formattedSpeed,
            color: AppColors.orange[500]!,
          ),
          const Divider(height: 32),
          CompletionStatItem(
            icon: Icons.local_fire_department_rounded,
            label: 'Calories Burned',
            value: '${session.caloriesBurned} kcal',
            color: AppColors.red[500]!,
          ),
        ],
      ),
    );
  }
}
