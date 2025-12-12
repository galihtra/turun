import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Helper class untuk membuat custom markers yang lebih gamifikasi
class CustomMarkerHelper {
  /// Create START checkpoint marker (green flag with pulse effect)
  static Future<BitmapDescriptor> createStartMarker() async {
    return await _createMarkerFromCanvas(
      size: const Size(80, 100),
      painter: (canvas, size) {
        // Pulse effect (outer glow)
        final outerPaint = Paint()
          ..color = Colors.green.withOpacity(0.2)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(size.width / 2, 40),
          40,
          outerPaint,
        );

        // Middle glow
        final middlePaint = Paint()
          ..color = Colors.green.withOpacity(0.4)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(size.width / 2, 40),
          30,
          middlePaint,
        );

        // Main coin circle with gradient
        final gradient = ui.Gradient.linear(
          Offset(size.width / 2, 15),
          Offset(size.width / 2, 65),
          [Color(0xFF00E676), Color(0xFF00C853)],
        );
        final coinPaint = Paint()
          ..shader = gradient
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(size.width / 2, 40), 25, coinPaint);

        // Coin border (gold ring)
        final borderPaint = Paint()
          ..color = Color(0xFFFFD700)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        canvas.drawCircle(Offset(size.width / 2, 40), 25, borderPaint);

        // Inner ring
        final innerRingPaint = Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawCircle(Offset(size.width / 2, 40), 20, innerRingPaint);

        // Draw flag icon in center
        final iconPainter = TextPainter(
          text: TextSpan(
            text: String.fromCharCode(Icons.flag_rounded.codePoint),
            style: TextStyle(
              fontFamily: Icons.flag_rounded.fontFamily,
              fontSize: 28,
              color: Colors.white,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        iconPainter.layout();
        iconPainter.paint(canvas, Offset(26, 26));

        // Draw "START" text below coin
        final textPainter = TextPainter(
          text: TextSpan(
            text: 'START',
            style: TextStyle(
              color: Color(0xFF00C853),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(23, 72));
      },
    );
  }

  /// Create checkpoint coin marker (Subway Surfers style)
  static Future<BitmapDescriptor> createCheckpointCoin(int number) async {
    return await _createMarkerFromCanvas(
      size: const Size(60, 80),
      painter: (canvas, size) {
        // Shadow/glow effect
        final glowPaint = Paint()
          ..color = Color(0xFFFFD700).withOpacity(0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(size.width / 2, 30),
          28,
          glowPaint,
        );

        // Main coin circle with gold gradient
        final gradient = ui.Gradient.linear(
          Offset(size.width / 2, 10),
          Offset(size.width / 2, 50),
          [Color(0xFFFFD700), Color(0xFFFFA000)],
        );
        final coinPaint = Paint()
          ..shader = gradient
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(size.width / 2, 30), 22, coinPaint);

        // Coin outer border (dark gold)
        final outerBorderPaint = Paint()
          ..color = Color(0xFFB8860B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawCircle(Offset(size.width / 2, 30), 22, outerBorderPaint);

        // Inner ring (light shine effect)
        final innerRingPaint = Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawCircle(Offset(size.width / 2, 30), 18, innerRingPaint);

        // Center highlight (top-left shine)
        final highlightPaint = Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(size.width / 2 - 6, 24), 6, highlightPaint);

        // Draw checkpoint number
        final numberPainter = TextPainter(
          text: TextSpan(
            text: '$number',
            style: TextStyle(
              color: Color(0xFF8B4513), // Dark brown
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        numberPainter.layout();
        final numberX = (size.width / 2) - (numberPainter.width / 2);
        numberPainter.paint(canvas, Offset(numberX, 22));
      },
    );
  }

  /// Create FINISH marker (red trophy)
  static Future<BitmapDescriptor> createFinishMarker() async {
    return await _createMarkerFromCanvas(
      size: const Size(80, 100),
      painter: (canvas, size) {
        // Glow effect
        final glowPaint = Paint()
          ..color = Colors.red.withOpacity(0.2)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(size.width / 2, 35),
          35,
          glowPaint,
        );

        // Trophy container with gradient
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(10, 10, 60, 80),
          Radius.circular(30),
        );
        final gradient = ui.Gradient.linear(
          Offset(40, 10),
          Offset(40, 90),
          [Color(0xFFFF5252), Color(0xFFD32F2F)],
        );
        final containerPaint = Paint()
          ..shader = gradient
          ..style = PaintingStyle.fill;
        canvas.drawRRect(rect, containerPaint);

        // Shadow
        final shadowPaint = Paint()
          ..color = Colors.red.withOpacity(0.3)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawRRect(rect, shadowPaint);

        // Draw trophy icon (gold)
        final trophyPainter = TextPainter(
          text: TextSpan(
            text: String.fromCharCode(Icons.emoji_events_rounded.codePoint),
            style: TextStyle(
              fontFamily: Icons.emoji_events_rounded.fontFamily,
              fontSize: 32,
              color: Color(0xFFFFD700), // Gold
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        trophyPainter.layout();
        trophyPainter.paint(canvas, Offset(24, 25));

        // Draw "FINISH" text
        final textPainter = TextPainter(
          text: TextSpan(
            text: 'FINISH',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(23, 63));
      },
    );
  }

  /// Convert canvas drawing to BitmapDescriptor
  static Future<BitmapDescriptor> _createMarkerFromCanvas({
    required Size size,
    required void Function(Canvas canvas, Size size) painter,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Paint transparent background
    final bgPaint = Paint()..color = Colors.transparent;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      bgPaint,
    );

    // Call custom painter
    painter(canvas, size);

    // Convert to image
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(buffer);
  }
}
