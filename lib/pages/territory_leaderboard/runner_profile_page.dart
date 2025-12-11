import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:turun/resources/assets_app.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';
import 'widgets/run_history_item.dart';

class RunnerProfilePage extends StatelessWidget {
  final String runnerName;

  const RunnerProfilePage({
    super.key,
    required this.runnerName,
  });

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
            const RunHistoryItem(
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
}
