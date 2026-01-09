import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShareRoutePainter extends CustomPainter {
  final List<LatLng>? routePoints;
  final bool isLandmark;

  ShareRoutePainter({
    this.routePoints,
    this.isLandmark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (routePoints != null && routePoints!.isNotEmpty) {
      _drawRealRoute(canvas, size);
    } else {
      _drawDummyTerritoryOutline(canvas, size);
    }
  }

  void _drawRealRoute(Canvas canvas, Size size) {
    if (routePoints == null || routePoints!.isEmpty) return;

    // Calculate bounding box
    double minLat = routePoints!.first.latitude;
    double maxLat = routePoints!.first.latitude;
    double minLng = routePoints!.first.longitude;
    double maxLng = routePoints!.first.longitude;

    for (var point in routePoints!) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final latRange = maxLat - minLat;
    final lngRange = maxLng - minLng;

    const padding = 10.0;
    final drawWidth = size.width - (padding * 2);
    final drawHeight = size.height - (padding * 2);

    // Convert GPS to canvas coordinates
    Offset latLngToOffset(LatLng point) {
      final x = padding + ((point.longitude - minLng) / lngRange) * drawWidth;
      final y = padding + ((maxLat - point.latitude) / latRange) * drawHeight;
      return Offset(x, y);
    }

    final routeColor = isLandmark ? const Color(0xFF00E676) : Colors.red;

    // Draw route path
    final routePaint = Paint()
      ..color = routeColor.withValues(alpha: 0.6)
      ..strokeWidth = isLandmark ? 3.0 : 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final firstPoint = latLngToOffset(routePoints!.first);
    path.moveTo(firstPoint.dx, firstPoint.dy);

    for (int i = 1; i < routePoints!.length; i++) {
      final point = latLngToOffset(routePoints![i]);
      path.lineTo(point.dx, point.dy);
    }

    if (!isLandmark) {
      path.close();
      final fillPaint = Paint()
        ..color = routeColor.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);
    }

    canvas.drawPath(path, routePaint);

    // Draw markers for landmarks
    if (isLandmark && routePoints!.length >= 2) {
      _drawLandmarkMarkers(canvas, firstPoint, latLngToOffset(routePoints!.last));
    }
  }

  void _drawLandmarkMarkers(Canvas canvas, Offset startPoint, Offset endPoint) {
    final startMarkerPaint = Paint()
      ..color = const Color(0xFF00E676)
      ..style = PaintingStyle.fill;

    final endMarkerPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Start point (green)
    canvas.drawCircle(startPoint, 4, startMarkerPaint);
    canvas.drawCircle(startPoint, 4, borderPaint);

    // End point (red)
    canvas.drawCircle(endPoint, 4, endMarkerPaint);
    canvas.drawCircle(endPoint, 4, borderPaint);
  }

  void _drawDummyTerritoryOutline(Canvas canvas, Size size) {
    final boundaryPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // Organic territory shape
    path.moveTo(size.width * 0.08, size.height * 0.35);
    path.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.12,
      size.width * 0.7,
      size.height * 0.18,
    );
    path.quadraticBezierTo(
      size.width * 0.92,
      size.height * 0.4,
      size.width * 0.88,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.55,
      size.height * 0.88,
      size.width * 0.15,
      size.height * 0.78,
    );
    path.quadraticBezierTo(
      size.width * 0.05,
      size.height * 0.55,
      size.width * 0.08,
      size.height * 0.35,
    );
    path.close();

    // Fill
    final fillPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Outline
    canvas.drawPath(path, boundaryPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is ShareRoutePainter) {
      return oldDelegate.routePoints != routePoints ||
          oldDelegate.isLandmark != isLandmark;
    }
    return false;
  }
}
