import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CompletionHeader extends StatelessWidget {
  final AnimationController animationController;
  final bool territoryConquered;

  const CompletionHeader({
    super.key,
    required this.animationController,
    required this.territoryConquered,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Trophy/Check icon with animation
        FadeTransition(
          opacity: animationController,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animationController,
                curve: Curves.elasticOut,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                territoryConquered
                    ? Icons.emoji_events_rounded
                    : Icons.check_circle_rounded,
                size: 80,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const Gap(30),

        // Title
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.5),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animationController,
              curve: Curves.easeOut,
            ),
          ),
          child: FadeTransition(
            opacity: animationController,
            child: Text(
              territoryConquered
                  ? '🎉 Territory Conquered! 🎉'
                  : 'Run Completed!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        const Gap(10),

        // Subtitle
        FadeTransition(
          opacity: animationController,
          child: Text(
            territoryConquered
                ? 'You are now the owner of this territory!'
                : 'Great job on completing your run!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
