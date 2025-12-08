import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:turun/base_widgets/text_field/custom_text_form_field.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';
import 'package:turun/resources/values_app.dart';

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

  // Color picker
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
      try {
        _selectedColor = Color(
          int.parse(data['profile_color'].toString().replaceAll('#', '0xFF')),
        );
      } catch (e) {
        _selectedColor = const Color(0xFF0000FF);
      }
    }
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color tempColor = _selectedColor;

        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.all(16.w),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.blueLogo,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.palette, color: Colors.white),
                SizedBox(width: 12.w),
                Text(
                  'Choose Territory Color',
                  style: AppStyles.body1SemiBold.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ======================================================================
                // Color Wheel Picker (HSV)
                // ======================================================================
                ColorPicker(
                  pickerColor: tempColor,
                  onColorChanged: (Color color) {
                    tempColor = color;
                  },
                  colorPickerWidth: 300.w,
                  pickerAreaHeightPercent: 0.7,
                  enableAlpha: false,
                  displayThumbColor: true,
                  paletteType: PaletteType.hueWheel,
                  labelTypes: const [],
                  pickerAreaBorderRadius: BorderRadius.circular(16.r),
                ),
                SizedBox(height: 24.h),
                // ======================================================================
                // Color Preview Card
                // ======================================================================
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: tempColor,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: tempColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.my_location,
                        size: 40.sp,
                        color: _getTextColorForBackground(tempColor),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Territory Preview',
                        style: AppStyles.body2SemiBold.copyWith(
                          color: _getTextColorForBackground(tempColor),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          _colorToHex(tempColor),
                          style: AppStyles.body3Regular.copyWith(
                            color: Colors.white,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppStyles.body2Medium.copyWith(
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedColor = tempColor;
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueLogo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 12.h,
                ),
              ),
              child: Text(
                'Select',
                style: AppStyles.body2SemiBold.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getTextColorForBackground(Color backgroundColor) {
    // Calculate luminance to determine if text should be white or black
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  void _handleNext() {
    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid) return;

    widget.onNext({
      'weight': double.tryParse(_weightController.text),
      'height': double.tryParse(_heightController.text),
      'profile_color': _colorToHex(_selectedColor),
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
            _buildColorPickerSection(),
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

  Widget _buildColorPickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Territory Color',
          style: AppStyles.body1SemiBold.copyWith(
            color: AppColors.deepBlue,
          ),
        ),
        SizedBox(height: 16.h),
        // ======================================================================
        // Color Display Card (Clickable)
        // ======================================================================
        GestureDetector(
          onTap: _showColorPickerDialog,
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.blueLight,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.blueLogo.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                // Color Preview Circle
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _selectedColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Color',
                        style: AppStyles.body3Regular.copyWith(
                          color: AppColors.deepBlue.withValues(alpha: 0.6),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _colorToHex(_selectedColor),
                        style: AppStyles.body1SemiBold.copyWith(
                          color: AppColors.deepBlue,
                          fontFamily: 'monospace',
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Tap to change',
                        style: AppStyles.body3Regular.copyWith(
                          color: AppColors.blueLogo,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.edit,
                  color: AppColors.blueLogo,
                  size: 24.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}