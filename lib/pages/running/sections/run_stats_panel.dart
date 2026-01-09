import 'package:flutter/material.dart';
import 'package:turun/data/providers/running/running_provider.dart';
import 'package:turun/data/providers/landmark/landmark_provider.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:gap/gap.dart';
import '../../../app/extensions.dart';
import '../widgets/compact_button.dart';
import '../widgets/compact_metric.dart';
import '../widgets/control_button.dart';
import '../widgets/detail_metric_card.dart';

class RunStatsPanel extends StatelessWidget {
  final double sheetSize;
  final RunningProvider runProvider;
  final LandmarkProvider landmarkProvider;
  final bool isLandmarkMode;
  final Color userColor;
  final int coinsCollected;
  final int totalCoins;
  final VoidCallback onPauseResume;
  final VoidCallback onFinish;
  final VoidCallback onCancel;

  const RunStatsPanel({
    super.key,
    required this.sheetSize,
    required this.runProvider,
    required this.landmarkProvider,
    required this.isLandmarkMode,
    required this.userColor,
    required this.coinsCollected,
    required this.totalCoins,
    required this.onPauseResume,
    required this.onFinish,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isExpanded = sheetSize > 0.4;
    final allCoinsCollected = coinsCollected >= totalCoins;

    // Get stats from appropriate provider
    final duration = isLandmarkMode
        ? landmarkProvider.elapsedSeconds
        : runProvider.runDuration;
    final distance = isLandmarkMode
        ? landmarkProvider.totalDistance
        : runProvider.runDistance;
    final pace = isLandmarkMode
        ? landmarkProvider.currentPace
        : runProvider.currentPace;
    final speed = isLandmarkMode ? 0.0 : runProvider.currentSpeed;

    if (!isExpanded) {
      // COLLAPSED: Compact horizontal stats
      return Column(
        children: [
          // Route progress bar (only for territory mode)
          if (!isLandmarkMode) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Progress',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (allCoinsCollected) ...[
                            const Gap(8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '✓ Complete!',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '$coinsCollected / $totalCoins coins',
                        style: TextStyle(
                          fontSize: 10,
                          color: allCoinsCollected ? Colors.green : AppColors.blueLogo,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Gap(4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: runProvider.routeProgress / 100,
                      minHeight: 6,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        allCoinsCollected ? Colors.green : userColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(12),
          ],

          // Compact metrics row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CompactMetric(
                label: 'Duration',
                value: FormattingRun.formatDuration(duration),
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              CompactMetric(
                label: 'Distance',
                value: FormattingRun.formatDistance(distance),
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              CompactMetric(
                label: 'Pace',
                value: FormattingRun.formatPace(pace),
              ),
            ],
          ),
          const Gap(16),
          // Control buttons (compact)
          _buildCompactControls(),
          const Gap(12),
        ],
      );
    } else {
      // EXPANDED: Full detailed stats
      return Column(
        children: [
          // Route progress (with coin counter) - only for territory mode
          if (!isLandmarkMode)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: allCoinsCollected
                    ? Colors.green.shade50
                    : AppColors.blueLogo.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: allCoinsCollected
                      ? Colors.green.withValues(alpha: 0.3)
                      : AppColors.blueLogo.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            allCoinsCollected
                                ? Icons.emoji_events_rounded
                                : Icons.monetization_on_rounded,
                            color: allCoinsCollected ? Colors.amber : AppColors.blueLogo,
                            size: 20,
                          ),
                          const Gap(8),
                          Text(
                            allCoinsCollected
                                ? 'All Coins Collected!'
                                : 'Coins Collected',
                            style: TextStyle(
                              fontSize: 12,
                              color: allCoinsCollected
                                  ? Colors.green.shade700
                                  : Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: allCoinsCollected ? Colors.green : AppColors.blueLogo,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$coinsCollected / $totalCoins',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: runProvider.routeProgress / 100,
                      minHeight: 10,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        allCoinsCollected ? Colors.green : userColor,
                      ),
                    ),
                  ),
                  if (allCoinsCollected) ...[
                    const Gap(10),
                    Text(
                      '🏁 Return to START to finish!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // Big duration display
          Text(
            FormattingRun.formatDuration(duration),
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: userColor,
              letterSpacing: -2,
            ),
          ),
          Text(
            'Duration',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(24),

          // Detailed metrics grid
          Row(
            children: [
              Expanded(
                child: DetailedMetricCard(
                  icon: Icons.straighten_rounded,
                  label: 'Distance',
                  value: FormattingRun.formatDistance(distance),
                ),
              ),
              const Gap(12),
              Expanded(
                child: DetailedMetricCard(
                  icon: Icons.speed_rounded,
                  label: 'Pace',
                  value: '${FormattingRun.formatPace(pace)}/km',
                ),
              ),
            ],
          ),
          const Gap(12),
          DetailedMetricCard(
            icon: Icons.directions_run_rounded,
            label: 'Current Speed',
            value: '${(speed * 3.6).toStringAsFixed(1)} km/h',
            isWide: true,
          ),
          const Gap(24),

          // Control buttons (expanded)
          _buildExpandedControls(),
          const Gap(20),
        ],
      );
    }
  }

  Widget _buildCompactControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CompactButton(
          icon: runProvider.activeRunSession?.status.name == 'active'
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          color: AppColors.yellow[500]!,
          onTap: onPauseResume,
        ),
        CompactButton(
          icon: Icons.check_circle_rounded,
          color: AppColors.green[500]!,
          onTap: onFinish,
        ),
        CompactButton(
          icon: Icons.close_rounded,
          color: AppColors.red[500]!,
          onTap: onCancel,
        ),
      ],
    );
  }

  Widget _buildExpandedControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ControlButton(
          icon: runProvider.activeRunSession?.status.name == 'active'
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          label: runProvider.activeRunSession?.status.name == 'active'
              ? 'Pause'
              : 'Resume',
          color: AppColors.yellow[500]!,
          onTap: onPauseResume,
        ),
        ControlButton(
          icon: Icons.check_circle_rounded,
          label: 'Finish',
          color: AppColors.green[500]!,
          onTap: onFinish,
        ),
        ControlButton(
          icon: Icons.close_rounded,
          label: 'Cancel',
          color: AppColors.red[500]!,
          onTap: onCancel,
        ),
      ],
    );
  }
}
