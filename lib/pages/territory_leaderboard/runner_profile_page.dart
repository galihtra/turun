import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:turun/resources/assets_app.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';
import 'package:turun/resources/values_app.dart';

class RunnerProfilePage extends StatelessWidget {
  final String runnerName;

  const RunnerProfilePage({
    Key? key,
    required this.runnerName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Runner Profile",
          style: AppStyles.title2SemiBold.copyWith(color: AppColors.deepBlue),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.deepBlue,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.deepBlue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.person_outline,
                    color: AppColors.deepBlue,
                    size: 50,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    runnerName,
                    style: AppStyles.title3SemiBold.copyWith(
                      color: AppColors.deepBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: AppIcons.totalRun,
                    title: "Total Runs",
                    value: "10",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: AppIcons.totalArea,
                    title: "Total Area",
                    value: "450 Km²",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: AppIcons.totalDistance,
                    title: "Total Distance",
                    value: "24 km",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: AppIcons.totalDuration,
                    title: "Total Duration",
                    value: "01:30:15",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              "Running History",
              style:
                  AppStyles.title2SemiBold.copyWith(color: AppColors.deepBlue),
            ),
            const SizedBox(height: 16),
            _buildRunHistoryItem(
              title: "Morning Run",
              date: "27 July 2025 08:00 AM",
              distance: "0.5 km",
              duration: "03:10",
              avgPace: "06:20",
              landmarkImage: AppImages.exMapsLandmark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blueLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                icon,
                height: 24,
                width: 24,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppStyles.body3Medium
                    .copyWith(color: AppColors.deepBlueOpacity),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppStyles.title3Medium.copyWith(
              color: AppColors.deepBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRunHistoryItem({
    required String title,
    required String date,
    required String distance,
    required String duration,
    required String avgPace,
    required String landmarkImage,
  }) {
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
              AppGaps.kGap12,
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
                        AppGaps.kGap8,
                        Text(
                          "0.02 km²",
                          style: AppStyles.body1SemiBold.copyWith(
                            color: AppColors.deepBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    AppGaps.kGap12,
                    Text(
                      date,
                      style: AppStyles.body3SemiBold.copyWith(
                        color: AppColors.deepBlue,
                      ),
                    ),
                    AppGaps.kGap12,
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
        AppGaps.kGap4,
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
