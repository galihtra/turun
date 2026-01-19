import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:turun/data/model/nutrition/nutrition_goal_model.dart';
import 'package:turun/data/providers/nutrition/nutrition_provider.dart';
import 'package:turun/data/providers/user/user_provider.dart';
import 'package:turun/pages/nutrition/nutrition_dashboard_screen.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';

/// Screen untuk setup nutrition goal (onboarding)
/// Ambil data otomatis dari user profile
class NutritionSetupScreen extends StatefulWidget {
  const NutritionSetupScreen({super.key});

  @override
  State<NutritionSetupScreen> createState() => _NutritionSetupScreenState();
}

class _NutritionSetupScreenState extends State<NutritionSetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form data
  NutritionGoalType? _selectedGoal;
  final TextEditingController _targetWeightController = TextEditingController();

  // User data (auto-filled from profile)
  double? _weight;
  double? _height;
  int? _age;
  String? _gender;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    if (user != null) {
      setState(() {
        _weight = user.weight;
        _height = user.height;
        _gender = user.gender;

        // Calculate age from birth date
        if (user.birthDate != null) {
          final now = DateTime.now();
          _age = now.year - user.birthDate!.year;
          if (now.month < user.birthDate!.month ||
              (now.month == user.birthDate!.month &&
                  now.day < user.birthDate!.day)) {
            _age = _age! - 1;
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D1B2A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Goal Setup',
          style:
              AppStyles.title3SemiBold.copyWith(color: const Color(0xFF0D1B2A)),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // Help action
            },
            child: Text(
              'Help',
              style: TextStyle(color: AppColors.grey.shade600),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Text(
                    'Step ${_currentPage + 1} of 3',
                    style: TextStyle(
                      color: AppColors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentPage + 1) / 3,
                        backgroundColor: AppColors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.blueLogo,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildGoalSelectionPage(),
                  _buildTargetWeightPage(),
                  _buildSummaryPage(),
                ],
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _canProceed() ? _handleNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueLogo,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.grey.shade300,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentPage == 2 ? 'Create My Plan' : 'Continue',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Gap(8),
                            const Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Page 1: Goal Selection
  Widget _buildGoalSelectionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What is your main goal?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D1B2A),
            ),
          ),
          const Gap(8),
          Text(
            "We'll tailor your daily macros and meal suggestions based on your choice.",
            style: TextStyle(
              fontSize: 15,
              color: AppColors.grey.shade600,
            ),
          ),
          const Gap(32),

          // Goal options
          ...NutritionGoalType.values.map((goal) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildGoalCard(goal),
              )),
        ],
      ),
    );
  }

  Widget _buildGoalCard(NutritionGoalType goal) {
    final isSelected = _selectedGoal == goal;

    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = goal),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.blueLogo : AppColors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.blueLogo.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1B2A),
                    ),
                  ),
                  const Gap(4),
                  Text(
                    goal.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.blueLogo : Colors.transparent,
                border: Border.all(
                  color:
                      isSelected ? AppColors.blueLogo : AppColors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Page 2: Target Weight
  Widget _buildTargetWeightPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Set your target weight',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D1B2A),
            ),
          ),
          const Gap(8),
          Text(
            'Your current weight is ${_weight?.toStringAsFixed(1) ?? '-'} kg',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.grey.shade600,
            ),
          ),
          const Gap(32),

          // Target weight input
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _targetWeightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D1B2A),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.0',
                    hintStyle: TextStyle(
                      color: AppColors.grey.shade300,
                    ),
                    suffixText: 'kg',
                    suffixStyle: TextStyle(
                      fontSize: 24,
                      color: AppColors.grey.shade500,
                    ),
                  ),
                ),
                const Gap(16),
                Text(
                  _getWeightDifferenceText(),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getWeightDifferenceText() {
    if (_weight == null) return '';
    final target = double.tryParse(_targetWeightController.text) ?? _weight!;
    final diff = target - _weight!;

    if (diff.abs() < 0.5) {
      return 'Maintaining current weight';
    } else if (diff > 0) {
      return 'You want to gain ${diff.toStringAsFixed(1)} kg';
    } else {
      return 'You want to lose ${(-diff).toStringAsFixed(1)} kg';
    }
  }

  /// Page 3: Summary
  Widget _buildSummaryPage() {
    // Calculate estimated calories
    double dailyCalories = 0;
    if (_weight != null &&
        _height != null &&
        _age != null &&
        _gender != null &&
        _selectedGoal != null) {
      final bmr = NutritionGoalModel.calculateBMR(
        weightKg: _weight!,
        heightCm: _height!,
        age: _age!,
        gender: _gender!,
      );
      final tdee = NutritionGoalModel.calculateTDEE(bmr);
      dailyCalories =
          NutritionGoalModel.calculateDailyCalories(tdee, _selectedGoal!);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Nutrition Plan',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D1B2A),
            ),
          ),
          const Gap(8),
          Text(
            "Here's your personalized daily nutrition target",
            style: TextStyle(
              fontSize: 15,
              color: AppColors.grey.shade600,
            ),
          ),
          const Gap(32),

          // Summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.blueGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blueLogo.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 48,
                ),
                const Gap(16),
                Text(
                  '${dailyCalories.round()}',
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'kkal / day',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                const Gap(24),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _selectedGoal?.displayName ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(24),

          // Daily breakdown
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Meal Breakdown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D1B2A),
                  ),
                ),
                const Gap(16),
                _buildMealBreakdownRow(
                    '🌅 Breakfast', '30%', (dailyCalories * 0.30).round()),
                const Gap(12),
                _buildMealBreakdownRow(
                    '☀️ Lunch', '40%', (dailyCalories * 0.40).round()),
                const Gap(12),
                _buildMealBreakdownRow(
                    '🌙 Dinner', '30%', (dailyCalories * 0.30).round()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealBreakdownRow(String meal, String percentage, int calories) {
    return Row(
      children: [
        Text(
          meal,
          style: const TextStyle(fontSize: 14),
        ),
        const Spacer(),
        Text(
          percentage,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.grey.shade600,
          ),
        ),
        const Gap(12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.blueLogo.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$calories kkal',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.blueLogo,
            ),
          ),
        ),
      ],
    );
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _selectedGoal != null;
      case 1:
        final target = double.tryParse(_targetWeightController.text);
        return target != null && target > 0;
      case 2:
        return true;
      default:
        return false;
    }
  }

  void _handleNext() async {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Save and proceed
      await _saveNutritionGoal();
    }
  }

  Future<void> _saveNutritionGoal() async {
    if (_weight == null ||
        _height == null ||
        _age == null ||
        _gender == null ||
        _selectedGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete your profile first')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final targetWeight =
        double.tryParse(_targetWeightController.text) ?? _weight!;
    final nutritionProvider =
        Provider.of<NutritionProvider>(context, listen: false);

    final success = await nutritionProvider.saveNutritionGoal(
      goalType: _selectedGoal!,
      targetWeight: targetWeight,
      weightKg: _weight!,
      heightCm: _height!,
      age: _age!,
      gender: _gender!,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      // Navigate to dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const NutritionDashboardScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(nutritionProvider.error ?? 'Failed to save goal')),
      );
    }
  }
}
