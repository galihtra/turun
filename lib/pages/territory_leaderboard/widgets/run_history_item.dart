import 'package:flutter/material.dart';

import '../../../resources/colors_app.dart';
import '../../../resources/styles_app.dart';

class RunHistoryItem extends StatelessWidget {
  final String title;
  final String date;
  final String distance;
  final String duration;
  final String avgPace;
  final String landmarkImage;

  const RunHistoryItem({
    super.key,
    required this.title,
    required this.date,
    required this.distance,
    required this.duration,
    required this.avgPace,
    required this.landmarkImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      constraints: BoxConstraints(
        minWidth: 250, 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 100,
                width: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: Image.asset(
                  landmarkImage,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: AppStyles.body2SemiBold.copyWith(
                            color: AppColors.deepBlue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "0.02 km²",
                          style: AppStyles.body1SemiBold.copyWith(
                            color: AppColors.deepBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      date,
                      style: AppStyles.body3SemiBold.copyWith(
                        color: AppColors.deepBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _RunDetailItem(title: "Distance", value: distance),
                        _RunDetailItem(title: "Duration", value: duration),
                        _RunDetailItem(title: "Avg pace", value: avgPace),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RunDetailItem extends StatelessWidget {
  final String title;
  final String value;

  const _RunDetailItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: AppStyles.body3Medium.copyWith(
            color: AppColors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppStyles.body1SemiBold.copyWith(
            color: AppColors.deepBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
