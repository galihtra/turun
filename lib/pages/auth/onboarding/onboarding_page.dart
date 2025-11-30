import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';

import '../../../data/providers/user/user_provider.dart';
import 'stepper/onboarding_step1_page.dart';
import 'stepper/onboarding_step2_page.dart';
import 'stepper/onboarding_step3_page.dart';

class OnboardingPage extends StatefulWidget {
  final VoidCallback? onComplete;
  const OnboardingPage({
    super.key,
    this.onComplete,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentStep = 0;
  final Map<String, dynamic> _onboardingData = {};
  bool _isLoading = false;

  void _handleStepData(Map<String, dynamic> data) {
    setState(() {
      _onboardingData.addAll(data);
    });
  }

  void _nextStep(Map<String, dynamic> data) {
    _handleStepData(data);
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _completeOnboarding(Map<String, dynamic> finalData) async {
    _handleStepData(finalData);

    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.completeOnboarding(_onboardingData);

    if (success && mounted) {
      // Navigation will be handled by AuthWrapper
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (widget.onComplete != null) {
        widget.onComplete!(); 
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userProvider.error ?? 'Failed to complete profile'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  Text(
                    'Complete Your Profile',
                    style: AppStyles.title1SemiBold.copyWith(
                      color: AppColors.deepBlue,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Step Indicator
                  Row(
                    children: [
                      _buildStepIndicator(1, 'About You', _currentStep >= 0),
                      _buildStepLine(_currentStep >= 1),
                      _buildStepIndicator(2, 'Your Specs', _currentStep >= 1),
                      _buildStepLine(_currentStep >= 2),
                      _buildStepIndicator(3, 'Interest', _currentStep >= 2),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : IndexedStack(
                      index: _currentStep,
                      children: [
                        OnboardingStep1Page(
                          onNext: _nextStep,
                          initialData: _onboardingData,
                        ),
                        OnboardingStep2Page(
                          onNext: _nextStep,
                          onBack: _previousStep,
                          initialData: _onboardingData,
                        ),
                        OnboardingStep3Page(
                          onComplete: _completeOnboarding,
                          onBack: _previousStep,
                          initialData: _onboardingData,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isActive ? AppColors.blueGradient : null,
            color: isActive ? null : Colors.grey.shade300,
          ),
          child: Center(
            child: Text(
              '0$step',
              style: AppStyles.body2SemiBold.copyWith(
                color: isActive ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: 60.w,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppStyles.body3Medium.copyWith(
              color: isActive ? AppColors.deepBlue : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2.h,
        margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 20.h),
        color: isActive ? AppColors.blueLogo : Colors.grey.shade300,
      ),
    );
  }
}
