import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:turun/resources/values_app.dart';
import '../../resources/styles_app.dart';
import 'sections/share_achievement_card.dart';
import 'sections/share_bottom_actions.dart';
import 'widgets/share_conquest_banner.dart';

class RunShareScreen extends StatefulWidget {
  final String distance;
  final String pace;
  final String duration;
  final String? avgSpeed;
  final String? maxSpeed;
  final String? calories;
  final List<LatLng>? routePoints;
  final bool territoryConquered;
  final String? territoryName;
  final int? totalTerritories;
  final String? userName;
  final String? userLevel;
  final bool isLandmark;
  final String? userAvatarUrl;

  const RunShareScreen({
    super.key,
    required this.distance,
    required this.pace,
    required this.duration,
    this.avgSpeed,
    this.maxSpeed,
    this.calories,
    this.routePoints,
    this.territoryConquered = false,
    this.territoryName,
    this.totalTerritories,
    this.userName,
    this.userLevel,
    this.isLandmark = false,
    this.userAvatarUrl,
  });

  @override
  State<RunShareScreen> createState() => _RunShareScreenState();
}

class _RunShareScreenState extends State<RunShareScreen> {
  final GlobalKey _cardKey = GlobalKey();
  final ImagePicker _picker = ImagePicker();
  File? _backgroundImage;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
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
                  child: _buildShareCard(),
                ),
              ),
            ),
          ),
          ShareBottomActions(
            backgroundImage: _backgroundImage,
            onPickImage: _pickBackgroundImage,
            onRemoveImage: _removeBackgroundImage,
          ),
        ],
      ),
    );
  }

  Widget _buildShareCard() {
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
              _buildBackground(),
              _buildGradientOverlay(),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    if (_backgroundImage != null) {
      return Image.file(_backgroundImage!, fit: BoxFit.cover);
    }

    return Container(
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
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.4),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppGaps.kGap20,
            if (widget.territoryConquered || widget.isLandmark) ...[
              ShareConquestBanner(
                isLandmark: widget.isLandmark,
                territoryName: widget.territoryName,
              ),
              AppGaps.kGap20,
            ],
            ShareAchievementCard(
              distance: widget.distance,
              pace: widget.pace,
              duration: widget.duration,
              routePoints: widget.routePoints,
              isLandmark: widget.isLandmark,
              userAvatarUrl: widget.userAvatarUrl,
            ),
            AppGaps.kGap20,
            _buildHeader(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('TuRun', style: AppStyles.titleLogo),
      ],
    );
  }

  Future<void> _pickBackgroundImage() async {
    final source = await ShareBottomActions.showImageSourceDialog(context);

    if (source != null) {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _backgroundImage = File(image.path));
      }
    }
  }

  void _removeBackgroundImage() {
    setState(() => _backgroundImage = null);
  }

  Future<void> _shareImage() async {
    setState(() => _isGenerating = true);

    try {
      final RenderRepaintBoundary boundary =
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/run_share_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await file.writeAsBytes(pngBytes);

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
      setState(() => _isGenerating = false);
    }
  }
}
