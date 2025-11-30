import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:turun/base_widgets/button/gradient_button.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';

class OnboardingStep1Page extends StatefulWidget {
  final Function(Map<String, dynamic>) onNext;
  final Map<String, dynamic>? initialData;

  const OnboardingStep1Page({
    super.key,
    required this.onNext,
    this.initialData,
  });

  @override
  State<OnboardingStep1Page> createState() => _OnboardingStep1PageState();
}

class _OnboardingStep1PageState extends State<OnboardingStep1Page> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _birthDateController = TextEditingController();
  
  DateTime? _selectedDate;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _usernameController.text = widget.initialData!['username'] ?? '';
      _selectedGender = widget.initialData!['gender'];
      if (widget.initialData!['birth_date'] != null) {
        _selectedDate = DateTime.parse(widget.initialData!['birth_date']);
        _birthDateController.text = DateFormat('dd MMMM yyyy').format(_selectedDate!);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.blueLogo,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text = DateFormat('dd MMMM yyyy').format(picked);
      });
    }
  }

  void _handleNext() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onNext({
        'username': _usernameController.text.trim(),
        'birth_date': _selectedDate?.toIso8601String().split('T')[0],
        'gender': _selectedGender,
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
            
            // Avatar Section
            Center(
              child: Column(
                children: [
                  Text(
                    'Add Image Profile',
                    style: AppStyles.title3SemiBold.copyWith(
                      color: AppColors.deepBlue,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Stack(
                    children: [
                      Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.blueLight,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 60.w,
                          color: AppColors.blueLogo,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.blueGradient,
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18.w,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 40.h),

            // Username Field
            Text(
              'Username',
              style: AppStyles.body1SemiBold.copyWith(
                color: AppColors.deepBlue,
              ),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'John21',
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
                  return 'Username is required';
                }
                if (value.length < 3) {
                  return 'Username must be at least 3 characters';
                }
                return null;
              },
            ),

            SizedBox(height: 24.h),

            // Date of Birth Field
            Text(
              'Date of Birth',
              style: AppStyles.body1SemiBold.copyWith(
                color: AppColors.deepBlue,
              ),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _birthDateController,
              readOnly: true,
              onTap: _selectDate,
              decoration: InputDecoration(
                hintText: '10 November 2003',
                filled: true,
                fillColor: AppColors.blueLight,
                suffixIcon: const Icon(Icons.calendar_today, color: AppColors.blueLogo),
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
                  return 'Date of birth is required';
                }
                return null;
              },
            ),

            SizedBox(height: 24.h),

            // Gender Field
            Text(
              'Gender',
              style: AppStyles.body1SemiBold.copyWith(
                color: AppColors.deepBlue,
              ),
            ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(
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
              hint: const Text('Male'),
              items: ['Male', 'Female', 'Other'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select your gender';
                }
                return null;
              },
            ),

            SizedBox(height: 40.h),

            // Next Button
            GradientButton(
              text: 'Next',
              onTap: _handleNext,
            ),
          ],
        ),
      ),
    );
  }
}