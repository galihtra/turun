import 'package:flutter/material.dart';
import 'package:turun/resources/colors_app.dart';

class RunDialogs {
  /// Show confirmation dialog for finishing a run
  static Future<bool?> showFinishConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish Run?'),
        content: const Text('Are you sure you want to finish this run?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green[500],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  /// Show confirmation dialog for canceling a run
  static Future<bool?> showCancelConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Run?'),
        content: const Text('Are you sure? This will discard your progress.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red[500],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
