import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:turun/data/model/territory/territory_model.dart';

enum WarningMode {
  proximity,  // User is physically near/at an owned territory when starting Landmark run
  planning,   // User's planned route passes through an owned territory
  completion  // User's completed run overlaps with an existing territory
}

class PlanningDialogs {
  /// Show a gamified warning when territory interference is detected
  static Future<bool> showOverlapWarning(
    BuildContext context, 
    Territory territory, {
    WarningMode mode = WarningMode.planning,
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = Curves.elasticOut.transform(anim1.value);
        return Transform.scale(
          scale: curve,
          child: Opacity(
            opacity: anim1.value.clamp(0.0, 1.0),
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF121212),
                      const Color(0xFF1E1E1E),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.1),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated Header Section
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.05),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Pulse effect
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.8, end: 1.2),
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeInOut,
                            builder: (context, value, child) {
                              return Container(
                                width: 120 * value,
                                height: 120 * value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.amber.withValues(alpha: 0.1 / value),
                                ),
                              );
                            },
                          ),
                          const Icon(
                            Icons.gpp_bad_rounded,
                            size: 80,
                            color: Colors.amber,
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                      child: Column(
                        children: [
                          const Text(
                            'ZONE OCCUPIED!',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.5,
                            ),
                          ),
                          const Gap(20),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                height: 1.6,
                              ),
                              children: [
                                TextSpan(
                                  text: mode == WarningMode.planning 
                                    ? 'Your planned route crosses into '
                                    : mode == WarningMode.completion
                                      ? 'Your finished route overlaps with '
                                      : 'You are standing within ',
                                ),
                                TextSpan(
                                  text: territory.name ?? 'a rival zone',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: mode == WarningMode.planning
                                    ? '.\n\nTo build your own Landmark, find an unclaimed path elsewhere.'
                                    : mode == WarningMode.completion
                                      ? '.\n\nThis area is already claimed by another runner. This landmark cannot be registered here!'
                                      : '.\n\nThis territory belongs to another runner. You cannot start a new Landmark here!',
                                ),
                              ],
                            ),
                          ),
                          const Gap(32),
                          
                          // Primary Action
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mode == WarningMode.proximity ? Colors.white : Colors.amber,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                mode == WarningMode.proximity 
                                  ? 'CHALLENGE RIVAL' 
                                  : mode == WarningMode.completion
                                    ? 'ACKNOWLEDGE'
                                    : 'FIND ANOTHER PATH',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                          
                          if (mode == WarningMode.proximity) ...[
                            const Gap(12),
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text(
                                'Dismiss',
                                style: TextStyle(color: Colors.white38),
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
      },
    );
    return result ?? false;
  }
}
