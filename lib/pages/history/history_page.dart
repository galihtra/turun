import 'package:flutter/material.dart';

import '../../data/services/test_service.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final testService = TestService();

    return Scaffold(
      appBar: AppBar(title: const Text('Test Supabase')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                testService.insertTestData();
              },
              child: const Text('Insert Test Data'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                testService.fetchTestData();
              },
              child: const Text('Fetch Test Data'),
            ),
          ],
        ),
      ),
    );
  }
}
