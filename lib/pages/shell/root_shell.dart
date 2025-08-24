import 'package:flutter/material.dart';
import 'package:turun/components/bottom_navigation/bottom_nav_bar.dart';
import 'package:turun/pages/history/history_page.dart';
import 'package:turun/pages/home/home_page.dart';
import 'package:turun/pages/profile/profile_page.dart';
import 'package:turun/pages/territory_leaderboard/territory_leaderboard.dart';
import '../../../../resources/colors_app.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  // IndexedStack menjaga state tiap page.
  final _pages = const [
    HomePage(),
    TerritoryLeaderboard(),
    HistoryPage(),
    ProfilePage(),
  ];

  void _onChanged(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // agar tombol tengah “menonjol”
      body: SafeArea(
        top: false, // biar area header custom bisa full bleed kalau perlu
        child: IndexedStack(index: _index, children: _pages),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _index,
        onChanged: _onChanged,
        onCenterTap: () {
          // aksi tombol tengah (sesuai mockup: Run / Start Activity)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Start / Center action tapped')),
          );
        },
      ),
      backgroundColor: AppColors.deepBlue,
    );
  }
}
