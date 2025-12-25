import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:turun/data/model/running/run_session_model.dart';
import 'package:turun/resources/colors_app.dart';

class ActivityDetailPage extends StatelessWidget {
  final RunSession activity;

  const ActivityDetailPage({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final isTerritory = activity.territoryConquered;
    final categoryColor = isTerritory
        ? const Color(0xFFFF6B6B)
        : const Color(0xFF10B981);
    final categoryGradient = isTerritory
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF10B981), Color(0xFF34D399)],
          );
    final categoryIcon = isTerritory ? Icons.flag : Icons.explore;
    final categoryLabel = isTerritory ? 'Territory' : 'Landmark';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, categoryGradient, categoryIcon, categoryLabel),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Stats Card
                    _buildMainStatsCard(categoryColor),

                    const Gap(20),

                    // Performance Metrics
                    _buildPerformanceMetrics(categoryColor),

                    const Gap(20),

                    // Route Map Placeholder
                    if (activity.routePoints.isNotEmpty)
                      _buildRouteMapCard(),

                    const Gap(20),

                    // Achievement Section
                    if (isTerritory)
                      _buildConquestBadge(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Gradient gradient, IconData icon, String label) {
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(gradient: gradient),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const Gap(8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        dateFormat.format(activity.startTime),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(12),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.white.withValues(alpha: 0.9), size: 16),
                const Gap(6),
                Text(
                  '${timeFormat.format(activity.startTime)} - ${activity.endTime != null ? timeFormat.format(activity.endTime!) : 'Ongoing'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStatsCard(Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMainStat(
                  icon: Icons.route,
                  label: 'Distance',
                  value: activity.formattedDistance,
                  color: const Color(0xFF2563EB),
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: Colors.grey[200],
              ),
              Expanded(
                child: _buildMainStat(
                  icon: Icons.access_time,
                  label: 'Duration',
                  value: activity.formattedDuration,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
          const Gap(20),
          Divider(color: Colors.grey[200], height: 1),
          const Gap(20),
          Row(
            children: [
              Expanded(
                child: _buildMainStat(
                  icon: Icons.speed,
                  label: 'Avg Pace',
                  value: activity.formattedPaceWithUnit,
                  color: const Color(0xFFFF6B6B),
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: Colors.grey[200],
              ),
              Expanded(
                child: _buildMainStat(
                  icon: Icons.local_fire_department,
                  label: 'Calories',
                  value: '${activity.caloriesBurned}',
                  color: const Color(0xFFFF8E53),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const Gap(8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPerformanceMetrics(Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Metrics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D1B2A),
          ),
        ),
        const Gap(16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildMetricRow(
                'Average Speed',
                activity.formattedSpeed,
                Icons.trending_up,
                const Color(0xFF10B981),
              ),
              const Gap(16),
              _buildMetricRow(
                'Max Speed',
                '${activity.maxSpeed.toStringAsFixed(1)} km/h',
                Icons.flash_on,
                const Color(0xFFFFD700),
              ),
              const Gap(16),
              _buildMetricRow(
                'Calories Burned',
                '${activity.caloriesBurned} kcal',
                Icons.local_fire_department,
                const Color(0xFFFF6B6B),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const Gap(16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteMapCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Route Map',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D1B2A),
          ),
        ),
        const Gap(16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 48,
                    color: AppColors.blueLogo.withValues(alpha: 0.5),
                  ),
                  const Gap(12),
                  Text(
                    'Route map with ${activity.routePoints.length} points',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Gap(4),
                  Text(
                    'Map view coming soon',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConquestBadge() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFD700),
            Color(0xFFFFA500),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 40,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Territory Conquered!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Gap(4),
                Text(
                  'You successfully conquered this territory',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
