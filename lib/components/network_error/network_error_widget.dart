import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';

/// Network error types for gamification messages
enum NetworkErrorType {
  noConnection,    // 📵 No internet at all
  slowConnection,  // 🐌 Internet is very slow
  timeout,         // ⏱️ Request timed out
  serverError,     // 🔥 Server is down
}

/// A gamified network error widget with fun messages and animations
class NetworkErrorWidget extends StatefulWidget {
  final NetworkErrorType errorType;
  final VoidCallback? onRetry;
  final bool showRetryButton;
  final bool isCompact;

  const NetworkErrorWidget({
    super.key,
    required this.errorType,
    this.onRetry,
    this.showRetryButton = true,
    this.isCompact = false,
  });

  @override
  State<NetworkErrorWidget> createState() => _NetworkErrorWidgetState();
}

class _NetworkErrorWidgetState extends State<NetworkErrorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = _getErrorConfig();

    if (widget.isCompact) {
      return _buildCompactView(config);
    }

    return _buildFullView(config);
  }

  Widget _buildFullView(_ErrorConfig config) {
    return Container(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Icon
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -_bounceAnimation.value),
                child: Transform.scale(
                  scale: _pulseAnimation.value,
                  child: _buildIconContainer(config),
                ),
              );
            },
          ),
          SizedBox(height: 32.h),

          // Title with emoji
          Text(
            config.title,
            style: AppStyles.title2SemiBold.copyWith(
              color: AppColors.black[900],
              fontSize: 22.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),

          // Gamified message
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  config.color.withValues(alpha: 0.1),
                  config.color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: config.color.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  config.message,
                  style: AppStyles.body2Regular.copyWith(
                    color: AppColors.black[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                // Fun tip
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppColors.yellow[600],
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        config.tip,
                        style: AppStyles.label3Regular.copyWith(
                          color: AppColors.black[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Stats badge (gamification element)
          _buildStatsBadge(config),
          SizedBox(height: 24.h),

          // Retry button
          if (widget.showRetryButton && widget.onRetry != null)
            _buildRetryButton(config),
        ],
      ),
    );
  }

  Widget _buildCompactView(_ErrorConfig config) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: config.color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [config.color, config.color.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                config.emoji,
                style: TextStyle(fontSize: 24.sp),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  config.title,
                  style: AppStyles.label1SemiBold.copyWith(
                    color: AppColors.black[900],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  config.shortMessage,
                  style: AppStyles.label3Regular.copyWith(
                    color: AppColors.black[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Retry button
          if (widget.showRetryButton && widget.onRetry != null)
            IconButton(
              onPressed: widget.onRetry,
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: config.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIconContainer(_ErrorConfig config) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        Container(
          width: 140.w,
          height: 140.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                config.color.withValues(alpha: 0.3),
                config.color.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
        // Main circle
        Container(
          width: 100.w,
          height: 100.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                config.color,
                config.color.withValues(alpha: 0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: config.color.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              config.emoji,
              style: TextStyle(fontSize: 48.sp),
            ),
          ),
        ),
        // Status ring
        Container(
          width: 120.w,
          height: 120.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: config.color.withValues(alpha: 0.3),
              width: 3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBadge(_ErrorConfig config) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.black[800],
        borderRadius: BorderRadius.circular(50.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.statusIcon,
            color: config.color,
            size: 18.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            config.statusText,
            style: AppStyles.label2SemiBold.copyWith(
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: config.color,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              config.statusBadge,
              style: AppStyles.label3SemiBold.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetryButton(_ErrorConfig config) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onRetry,
        style: ElevatedButton.styleFrom(
          backgroundColor: config.color,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 4,
          shadowColor: config.color.withValues(alpha: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.replay_rounded,
              color: Colors.white,
              size: 22.sp,
            ),
            SizedBox(width: 10.w),
            Text(
              config.retryText,
              style: AppStyles.label1SemiBold.copyWith(
                color: Colors.white,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _ErrorConfig _getErrorConfig() {
    switch (widget.errorType) {
      case NetworkErrorType.noConnection:
        return _ErrorConfig(
          emoji: '📵',
          title: 'Connection Lost!',
          message: 'Looks like your signal went ninja mode! 🥷\n'
              'Your internet is currently playing hide and seek...',
          shortMessage: 'No internet connection',
          tip: 'Try checking your WiFi or mobile data!',
          color: AppColors.red[500]!,
          statusIcon: Icons.signal_wifi_off_rounded,
          statusText: 'SIGNAL LOST',
          statusBadge: 'OFFLINE',
          retryText: 'Try Again! 🔄',
        );
      case NetworkErrorType.slowConnection:
        return _ErrorConfig(
          emoji: '🐌',
          title: 'Super Slow Network!',
          message: 'Your internet is slower than a sleepy turtle! 🐢\n'
              'Hang tight, there\'s a traffic jam on the data highway...',
          shortMessage: 'Slow connection, please wait...',
          tip: 'Maybe move to a spot with better signal?',
          color: AppColors.orange[500]!,
          statusIcon: Icons.signal_wifi_4_bar_rounded,
          statusText: 'SLOW MODE',
          statusBadge: 'LOADING...',
          retryText: 'Let\'s Try Again! 🚀',
        );
      case NetworkErrorType.timeout:
        return _ErrorConfig(
          emoji: '⏱️',
          title: 'Time\'s Up!',
          message: 'The server took too long to respond! ⏳\n'
              'Maybe it\'s stuck in a meeting...',
          shortMessage: 'Request timed out, try again',
          tip: 'Wait a moment and try again!',
          color: AppColors.yellow[600]!,
          statusIcon: Icons.timer_off_rounded,
          statusText: 'TIMEOUT',
          statusBadge: 'EXPIRED',
          retryText: 'Retry Request! ⏰',
        );
      case NetworkErrorType.serverError:
        return _ErrorConfig(
          emoji: '🔥',
          title: 'Server on Fire!',
          message: 'Our server is having a meltdown! 🧯\n'
              'The team is working hard to put out the flames...',
          shortMessage: 'Server error, team is on it',
          tip: 'This isn\'t your fault, give us a moment!',
          color: AppColors.purple[500]!,
          statusIcon: Icons.cloud_off_rounded,
          statusText: 'SERVER DOWN',
          statusBadge: 'ERROR 500',
          retryText: 'Check Again! 🔍',
        );
    }
  }
}

class _ErrorConfig {
  final String emoji;
  final String title;
  final String message;
  final String shortMessage;
  final String tip;
  final Color color;
  final IconData statusIcon;
  final String statusText;
  final String statusBadge;
  final String retryText;

  _ErrorConfig({
    required this.emoji,
    required this.title,
    required this.message,
    required this.shortMessage,
    required this.tip,
    required this.color,
    required this.statusIcon,
    required this.statusText,
    required this.statusBadge,
    required this.retryText,
  });
}

/// Static helper to show network error dialogs
class NetworkErrorDialog {
  static Future<void> show(
    BuildContext context, {
    required NetworkErrorType errorType,
    VoidCallback? onRetry,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NetworkErrorWidget(
                errorType: errorType,
                onRetry: () {
                  Navigator.pop(context);
                  onRetry?.call();
                },
              ),
              // Close button
              Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Close',
                    style: AppStyles.label2Medium.copyWith(
                      color: AppColors.grey[600],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show a snackbar-style network error
  static void showSnackbar(
    BuildContext context, {
    required NetworkErrorType errorType,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    final config = _getConfig(errorType);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(
              config['emoji']!,
              style: TextStyle(fontSize: 24.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    config['title']!,
                    style: AppStyles.label2SemiBold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    config['shortMessage']!,
                    style: AppStyles.label3Regular.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            if (onRetry != null)
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onRetry.call();
                },
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
          ],
        ),
        backgroundColor: _getColor(errorType),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        margin: EdgeInsets.all(16.w),
        duration: duration,
      ),
    );
  }

  static Map<String, String> _getConfig(NetworkErrorType type) {
    switch (type) {
      case NetworkErrorType.noConnection:
        return {
          'emoji': '📵',
          'title': 'Connection Lost!',
          'shortMessage': 'No internet connection',
        };
      case NetworkErrorType.slowConnection:
        return {
          'emoji': '🐌',
          'title': 'Slow Network!',
          'shortMessage': 'Connection is slow, please wait...',
        };
      case NetworkErrorType.timeout:
        return {
          'emoji': '⏱️',
          'title': 'Time\'s Up!',
          'shortMessage': 'Request timed out',
        };
      case NetworkErrorType.serverError:
        return {
          'emoji': '🔥',
          'title': 'Server Error!',
          'shortMessage': 'Something went wrong on our end',
        };
    }
  }

  static Color _getColor(NetworkErrorType type) {
    switch (type) {
      case NetworkErrorType.noConnection:
        return AppColors.red[500]!;
      case NetworkErrorType.slowConnection:
        return AppColors.orange[500]!;
      case NetworkErrorType.timeout:
        return AppColors.yellow[700]!;
      case NetworkErrorType.serverError:
        return AppColors.purple[500]!;
    }
  }
}

/// Bottom sheet version for more detailed error display
class NetworkErrorBottomSheet {
  static Future<void> show(
    BuildContext context, {
    required NetworkErrorType errorType,
    VoidCallback? onRetry,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            NetworkErrorWidget(
              errorType: errorType,
              onRetry: () {
                Navigator.pop(context);
                onRetry?.call();
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
