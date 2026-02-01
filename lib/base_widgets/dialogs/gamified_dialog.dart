import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:turun/resources/styles_app.dart';

class GamifiedDialog extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> headerGradient;
  final String primaryButtonText;
  final VoidCallback onPrimaryPressed;
  final String secondaryButtonText;
  final VoidCallback onSecondaryPressed;
  final Color? primaryButtonColor;

  const GamifiedDialog({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.headerGradient,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    required this.secondaryButtonText,
    required this.onSecondaryPressed,
    this.primaryButtonColor,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required List<Color> headerGradient,
    required String primaryButtonText,
    required VoidCallback onPrimaryPressed,
    required String secondaryButtonText,
    required VoidCallback onSecondaryPressed,
    Color? primaryButtonColor,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = Curves.easeOutBack.transform(anim1.value);
        return Transform.scale(
          scale: curve,
          child: Opacity(
            opacity: anim1.value.clamp(0.0, 1.0),
            child: GamifiedDialog(
              title: title,
              description: description,
              icon: icon,
              headerGradient: headerGradient,
              primaryButtonText: primaryButtonText,
              onPrimaryPressed: onPrimaryPressed,
              secondaryButtonText: secondaryButtonText,
              onSecondaryPressed: onSecondaryPressed,
              primaryButtonColor: primaryButtonColor,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: headerGradient.first.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: headerGradient,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const Gap(16),
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                children: [
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: AppStyles.body1Regular.copyWith(
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const Gap(32),
                  
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onSecondaryPressed,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            secondaryButtonText,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onPrimaryPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryButtonColor ?? headerGradient.first,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            primaryButtonText,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
