import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../data/providers/weight/weight_provider.dart';
import '../../../data/model/weight/weight_entry_model.dart';
import '../../../resources/styles_app.dart';
import '../../../resources/values_app.dart';
import '../section/add_weight_modal.dart';

/// Full screen page for viewing and managing weight history
class WeightTrackingScreen extends StatefulWidget {
  const WeightTrackingScreen({super.key});

  @override
  State<WeightTrackingScreen> createState() => _WeightTrackingScreenState();
}

class _WeightTrackingScreenState extends State<WeightTrackingScreen> {
  @override
  void initState() {
    super.initState();
    // Defer loading until after the first frame to ensure Provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final provider = Provider.of<WeightProvider>(context, listen: false);
    await provider.loadWeightHistory();
  }

  Future<void> _addWeight() async {
    final result = await AddWeightModal.show(context);
    if (result == true) {
      // Data will be reloaded by the modal
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF1A2B3C)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Weight Tracking',
          style: AppStyles.title2SemiBold.copyWith(
            color: const Color(0xFF1A2B3C),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Color(0xFF4A90E2)),
            onPressed: _addWeight,
          ),
        ],
      ),
      body: Consumer<WeightProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && !provider.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats card
                  _buildStatsCard(provider),
                  AppGaps.kGap24,

                  // Chart card
                  _buildChartCard(provider),
                  AppGaps.kGap24,

                  // History list
                  _buildHistorySection(provider),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addWeight,
        backgroundColor: const Color(0xFF4A90E2),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Add Weight',
          style: AppStyles.body2SemiBold.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStatsCard(WeightProvider provider) {
    final stats = provider.statistics;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF6B5DD3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Weight',
            style: AppStyles.body2Medium.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                stats.latestWeight?.toStringAsFixed(1) ?? '--',
                style: AppStyles.heading1SemiBold.copyWith(
                  color: Colors.white,
                  fontSize: 48,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'kg',
                  style: AppStyles.title3Medium.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
              const Spacer(),
              if (stats.weightChange != null)
                _buildChangeIndicator(stats.weightChange!),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatItem('Lowest', stats.minWeight, Icons.arrow_downward_rounded),
              const SizedBox(width: 16),
              _buildStatItem('Highest', stats.maxWeight, Icons.arrow_upward_rounded),
              const SizedBox(width: 16),
              _buildStatItem('Average', stats.averageWeight, Icons.analytics_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChangeIndicator(double change) {
    final isPositive = change > 0;
    final isNeutral = change == 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isNeutral
                ? Icons.remove
                : (isPositive ? Icons.arrow_upward : Icons.arrow_downward),
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${isPositive ? '+' : ''}${change.toStringAsFixed(1)} kg',
            style: AppStyles.label2SemiBold.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, double? value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 18),
            const SizedBox(height: 8),
            Text(
              value?.toStringAsFixed(1) ?? '--',
              style: AppStyles.title3SemiBold.copyWith(
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: AppStyles.label3Regular.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(WeightProvider provider) {
    final chartPoints = provider.getChartDataPoints();

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress Chart',
                style: AppStyles.title3SemiBold.copyWith(
                  color: const Color(0xFF1A2B3C),
                ),
              ),
              Text(
                'Last 30 days',
                style: AppStyles.label3Regular.copyWith(
                  color: const Color(0xFFB0BEC5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: chartPoints.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.show_chart_rounded,
                          color: Colors.grey.shade300,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No data yet',
                          style: AppStyles.body2Regular.copyWith(
                            color: Colors.grey.shade400,
                          ),
                        ),
                        Text(
                          'Add your first weight entry',
                          style: AppStyles.label3Regular.copyWith(
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  )
                : CustomPaint(
                    painter: WeightChartPainter(dataPoints: chartPoints),
                    size: const Size(double.infinity, 150),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(WeightProvider provider) {
    final history = provider.weightHistory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'History',
              style: AppStyles.title3SemiBold.copyWith(
                color: const Color(0xFF1A2B3C),
              ),
            ),
            Text(
              '${history.length} entries',
              style: AppStyles.label3Regular.copyWith(
                color: const Color(0xFFB0BEC5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (history.isEmpty)
          _buildEmptyHistory()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildHistoryItem(history[index], provider),
          ),
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      padding: const EdgeInsets.all(32),
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
          Icon(
            Icons.monitor_weight_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No weight entries yet',
            style: AppStyles.body1SemiBold.copyWith(
              color: const Color(0xFF1A2B3C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your weight by adding your first entry',
            style: AppStyles.body2Regular.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(WeightEntryModel entry, WeightProvider provider) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Entry'),
            content: const Text('Are you sure you want to delete this weight entry?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => provider.deleteWeight(entry.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.monitor_weight_outlined,
                color: Color(0xFF4A90E2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.weight.toStringAsFixed(1)} kg',
                    style: AppStyles.title3SemiBold.copyWith(
                      color: const Color(0xFF1A2B3C),
                    ),
                  ),
                  Text(
                    _formatDate(entry.recordedAt),
                    style: AppStyles.label3Regular.copyWith(
                      color: const Color(0xFF8896A6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today, ${DateFormat('HH:mm').format(date)}';
    } else if (dateOnly == yesterday) {
      return 'Yesterday, ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('d MMM yyyy, HH:mm').format(date);
    }
  }
}

/// Custom painter for the weight chart with smooth curves
class WeightChartPainter extends CustomPainter {
  final List<double> dataPoints;

  WeightChartPainter({required this.dataPoints});

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final linePaint = Paint()
      ..color = const Color(0xFF4A90E2)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF4A90E2).withValues(alpha: 0.3),
          const Color(0xFF4A90E2).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final dotPaint = Paint()
      ..color = const Color(0xFF4A90E2)
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    // Calculate points
    final points = <Offset>[];
    for (int i = 0; i < dataPoints.length; i++) {
      final x = (size.width / (dataPoints.length - 1)) * i;
      final y = size.height * dataPoints[i] * 0.8 + size.height * 0.1;
      points.add(Offset(x, y));
    }

    // Draw smooth curve
    if (points.isNotEmpty) {
      fillPath.moveTo(0, size.height);
      fillPath.lineTo(points.first.dx, points.first.dy);

      path.moveTo(points.first.dx, points.first.dy);

      for (int i = 0; i < points.length - 1; i++) {
        final current = points[i];
        final next = points[i + 1];
        final cpX = (current.dx + next.dx) / 2;

        path.cubicTo(cpX, current.dy, cpX, next.dy, next.dx, next.dy);
        fillPath.cubicTo(cpX, current.dy, cpX, next.dy, next.dx, next.dy);
      }

      fillPath.lineTo(points.last.dx, size.height);
      fillPath.close();

      // Draw fill
      canvas.drawPath(fillPath, fillPaint);

      // Draw line
      canvas.drawPath(path, linePaint);

      // Draw dots
      for (int i = 0; i < points.length; i++) {
        final point = points[i];
        canvas.drawCircle(point, 6, dotBorderPaint);
        canvas.drawCircle(point, 4, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant WeightChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints;
  }
}
