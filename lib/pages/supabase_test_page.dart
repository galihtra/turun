import 'package:flutter/material.dart';

import '../helper/supabase_test_helper.dart';

class SupabaseTestPage extends StatelessWidget {
  const SupabaseTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await SupabaseTestHelper.testConnection();
              },
              child: const Text('Test Connection'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await SupabaseTestHelper.checkTableStructure();
              },
              child: const Text('Check Table Structure'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await SupabaseTestHelper.insertDummyTerritory();
              },
              child: const Text('Insert Dummy Data'),
            ),
          ],
        ),
      ),
    );
  }
}