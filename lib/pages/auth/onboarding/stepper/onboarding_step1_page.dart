import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:turun/app/app_dialog.dart';
import 'package:turun/base_widgets/button/gradient_button.dart';
import 'package:turun/base_widgets/image/custom_image_profile.dart';
import 'package:turun/base_widgets/text_field/custom_text_form_field.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';
import 'package:turun/resources/values_app.dart';

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

  final ValueNotifier<String?> genderNotifier = ValueNotifier(null);
  final ValueNotifier<String?> birthDateNotifier = ValueNotifier(null);

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _usernameController.text = widget.initialData!['username'] ?? '';

      final initialGender = widget.initialData!['gender'];
      if (initialGender != null) {
        genderNotifier.value = initialGender;
      }

      if (widget.initialData!['birth_date'] != null) {
        _selectedDate = DateTime.parse(widget.initialData!['birth_date']);
        _birthDateController.text =
            DateFormat('dd MMMM yyyy').format(_selectedDate!);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _birthDateController.dispose();
    genderNotifier.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ??
          DateTime.now().subtract(const Duration(days: 365 * 20)),
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
        'gender': genderNotifier.value,
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
            // ======================================================================
            // Image Profile
            // ======================================================================
            Center(
              child: CustomImageProfile(
                title: "Add Image Profile",
                titleStyle: AppStyles.body1SemiBold.copyWith(
                  color: AppColors.deepBlue,
                ),
                size: 100,
                onTap: () {},
                borderColor: AppColors.blueDark,
                borderWidth: 2,
              ),
            ),
            AppGaps.kGap20,
            // ======================================================================
            // Username
            // ======================================================================
            CustomTextFormField(
              title: "Username",
              titleStyle: AppStyles.body1SemiBold.copyWith(
                color: AppColors.deepBlue,
              ),
              controller: _usernameController,
              hintText: 'Input your username',
              backgroundColor: AppColors.blueLight,
              borderColor: AppColors.blueDark,
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
            AppGaps.kGap20,
            // ======================================================================
            // Date of Birth
            // ======================================================================
            CustomTextFormField(
              title: "Date of Birth",
              titleStyle: AppStyles.body1SemiBold.copyWith(
                color: AppColors.deepBlue,
              ),
              controller: _birthDateController,
              suffixIcon: const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.blueDark,
              ),
              hintText: 'Input your birthday',
              backgroundColor: AppColors.blueLight,
              borderColor: AppColors.blueDark,
              onTap: _selectDate,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Date of birth is required';
                }
                return null;
              },
            ),
            AppGaps.kGap20,
            // ======================================================================
            // Gender
            // ======================================================================
            ValueListenableBuilder(
                valueListenable: genderNotifier,
                builder: (context, value, _) {
                  return CustomTextFormField(
                    title: "Gender",
                    titleStyle: AppStyles.body1SemiBold.copyWith(
                      color: AppColors.deepBlue,
                    ),
                    controller: TextEditingController(text: value ?? ''),
                    readOnly: true,
                    hintText: "Select your gender",
                    backgroundColor: AppColors.blueLight,
                    borderColor: AppColors.blueDark,
                    suffixIcon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.blueDark,
                    ),
                    onTap: () async {
                      final selected =
                          await AppBottomSheet.showCustomBottomSheet(
                        context,
                        children: [
                          _genderItem(
                            icon: Icons.male_rounded,
                            text: "Male",
                            color: Colors.blue.shade400,
                            onTap: () => Navigator.pop(context, "Male"),
                          ),
                          _genderItem(
                            icon: Icons.female_rounded,
                            text: "Female",
                            color: Colors.pink.shade400,
                            onTap: () => Navigator.pop(context, "Female"),
                          ),
                        ],
                      );
                      if (selected != null) {
                        genderNotifier.value = selected;
                      }
                    },
                    validator: (_) {
                      if (genderNotifier.value == null ||
                          genderNotifier.value!.isEmpty) {
                        return "Please select your gender";
                      }
                      return null;
                    },
                  );
                }),
            AppGaps.kGap30,
            // ======================================================================
            // Button Next
            // ======================================================================
            GradientButton(
              text: 'Next',
              onTap: _handleNext,
            ),
          ],
        ),
      ),
    );
  }

  Widget _genderItem({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: AppStyles.body1SemiBold.copyWith(
                color: AppColors.deepBlue,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
