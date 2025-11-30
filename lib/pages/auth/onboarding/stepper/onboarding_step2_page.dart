import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:turun/base_widgets/button/gradient_button.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';

class OnboardingStep2Page extends StatefulWidget {
  final Function(Map<String, dynamic>) onNext;
  final VoidCallback onBack;
  final Map<String, dynamic>? initialData;

  const OnboardingStep2Page({
    super.key,
    required this.onNext,
    required this.onBack,
    this.initialData,
  });

  @override
  State<OnboardingStep2Page> createState() => _OnboardingStep2PageState();
}

class _OnboardingStep2PageState extends State<OnboardingStep2Page> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  
  String _selectedColor = '#0000FF'; // Default blue

  final List<Color> _colorOptions = [
    const Color(0xFFFF0000), // Red
    const Color(0xFFFF8A00), // Orange
    const Color(0xFFFFFF00), // Yellow
    const Color(0xFF00FF00), // Green
    const Color(0xFF0000FF), // Blue
    const Color(0xFF8B00FF), // Purple
    const Color(0xFFFF00FF), // Pink
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _weightController.text = widget.initialData!['weight']?.toString() ?? '';
      _heightController.text = widget.initialData!['height']?.toString() ?? '';
      _selectedColor = widget.initialData!['profile_color'] ?? '#0000FF';
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _handleNext() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onNext({
        'weight': double.tryParse(_weightController.text),
        'height': double.tryParse(_heightController.text),
        'profile_color': _selectedColor,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32.h),

            // Weight Field
            Text(
              'Weight',
              style: AppStyles.body1SemiBold.copyWith(
                color: AppColors.deepBlue,
              ),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '60 kg',
                filled: true,
                fillColor: AppColors.blueLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22.r),
                  borderSide: const BorderSide(color: AppColors.blueDark),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 16.h,
                  horizontal: 18.w,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Weight is required';
                }
                final weight = double.tryParse(value);
                if (weight == null || weight <= 0) {
                  return 'Please enter a valid weight';
                }
                return null;
              },
            ),

            SizedBox(height: 24.h),

            // Height Field
            Text(
              'Height',
              style: AppStyles.body1SemiBold.copyWith(
                color: AppColors.deepBlue,
              ),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '165 cm',
                filled: true,
                fillColor: AppColors.blueLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22.r),
                  borderSide: const BorderSide(color: AppColors.blueDark),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 16.h,
                  horizontal: 18.w,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Height is required';
                }
                final height = double.tryParse(value);
                if (height == null || height <= 0) {
                  return 'Please enter a valid height';
                }
                return null;
              },
            ),

            SizedBox(height: 24.h),

            // Territory Color
            Text(
              'Territory Color',
              style: AppStyles.body1SemiBold.copyWith(
                color: AppColors.deepBlue,
              ),
            ),
            SizedBox(height: 16.h),
            
            // Color Picker
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _colorOptions.map((color) {
                final colorHex = _colorToHex(color);
                final isSelected = _selectedColor == colorHex;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = colorHex;
                    });
                  },
                  child: Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: AppColors.deepBlue,
                              width: 3,
                            )
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 16.h),

            // Selected Color Display
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.blueLight,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _selectedColor,
                    style: AppStyles.body2Regular.copyWith(
                      color: AppColors.deepBlue,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40.h),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onBack,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      side: const BorderSide(color: AppColors.blueLogo),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.blueLogo,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 3,
                  child: GradientButton(
                    text: 'Next',
                    onTap: _handleNext,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}