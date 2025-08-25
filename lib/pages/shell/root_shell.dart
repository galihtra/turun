import 'package:flutter/material.dart';
import 'package:turun/components/bottom_navigation/bottom_nav_bar.dart';
import 'package:turun/pages/history/history_page.dart';
import 'package:turun/pages/home/home_page.dart';
import 'package:turun/pages/profile/profile_page.dart';
import 'package:turun/pages/territory_leaderboard/territory_leaderboard.dart';
import 'package:turun/resources/values_app.dart';
import '../../../../resources/colors_app.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;
  final _pages = [
    const HomePage(),
    TerritoryLeaderboard(),
    const HistoryPage(),
    const ProfilePage(),
  ];
  void _onChanged(int i) => setState(() => _index = i);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        top: false,
        child: IndexedStack(index: _index, children: _pages),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (_) => const StartPage()),
          // );
        },
        child: Container(
          width: AppDimens.w70,
          height: AppDimens.h70,
          decoration: const ShapeDecoration(
            gradient: AppColors.blueGradient,
            shape: CircleBorder(),
          ),
          child: const Icon(
            Icons.directions_run_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.symmetric(horizontal: AppDimens.w16),
        height: AppDimens.h80,
        color: AppColors.deepBlue,
        shape: const CircularNotchedRectangle(),
        notchMargin: 5,
        child: BottomNavBar(
          currentIndex: _index,
          onChanged: _onChanged,
        ),
      ),
    );
  }
}
