import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/custom_transition.dart';
import '../../../data/providers/weight/weight_provider.dart';
import '../../../resources/styles_app.dart';
import '../pages/weight_tracking_screen.dart';
import 'add_weight_modal.dart';

/// Weight tracking card widget for the profile screen
class WeightTracking extends StatefulWidget {
  const WeightTracking({super.key});

  @override
  State<WeightTracking> createState() => _WeightTrackingState();
}

class _WeightTrackingState extends State<WeightTracking> {
  @override
  void initState() {
    super.initState();
    // Defer loading until after the first frame to ensure Provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeightData();
    });
  }

  Future<void> _loadWeightData() async {
    if (!mounted) return;
    final provider = Provider.of<WeightProvider>(context, listen: false);
    await provider.loadWeightHistory();
  }

  void _navigateToWeightTracking() {
    Navigator.push(
      context,
      SlidePageRoute(page: const WeightTrackingScreen()),
    );
  }

  Future<void> _addWeight() async {
    await AddWeightModal.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeightProvider>(
      builder: (context, provider, _) {
        final stats = provider.statistics;
        final chartPoints = provider.getChartDataPoints();

        return GestureDetector(
          onTap: _navigateToWeightTracking,
          child: Container(
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
                      'Weight',
                      style: AppStyles.title3SemiBold.copyWith(
                        color: const Color(0xFF1A2B3C),
                      ),
                    ),
                    TextButton(
                      onPressed: _addWeight,
                      style: TextButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'ADD',
                        style: AppStyles.label2SemiBold.copyWith(
                          color: const Color(0xFF4A90E2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      stats.latestWeight?.toStringAsFixed(1) ?? '0.0',
                      style: AppStyles.heading2SemiBold.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A2B3C),
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        'kg',
                        style: AppStyles.title3Medium.copyWith(
                          color: const Color(0xFF8896A6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (stats.weightChange != null)
                      _buildChangeIndicator(stats.weightChange!),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  provider.hasData 
                      ? '${stats.totalEntries} entries · Last 30 days'
                      : 'Tap to start tracking',
                  style: AppStyles.label3Regular.copyWith(
                    color: const Color(0xFFB0BEC5),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 100,
                  child: provider.isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : chartPoints.isEmpty
                          ? _buildEmptyChart()
                          : CustomPaint(
                              painter: WeightChartPainter(dataPoints: chartPoints),
                              size: const Size(double.infinity, 100),
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChangeIndicator(double change) {
    final isPositive = change > 0;
    final color = isPositive ? Colors.red.shade400 : Colors.green.shade500;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 2),
          Text(
            change.abs().toStringAsFixed(1),
            style: AppStyles.label3SemiBold.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart_rounded,
            color: Colors.grey.shade300,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Add weight to see chart',
            style: AppStyles.label3Regular.copyWith(
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the weight chart with smooth curves
class WeightChartPainter extends CustomPainter {
  final List<double> dataPoints;

  WeightChartPainter({required this.dataPoints});

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFF4A90E2)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF4A90E2).withValues(alpha: 0.2),
          const Color(0xFF4A90E2).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    // Calculate points
    final points = <Offset>[];
    for (int i = 0; i < dataPoints.length; i++) {
      final x = dataPoints.length > 1 
          ? (size.width / (dataPoints.length - 1)) * i 
          : size.width / 2;
      final y = size.height * dataPoints[i] * 0.8 + size.height * 0.1;
      points.add(Offset(x, y));
    }

    if (points.length == 1) {
      // Single point - draw a dot
      canvas.drawCircle(points.first, 4, paint..style = PaintingStyle.fill);
      return;
    }

    // Draw smooth curve
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

    // Draw fill gradient
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WeightChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints;
  }
}