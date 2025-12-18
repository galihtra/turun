import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:turun/resources/assets_app.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/values_app.dart';

import '../../resources/styles_app.dart';

class RunShareScreen extends StatefulWidget {
  final String distance; // e.g., "21.51 km"
  final String pace; // e.g., "6:01 /km"
  final String duration; // e.g., "2j 9m"
  final String? avgSpeed; // e.g., "10.5 km/h"
  final String? maxSpeed; // e.g., "15.2 km/h"
  final String? calories; // e.g., "1291 cal"
  final String? mapImagePath; // Path to route map image
  final bool territoryConquered;
  final String? territoryName;
  final int? totalTerritories; // Total territories owned by user
  final String? userName;
  final String? userLevel; // e.g., "Level 12" or "Marathon Runner"

  const RunShareScreen({
    super.key,
    required this.distance,
    required this.pace,
    required this.duration,
    this.avgSpeed,
    this.maxSpeed,
    this.calories,
    this.mapImagePath,
    this.territoryConquered = false,
    this.territoryName,
    this.totalTerritories,
    this.userName,
    this.userLevel,
  });

  @override
  State<RunShareScreen> createState() => _RunShareScreenState();
}

class _RunShareScreenState extends State<RunShareScreen> {
  final GlobalKey _cardKey = GlobalKey();
  File? _backgroundImage;
  final ImagePicker _picker = ImagePicker();
  bool _isGenerating = false;

  // Dummy data for testing
  static const String dummyDistance = "21.51 km";
  static const String dummyPace = "6:01";
  static const String dummyDuration = "2j 9m";

  @override
  Widget build(BuildContext context) {
    final distance =
        widget.distance.isNotEmpty ? widget.distance : dummyDistance;
    final pace = widget.pace.isNotEmpty ? widget.pace : dummyPace;
    final duration =
        widget.duration.isNotEmpty ? widget.duration : dummyDuration;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Share Run'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _isGenerating ? null : _shareImage,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: RepaintBoundary(
                  key: _cardKey,
                  child: _buildShareCard(distance, pace, duration),
                ),
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildShareCard(
    String distance,
    String pace,
    String duration,
  ) {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[900],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image or default gradient
              if (_backgroundImage != null)
                Image.file(
                  _backgroundImage!,
                  fit: BoxFit.cover,
                )
              else
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1a1a2e),
                        const Color(0xFF16213e),
                        Colors.grey[900]!,
                      ],
                    ),
                  ),
                ),

              // Animated gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),

              // Content
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppGaps.kGap20,
                      if (widget.territoryConquered) ...[
                        _buildConquestBanner(),
                        AppGaps.kGap20,
                      ],
                      _buildMainAchievementCard(distance, pace, duration),
                      AppGaps.kGap20,
                      _buildHeader(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'TuRun',
          style: AppStyles.titleLogo,
        ),
      ],
    );
  }

  Widget _buildConquestBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.blueLogo.withValues(alpha: 0.2),
            AppColors.blueLogo.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.blueLogo, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueLogo.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.blueLogo,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.military_tech,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This territory is officially',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  maxLines: 2,
                  widget.territoryName ?? 'Unknown Territory',
                  style: const TextStyle(
                    color: AppColors.blueLogo,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainAchievementCard(
      String distance, String pace, String duration) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Main stat - Distance
          Column(
            children: [
              Text(
                'Sector Secured',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              // Territory route grid
              _buildSimpleRouteGrid(),
            ],
          ),

          const SizedBox(height: 20),

          // Divider
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),

          const SizedBox(height: 20),

          // Secondary main stats
          Row(
            children: [
              Expanded(
                child: _buildCompactStat(
                    'DISTANCE', distance, Icons.directions_walk),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildCompactStat('PACE', pace, Icons.speed),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildCompactStat('TIME', duration, Icons.timer),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.blueLogo, size: 20),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleRouteGrid() {
    return SizedBox(
      height: 100,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Territory polygon background
          SizedBox(
            width: double.infinity,
            height: 100,
            child: CustomPaint(
              painter: _SimpleRouteGridPainter(),
            ),
          ),
          // Icon in the center (territory claim)
          // Profile with flag badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Profile image
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                  image: const DecorationImage(
                    image: AssetImage(AppImages.exProfile),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Flag badge
              Positioned(
                right: -5,
                bottom: -5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.flag_rounded,
                    color: Colors.white,
                    size: 8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _pickBackgroundImage,
              icon: const Icon(Icons.image),
              label: const Text('Change Background'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (_backgroundImage != null) ...[
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: _removeBackgroundImage,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              child: const Icon(Icons.delete),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickBackgroundImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _backgroundImage = File(image.path);
      });
    }
  }

  void _removeBackgroundImage() {
    setState(() {
      _backgroundImage = null;
    });
  }

  Future<void> _shareImage() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Capture the widget as an image
      final RenderRepaintBoundary boundary =
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = await File(
              '${tempDir.path}/run_share_${DateTime.now().millisecondsSinceEpoch}.png')
          .create();
      await file.writeAsBytes(pngBytes);

      // Share the image
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out my run! 🏃‍♂️💪 #TuRun #Running',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e')),
        );
      }
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }
}

// Custom painter for territory polygon (blue theme, no background)
class _SimpleRouteGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw only territory boundary (blue)
    _drawTerritoryOutline(canvas, size);
  }

  void _drawTerritoryOutline(Canvas canvas, Size size) {
    final boundaryPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // Wider organic territory shape
    path.moveTo(size.width * 0.08, size.height * 0.35);

    // Top curve (wider spread)
    path.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.12,
      size.width * 0.7,
      size.height * 0.18,
    );

    // Right side curve (extended further right)
    path.quadraticBezierTo(
      size.width * 0.92,
      size.height * 0.4,
      size.width * 0.88,
      size.height * 0.7,
    );

    // Bottom curve (wider spread)
    path.quadraticBezierTo(
      size.width * 0.55,
      size.height * 0.88,
      size.width * 0.15,
      size.height * 0.78,
    );

    // Left side curve (back to start)
    path.quadraticBezierTo(
      size.width * 0.05,
      size.height * 0.55,
      size.width * 0.08,
      size.height * 0.35,
    );

    path.close();

    // Fill with transparent red
    final fillPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw outline
    canvas.drawPath(path, boundaryPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
