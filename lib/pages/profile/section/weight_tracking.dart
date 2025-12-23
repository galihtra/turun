import 'package:flutter/material.dart';

import '../../../resources/styles_app.dart';

class WeightTracking extends StatelessWidget {
  const WeightTracking({super.key});

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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add weight coming soon!')),
                  );
                },
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
                '0.0',
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
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Last 30 days',
            style: AppStyles.label3Regular.copyWith(
              color: const Color(0xFFB0BEC5),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 100,
            child: CustomPaint(
              painter: WeightChartPainter(),
              size: const Size(double.infinity, 100),
            ),
          ),
        ],
      ),
    );
  }
}

class WeightChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4A90E2)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final points = [
      0.6,
      0.65,
      0.55,
      0.7,
      0.6,
      0.5,
      0.55,
      0.45,
      0.4,
      0.35,
      0.3,
      0.2
    ];

    path.moveTo(0, size.height * points[0]);

    for (int i = 0; i < points.length; i++) {
      final x = (size.width / (points.length - 1)) * i;
      final y = size.height * points[i];

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (size.width / (points.length - 1)) * (i - 1);
        final prevY = size.height * points[i - 1];
        final cpX = (prevX + x) / 2;

        path.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}