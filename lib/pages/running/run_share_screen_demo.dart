import 'package:flutter/material.dart';
import 'run_share_screen.dart';

/// Demo page to test RunShareScreen UI with complete game-like stats
class RunShareScreenDemo extends StatelessWidget {
  const RunShareScreenDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Run Share Demo'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.share,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              const Text(
                'Test Run Share Screen',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'dengan informasi lengkap ala game achievement!',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Test Case 1: Full Marathon with Territory Conquest
              _buildTestButton(
                context,
                'Full Marathon - Territory Conquered 🏆',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RunShareScreen(
                      distance: '21.51 km',
                      pace: '6:01 /km',
                      duration: '2j 9m',
                      avgSpeed: '10.0 km/h',
                      maxSpeed: '15.2 km/h',
                      calories: '1291 cal',
                      territoryConquered: true,
                      territoryName: 'Grand Harbour',
                      totalTerritories: 12,
                      userName: 'Galih Runner',
                      userLevel: 'Level 15 - Marathon Master',
                    ),
                  ),
                ),
                Colors.orange,
                Icons.emoji_events,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestButton(
    BuildContext context,
    String label,
    VoidCallback onPressed,
    Color color,
    IconData icon,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  
}
