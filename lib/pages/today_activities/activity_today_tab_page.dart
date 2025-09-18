import 'package:flutter/material.dart';
import 'package:turun/pages/today_activities/step_tracker/step_tracker_page.dart';
import 'package:turun/pages/today_activities/water_reminder/water_reminder_page.dart';
import 'package:turun/resources/colors_app.dart';

import '../../resources/styles_app.dart';

class ActivityTodayTabPage extends StatelessWidget {
  const ActivityTodayTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Today',
            style: AppStyles.title1SemiBold.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.blueThird,
            ),
          ),
          iconTheme: const IconThemeData(
            color: AppColors.blueThird,
          ),
          backgroundColor: Colors.transparent,
          bottom: const TabBar(
            dividerColor: Colors.transparent,
            labelColor: AppColors.blueThird,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.blueThird,
            tabs: [
              Tab(text: 'Drink Water'),
              Tab(text: 'Steps'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            WaterReminderPage(),
            StepTrackerPage(),
          ],
        ),
      ),
    );
  }
}
