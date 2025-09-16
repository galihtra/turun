import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterReminderPage extends StatefulWidget {
  const WaterReminderPage({super.key});

  @override
  _WaterReminderPageState createState() => _WaterReminderPageState();
}

class _WaterReminderPageState extends State<WaterReminderPage> {
  int _waterIntake = 0;
  final int _targetIntake = 2000; 
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadWaterIntake();
  }

  _loadWaterIntake() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _waterIntake = _prefs.getInt('waterIntake') ?? 0;
    });
    _checkAndResetDailyIntake();
  }

  _checkAndResetDailyIntake() async {
    DateTime now = DateTime.now();
    String? lastResetDateStr = _prefs.getString('lastResetDate');
    
    if (lastResetDateStr == null) {
      await _prefs.setString('lastResetDate', now.toString());
      return;
    }
    
    DateTime lastResetDate = DateTime.parse(lastResetDateStr);
    
    if (now.day != lastResetDate.day || 
        now.month != lastResetDate.month || 
        now.year != lastResetDate.year) {
      setState(() {
        _waterIntake = 0;
      });
      await _prefs.setInt('waterIntake', 0);
      await _prefs.setString('lastResetDate', now.toString());
    }
  }

  // Increment water intake and save it
  _incrementWaterIntake(int amount) async {
    await _checkAndResetDailyIntake();
    
    setState(() {
      _waterIntake += amount;
    });
    await _prefs.setInt('waterIntake', _waterIntake);
  }

  _resetIntake() async {
    setState(() {
      _waterIntake = 0;
    });
    await _prefs.setInt('waterIntake', 0);
    await _prefs.setString('lastResetDate', DateTime.now().toString());
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Water intake reset to 0'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = _waterIntake / _targetIntake;
    progress = progress > 1.0 ? 1.0 : progress; 
    
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Daily Water Intake',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 30),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12.0,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$_waterIntake ml',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Goal: $_targetIntake ml',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            Text(
              _waterIntake >= _targetIntake 
                  ? 'Goal Achieved! 🎉' 
                  : 'Keep hydrating! 💧',
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: _waterIntake >= _targetIntake ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _incrementWaterIntake(250),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('+250 ml'),
                ),
                ElevatedButton(
                  onPressed: () => _incrementWaterIntake(500),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('+500 ml'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Removed the notification button
          ],
        ),
      ),
    );
  }
}