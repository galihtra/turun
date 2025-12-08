import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:turun/app/extensions.dart';
import 'package:turun/base_widgets/text_field/custom_text_form_field.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';
import 'package:turun/resources/values_app.dart';

import 'widgets/color_display_card.dart';
import 'widgets/color_picker_dialog.dart';
import 'widgets/onboarding_navigation_button.dart';

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

  Color _selectedColor = const Color(0xFF0000FF); // Blue default

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    if (widget.initialData == null) return;

    final data = widget.initialData!;

    _weightController.text = data['weight']?.toString() ?? '';
    _heightController.text = data['height']?.toString() ?? '';

    if (data['profile_color'] != null) {
      // ✅ Use extension to convert string to Color
      _selectedColor = data['profile_color'].toString().toColorOrNull() ??
          const Color(0xFF0000FF);
    }
  }

  void _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ColorPickerDialog(
          initialColor: _selectedColor,
          onColorSelected: (Color color) {
            setState(() {
              _selectedColor = color;
            });
          },
        );
      },
    );
  }

  void _handleNext() {
    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid) return;

    widget.onNext({
      'weight': double.tryParse(_weightController.text),
      'height': double.tryParse(_heightController.text),
      'profile_color': _selectedColor.toHex(),
    });
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
            AppGaps.kGap20,
            // ======================================================================
            // Weight
            // ======================================================================
            CustomTextFormField(
              title: "Weight",
              titleStyle:
                  AppStyles.body1SemiBold.copyWith(color: AppColors.deepBlue),
              controller: _weightController,
              hintText: 'Example 60 kg',
              backgroundColor: AppColors.blueLight,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Weight is required';
                }

                final weight = double.tryParse(value);
                if (weight == null || weight <= 0) {
                  return 'Please enter a valid weight';
                }

                if (weight < 20 || weight > 300) {
                  return 'Weight must be between 20-300 kg';
                }

                return null;
              },
            ),
            AppGaps.kGap20,
            // ======================================================================
            // Height
            // ======================================================================
            CustomTextFormField(
              title: "Height",
              titleStyle:
                  AppStyles.body1SemiBold.copyWith(color: AppColors.deepBlue),
              controller: _heightController,
              hintText: 'Example 165 cm',
              backgroundColor: AppColors.blueLight,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Height is required';
                }

                final height = double.tryParse(value);
                if (height == null || height <= 0) {
                  return 'Please enter a valid height';
                }

                if (height < 100 || height > 250) {
                  return 'Height must be between 100-250 cm';
                }

                return null;
              },
            ),
            AppGaps.kGap20,
            // ======================================================================
            // Territory Color Picker
            // ======================================================================
            ColorDisplayCard(
              selectedColor: _selectedColor,
              onTap: _showColorPickerDialog,
            ),
            AppGaps.kGap40,
            // ======================================================================
            // Navigation Button
            // ======================================================================
            OnboardingNavigationButton(
              onBack: widget.onBack,
              onNext: _handleNext,
              nextButtonText: 'Next',
            ),
          ],
        ),
      ),
    );
  }
}
