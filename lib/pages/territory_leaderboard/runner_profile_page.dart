import 'package:flutter/material.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';

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
          icon: Icon(Icons.arrow_back, color: AppColors.deepBlue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Runner Name
            Center(
              child: Text(
                runnerName,
                style: AppStyles.title2SemiBold.copyWith(
                  color: AppColors.deepBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.directions_run,
                    title: "Total Runs",
                    value: "10",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.landscape,
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
                    icon: Icons.alt_route,
                    title: "Total Distance",
                    value: "24 km",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.timer,
                    title: "Total Duration",
                    value: "01:30:15",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Running History Title
            Text(
              "Running History",
              style: AppStyles.title2SemiBold.copyWith(
                color: AppColors.deepBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Running History List
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 6,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildRunHistoryItem(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
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
          Icon(icon, color: AppColors.deepBlue),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppStyles.body3Medium.copyWith(color: AppColors.deepBlue),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppStyles.body3Medium.copyWith(
              color: AppColors.deepBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRunHistoryItem() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_run, size: 16, color: AppColors.deepBlue),
              const SizedBox(width: 8),
              Text(
                "Morning Run",
                style: AppStyles.body2Medium.copyWith(
                  color: AppColors.deepBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                "0.02 km",
                style: AppStyles.body3Medium.copyWith(color: AppColors.deepBlue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "27 July 2025 08:00 AM",
            style: AppStyles.body3Medium.copyWith(color: AppColors.grey),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _RunDetailItem(title: "Distance", value: "0.5 km"),
              _RunDetailItem(title: "Duration", value: "03:10"),
              _RunDetailItem(title: "Avg pace", value: "06:20"),
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
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: AppStyles.body2SemiBold.copyWith(color: AppColors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppStyles.body3SemiBold.copyWith(
            color: AppColors.deepBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}