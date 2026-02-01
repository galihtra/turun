import 'package:flutter/material.dart';
import 'package:turun/base_widgets/dialogs/gamified_dialog.dart';

class RunDialogs {
  /// Show confirmation dialog for finishing a run
  static Future<bool?> showFinishConfirmation(BuildContext context) {
    return GamifiedDialog.show<bool>(
      context: context,
      title: 'Finish Run?',
      description: 'Amazing progress! Are you sure you want to wrap up this run session and save your achievements?',
      icon: Icons.flag_rounded,
      headerGradient: [
        const Color(0xFF10B981),
        const Color(0xFF059669),
      ],
      primaryButtonText: 'FINISH',
      onPrimaryPressed: () => Navigator.pop(context, true),
      secondaryButtonText: 'KEEP GOING',
      onSecondaryPressed: () => Navigator.pop(context, false),
    );
  }

  /// Show confirmation dialog for canceling a run
  static Future<bool?> showCancelConfirmation(BuildContext context) {
    return GamifiedDialog.show<bool>(
      context: context,
      title: 'Cancel Run?',
      description: 'Warning! Discarding this run will lose all progress and unclaimed territory points. Are you sure?',
      icon: Icons.warning_rounded,
      headerGradient: [
        const Color(0xFFEF4444),
        const Color(0xFFDC2626),
      ],
      primaryButtonText: 'YES, DISCARD',
      onPrimaryPressed: () => Navigator.pop(context, true),
      secondaryButtonText: 'NO, WAIT',
      onSecondaryPressed: () => Navigator.pop(context, false),
    );
  }
}
