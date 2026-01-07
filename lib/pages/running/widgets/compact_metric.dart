import 'package:flutter/material.dart';
import 'package:turun/resources/values_app.dart';

import '../../../resources/colors_app.dart';

class CompactMetric extends StatelessWidget {
  final String label;
  final String value;

  const CompactMetric({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.blueLogo,
          ),
        ),
        AppGaps.kGap4,
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
