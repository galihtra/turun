import 'package:flutter/material.dart';
import 'package:turun/data/model/broadcast/broadcast_model.dart';

/// A beautiful broadcast card widget that displays announcements, promotions, and surveys
class BroadcastCard extends StatefulWidget {
  final BroadcastModel broadcast;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;
  final VoidCallback? onView;

  const BroadcastCard({
    super.key,
    required this.broadcast,
    this.onAction,
    this.onDismiss,
    this.onView,
  });

  @override
  State<BroadcastCard> createState() => _BroadcastCardState();
}

class _BroadcastCardState extends State<BroadcastCard> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    
    // Record view after animation
    Future.delayed(const Duration(milliseconds: 500), () {
      widget.onView?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return const Color(0xFF4F46E5); // Default indigo
    }
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return const Color(0xFF4F46E5);
    }
  }

  void _handleDismiss() async {
    await _controller.reverse();
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _parseColor(widget.broadcast.backgroundColor);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                backgroundColor,
                backgroundColor.withValues(alpha: 0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Background pattern
                Positioned(
                  right: -30,
                  bottom: -30,
                  child: Icon(
                    _getIconData(widget.broadcast.iconName),
                    size: 120,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                widget.broadcast.iconEmoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          
                          // Title & Subtitle
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.broadcast.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                                if (widget.broadcast.subtitle != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.broadcast.subtitle!,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          
                          // Dismiss button
                          GestureDetector(
                            onTap: _handleDismiss,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white.withValues(alpha: 0.8),
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Description
                      if (widget.broadcast.description != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          widget.broadcast.description!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      
                      // Action button
                      if (widget.broadcast.hasAction && 
                          widget.broadcast.actionLabel != null) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: widget.onAction,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.broadcast.actionLabel!,
                                  style: TextStyle(
                                    color: backgroundColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  _getActionIcon(widget.broadcast.actionType),
                                  color: backgroundColor,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconData(BroadcastIconName? iconName) {
    switch (iconName) {
      case BroadcastIconName.megaphone:
        return Icons.campaign;
      case BroadcastIconName.gift:
        return Icons.card_giftcard;
      case BroadcastIconName.star:
        return Icons.star;
      case BroadcastIconName.survey:
        return Icons.assignment;
      case BroadcastIconName.alert:
        return Icons.warning;
      case BroadcastIconName.trophy:
        return Icons.emoji_events;
      case BroadcastIconName.heart:
        return Icons.favorite;
      case BroadcastIconName.lightning:
        return Icons.flash_on;
      default:
        return Icons.campaign;
    }
  }

  IconData _getActionIcon(BroadcastActionType actionType) {
    switch (actionType) {
      case BroadcastActionType.link:
        return Icons.open_in_new;
      case BroadcastActionType.survey:
        return Icons.assignment_outlined;
      case BroadcastActionType.inApp:
        return Icons.arrow_forward;
      default:
        return Icons.arrow_forward;
    }
  }
}

/// A compact broadcast banner for showing at the top of screens
class BroadcastBanner extends StatelessWidget {
  final BroadcastModel broadcast;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const BroadcastBanner({
    super.key,
    required this.broadcast,
    this.onTap,
    this.onDismiss,
  });

  Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return const Color(0xFF4F46E5);
    }
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return const Color(0xFF4F46E5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _parseColor(broadcast.backgroundColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              broadcast.iconEmoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    broadcast.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (broadcast.subtitle != null)
                    Text(
                      broadcast.subtitle!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (broadcast.hasAction)
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withValues(alpha: 0.8),
                size: 16,
              ),
            if (onDismiss != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDismiss,
                child: Icon(
                  Icons.close,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 20,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
