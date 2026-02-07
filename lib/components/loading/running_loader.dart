import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';
import 'dart:math' as math;

/// A gamified loading widget with running person animation
class RunningLoader extends StatefulWidget {
  final String? message;
  final double size;
  final bool showMessage;
  final bool showProgress;
  final double? progress; // 0.0 to 1.0 for determinate progress

  const RunningLoader({
    super.key,
    this.message,
    this.size = 80,
    this.showMessage = true,
    this.showProgress = false,
    this.progress,
  });

  @override
  State<RunningLoader> createState() => _RunningLoaderState();
}

class _RunningLoaderState extends State<RunningLoader>
    with TickerProviderStateMixin {
  late AnimationController _runController;
  late AnimationController _bounceController;
  late AnimationController _trackController;
  late Animation<double> _legAnimation;
  late Animation<double> _armAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _trackAnimation;

  final List<String> _loadingMessages = [
    "Warming up... 🏃",
    "Stretching muscles...",
    "Getting ready to run!",
    "Almost there...",
    "Loading your adventure...",
    "Preparing the track...",
    "Lacing up shoes... 👟",
    "On your mark...",
  ];

  late String _currentMessage;
  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentMessage = widget.message ?? _loadingMessages[0];

    // Running animation (legs and arms)
    _runController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..repeat(reverse: true);

    _legAnimation = Tween<double>(begin: -0.4, end: 0.4).animate(
      CurvedAnimation(parent: _runController, curve: Curves.easeInOut),
    );

    _armAnimation = Tween<double>(begin: 0.3, end: -0.3).animate(
      CurvedAnimation(parent: _runController, curve: Curves.easeInOut),
    );

    // Bounce animation (body up/down)
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: -4).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    // Track animation (moving ground)
    _trackController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    _trackAnimation = Tween<double>(begin: 0, end: 1).animate(_trackController);

    // Rotate messages
    if (widget.message == null) {
      _startMessageRotation();
    }
  }

  void _startMessageRotation() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _loadingMessages.length;
          _currentMessage = _loadingMessages[_messageIndex];
        });
        _startMessageRotation();
      }
    });
  }

  @override
  void dispose() {
    _runController.dispose();
    _bounceController.dispose();
    _trackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Running animation container
        SizedBox(
          width: widget.size * 1.5,
          height: widget.size * 1.2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Track/Ground with animation
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _trackAnimation,
                  builder: (context, child) => _buildTrack(),
                ),
              ),

              // Running person
              AnimatedBuilder(
                animation: Listenable.merge([_runController, _bounceController]),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _bounceAnimation.value),
                    child: _buildRunningPerson(),
                  );
                },
              ),

              // Dust particles
              Positioned(
                bottom: 8.h,
                left: widget.size * 0.2,
                child: AnimatedBuilder(
                  animation: _runController,
                  builder: (context, child) => _buildDustParticles(),
                ),
              ),
            ],
          ),
        ),

        if (widget.showProgress && widget.progress != null) ...[
          SizedBox(height: 16.h),
          _buildProgressBar(),
        ],

        if (widget.showMessage) ...[
          SizedBox(height: 16.h),
          _buildMessage(),
        ],
      ],
    );
  }

  Widget _buildRunningPerson() {
    final size = widget.size;
    
    return CustomPaint(
      size: Size(size, size),
      painter: RunningPersonPainter(
        legAngle: _legAnimation.value,
        armAngle: _armAnimation.value,
        primaryColor: AppColors.blue[500]!,
        secondaryColor: AppColors.blue[700]!,
        skinColor: const Color(0xFFFFDBB4),
      ),
    );
  }

  Widget _buildTrack() {
    return Container(
      height: 8.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        gradient: LinearGradient(
          colors: [
            AppColors.grey[200]!,
            AppColors.grey[300]!,
            AppColors.grey[200]!,
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.r),
        child: Stack(
          children: [
            // Animated track marks
            ...List.generate(5, (index) {
              final offset = ((_trackAnimation.value + index * 0.2) % 1.0);
              return Positioned(
                left: offset * widget.size * 1.5 - 10,
                top: 2.h,
                child: Container(
                  width: 20.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.grey[400]!.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDustParticles() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final delay = index * 0.3;
        final opacity = math.max(0.0, math.min(1.0, 
            (1 - _runController.value - delay).abs()));
        return Opacity(
          opacity: opacity * 0.6,
          child: Container(
            width: (4 + index * 2).w,
            height: (4 + index * 2).h,
            margin: EdgeInsets.only(right: 4.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.grey[400],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      width: 200.w,
      height: 8.h,
      decoration: BoxDecoration(
        color: AppColors.grey[200],
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.r),
        child: Stack(
          children: [
            // Progress fill
            FractionallySizedBox(
              widthFactor: widget.progress ?? 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.blue[400]!,
                      AppColors.blue[600]!,
                    ],
                  ),
                ),
              ),
            ),
            // Runner icon on progress
            if (widget.progress != null)
              Positioned(
                left: (widget.progress! * 200.w) - 8.w,
                top: -4.h,
                child: Icon(
                  Icons.directions_run_rounded,
                  size: 16.sp,
                  color: AppColors.blue[700],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        _currentMessage,
        key: ValueKey(_currentMessage),
        style: AppStyles.label2Medium.copyWith(
          color: AppColors.grey[600],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Custom painter for the running person
class RunningPersonPainter extends CustomPainter {
  final double legAngle;
  final double armAngle;
  final Color primaryColor;
  final Color secondaryColor;
  final Color skinColor;

  RunningPersonPainter({
    required this.legAngle,
    required this.armAngle,
    required this.primaryColor,
    required this.secondaryColor,
    required this.skinColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Paint styles
    final bodyPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final shortsPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    final skinPaint = Paint()
      ..color = skinColor
      ..style = PaintingStyle.fill;

    final shoePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Scale factor
    final scale = size.width / 60;

    // Draw legs
    canvas.save();
    canvas.translate(center.dx - 5 * scale, center.dy + 10 * scale);
    canvas.rotate(legAngle);
    // Back leg
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-3 * scale, 0, 6 * scale, 20 * scale),
        Radius.circular(3 * scale),
      ),
      skinPaint,
    );
    // Back shoe
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-4 * scale, 17 * scale, 10 * scale, 5 * scale),
        Radius.circular(2 * scale),
      ),
      shoePaint,
    );
    canvas.restore();

    canvas.save();
    canvas.translate(center.dx + 5 * scale, center.dy + 10 * scale);
    canvas.rotate(-legAngle);
    // Front leg
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-3 * scale, 0, 6 * scale, 20 * scale),
        Radius.circular(3 * scale),
      ),
      skinPaint,
    );
    // Front shoe
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-4 * scale, 17 * scale, 10 * scale, 5 * scale),
        Radius.circular(2 * scale),
      ),
      shoePaint,
    );
    canvas.restore();

    // Draw shorts
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + 8 * scale),
          width: 18 * scale,
          height: 10 * scale,
        ),
        Radius.circular(3 * scale),
      ),
      shortsPaint,
    );

    // Draw body (torso)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - 5 * scale),
          width: 16 * scale,
          height: 20 * scale,
        ),
        Radius.circular(5 * scale),
      ),
      bodyPaint,
    );

    // Draw arms
    canvas.save();
    canvas.translate(center.dx - 8 * scale, center.dy - 8 * scale);
    canvas.rotate(armAngle);
    // Left arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-2 * scale, 0, 4 * scale, 15 * scale),
        Radius.circular(2 * scale),
      ),
      skinPaint,
    );
    canvas.restore();

    canvas.save();
    canvas.translate(center.dx + 8 * scale, center.dy - 8 * scale);
    canvas.rotate(-armAngle);
    // Right arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-2 * scale, 0, 4 * scale, 15 * scale),
        Radius.circular(2 * scale),
      ),
      skinPaint,
    );
    canvas.restore();

    // Draw head
    canvas.drawCircle(
      Offset(center.dx, center.dy - 20 * scale),
      8 * scale,
      skinPaint,
    );

    // Draw hair
    final hairPaint = Paint()
      ..color = const Color(0xFF3D2314)
      ..style = PaintingStyle.fill;
    
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - 22 * scale),
        width: 16 * scale,
        height: 12 * scale,
      ),
      math.pi,
      math.pi,
      true,
      hairPaint,
    );

    // Draw headband
    final headbandPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - 22 * scale),
          width: 18 * scale,
          height: 3 * scale,
        ),
        Radius.circular(1.5 * scale),
      ),
      headbandPaint,
    );
  }

  @override
  bool shouldRepaint(RunningPersonPainter oldDelegate) {
    return legAngle != oldDelegate.legAngle || armAngle != oldDelegate.armAngle;
  }
}

/// A compact version for buttons and small spaces
class RunningLoaderCompact extends StatefulWidget {
  final double size;
  final Color? color;

  const RunningLoaderCompact({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  State<RunningLoaderCompact> createState() => _RunningLoaderCompactState();
}

class _RunningLoaderCompactState extends State<RunningLoaderCompact>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Circular track
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (widget.color ?? AppColors.blue[500]!).withValues(alpha: 0.2),
                    width: 3,
                  ),
                ),
              ),
              // Running indicator
              Transform.rotate(
                angle: _controller.value * 2 * math.pi,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color ?? AppColors.blue[500],
                    ),
                  ),
                ),
              ),
              // Running icon in center
              Icon(
                Icons.directions_run_rounded,
                size: widget.size * 0.5,
                color: widget.color ?? AppColors.blue[500],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Full screen loading overlay with running animation
class RunningLoaderOverlay extends StatelessWidget {
  final String? message;
  final bool isVisible;

  const RunningLoaderOverlay({
    super.key,
    this.message,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(32.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: RunningLoader(
            message: message,
            size: 100,
          ),
        ),
      ),
    );
  }
}
