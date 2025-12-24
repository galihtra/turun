import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turun/data/model/goals/goal_model.dart';
import 'package:turun/data/providers/goals/goal_provider.dart';
import 'package:turun/resources/colors_app.dart';

class GoalSettingScreen extends StatefulWidget {
  const GoalSettingScreen({super.key});

  @override
  State<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends State<GoalSettingScreen> {
  int _selectedTab = 0; // 0 = Distance, 1 = Calories
  GoalUnit _selectedDistanceUnit = GoalUnit.km;
  GoalPeriod _selectedPeriod = GoalPeriod.daily;
  double _distanceGoal = 20.0;
  double _caloriesGoal = 500.0;

  @override
  void initState() {
    super.initState();
    _loadCurrentGoals();
  }

  void _loadCurrentGoals() {
    final goalProvider = context.read<GoalProvider>();

    if (goalProvider.activeDistanceGoal != null) {
      _distanceGoal = goalProvider.activeDistanceGoal!.targetValue;
      _selectedDistanceUnit = goalProvider.activeDistanceGoal!.unit;
      _selectedPeriod = goalProvider.activeDistanceGoal!.period;
    }

    if (goalProvider.activeCaloriesGoal != null) {
      _caloriesGoal = goalProvider.activeCaloriesGoal!.targetValue;
      _selectedPeriod = goalProvider.activeCaloriesGoal!.period;
    }
  }

  Future<void> _saveGoal() async {
    final goalProvider = context.read<GoalProvider>();

    final type = _selectedTab == 0 ? GoalType.distance : GoalType.calories;
    final targetValue = _selectedTab == 0 ? _distanceGoal : _caloriesGoal;
    final unit = _selectedTab == 0 ? _selectedDistanceUnit : GoalUnit.kcal;

    final success = await goalProvider.setGoal(
      type: type,
      targetValue: targetValue,
      unit: unit,
      period: _selectedPeriod,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Goal set successfully!',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          backgroundColor: AppColors.blueLogo,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.navy[900]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Goal Setting',
          style: TextStyle(
            color: AppColors.navy[900],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tab selector
          _buildTabSelector(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Unit selector
                  _buildUnitSelector(),

                  const SizedBox(height: 40),

                  // Number picker
                  _buildNumberPicker(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Save button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueLogo,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Set New Goal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTab('Distance', 0),
          ),
          Expanded(
            child: _buildTab('Calories', 1),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blueLogo : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildUnitSelector() {
    return Column(
      children: [
        // Period selector
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.blueLogo, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildPeriodButton('Daily', GoalPeriod.daily),
              ),
              Expanded(
                child: _buildPeriodButton('Weekly', GoalPeriod.weekly),
              ),
              Expanded(
                child: _buildPeriodButton('Monthly', GoalPeriod.monthly),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Unit selector (only for distance)
        if (_selectedTab == 0)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.blueLogo, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildUnitButton('Km', GoalUnit.km, _selectedDistanceUnit, (unit) {
                    setState(() => _selectedDistanceUnit = unit);
                  }),
                ),
                Expanded(
                  child: _buildUnitButton('Mile', GoalUnit.mile, _selectedDistanceUnit, (unit) {
                    setState(() => _selectedDistanceUnit = unit);
                  }),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPeriodButton(String label, GoalPeriod period) {
    final isSelected = period == _selectedPeriod;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = period),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blueLogo : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.blueLogo,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildUnitButton(
    String label,
    GoalUnit unit,
    GoalUnit selectedUnit,
    Function(GoalUnit) onSelect,
  ) {
    final isSelected = unit == selectedUnit;
    return GestureDetector(
      onTap: () => onSelect(unit),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blueLogo : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.blueLogo,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPicker() {
    final currentValue = _selectedTab == 0 ? _distanceGoal : _caloriesGoal;
    final values = _generateValues();

    return SizedBox(
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Selection indicator
          Container(
            height: 60,
            decoration: BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: AppColors.blueLogo.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
            ),
          ),
          // Scrollable numbers
          ListWheelScrollView.useDelegate(
            itemExtent: 60,
            diameterRatio: 1.5,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              setState(() {
                if (_selectedTab == 0) {
                  _distanceGoal = values[index];
                } else {
                  _caloriesGoal = values[index];
                }
              });
            },
            controller: FixedExtentScrollController(
              initialItem: values.indexOf(currentValue),
            ),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: values.length,
              builder: (context, index) {
                final value = values[index];
                final isSelected = value == currentValue;
                return Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: isSelected ? 48 : 32,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.blueLogo : Colors.grey[400],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getUnitLabel(),
                        style: TextStyle(
                          fontSize: isSelected ? 24 : 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.blueLogo : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<double> _generateValues() {
    List<double> values = [];
    if (_selectedTab == 0) {
      // Distance: 1-50 km
      for (int i = 1; i <= 50; i++) {
        values.add(i.toDouble());
      }
    } else {
      // Calories: 100-2000 kcal (in steps of 50)
      for (int i = 100; i <= 2000; i += 50) {
        values.add(i.toDouble());
      }
    }
    return values;
  }

  String _getUnitLabel() {
    if (_selectedTab == 0) {
      return _selectedDistanceUnit == GoalUnit.km ? 'Km' : 'Mile';
    } else {
      return 'kcal';
    }
  }
}
