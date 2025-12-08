import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turun/app/app_dialog.dart';
import 'package:turun/app/app_logger.dart';
import 'package:turun/base_widgets/button/gradient_button.dart';
import 'package:turun/base_widgets/image/custom_image_profile.dart';
import 'package:turun/base_widgets/text_field/custom_text_form_field.dart';
import 'package:turun/pages/auth/onboarding/stepper/widgets/image_source_item.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';
import 'package:turun/resources/values_app.dart';

import 'widgets/gender_selection_item.dart';

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

  final ValueNotifier<String?> _genderNotifier = ValueNotifier(null);
  final ValueNotifier<DateTime?> _birthDateNotifier = ValueNotifier(null);
  final ValueNotifier<File?> _imageNotifier = ValueNotifier(null);
  final ValueNotifier<String?> _imageErrorNotifier = ValueNotifier(null);

  final ImagePicker _picker = ImagePicker();

  String? _googleAvatarUrl;
  bool _isUsingGoogleAvatar =
      true; // Track if using Google avatar or new upload

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadGoogleAvatar();
  }

  void _loadInitialData() {
    if (widget.initialData != null) {
      _usernameController.text = widget.initialData!['username'] ?? '';

      final initialGender = widget.initialData!['gender'];
      if (initialGender != null) {
        _genderNotifier.value = initialGender;
      }

      if (widget.initialData!['birth_date'] != null) {
        _birthDateNotifier.value =
            DateTime.parse(widget.initialData!['birth_date']);
        _birthDateController.text =
            DateFormat('dd MMMM yyyy').format(_birthDateNotifier.value!);
      }
    }
  }

  Future<void> _loadGoogleAvatar() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final avatarUrl = user.userMetadata?['avatar_url'] as String?;

        if (avatarUrl != null && avatarUrl.isNotEmpty) {
          setState(() {
            _googleAvatarUrl = avatarUrl;
            _isUsingGoogleAvatar = true;
          });
          AppLogger.error(
              LogLabel.supabase, 'Google avatar loaded: $avatarUrl');
        }
      }
    } catch (e) {
      AppLogger.error(LogLabel.supabase, 'Failed to load Google avatar');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _birthDateController.dispose();
    _genderNotifier.dispose();
    _birthDateNotifier.dispose();
    _imageNotifier.dispose();
    _imageErrorNotifier.dispose();
    super.dispose();
  }

  // ======================================================================
  // Image Picker Functions
  // ======================================================================
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageNotifier.value = File(pickedFile.path);
          _imageErrorNotifier.value = null;
          _isUsingGoogleAvatar = false; // ✅ User changed avatar
        });
        AppLogger.info(
            LogLabel.supabase, 'User selected new avatar from gallery');
      }
    } catch (e) {
      if (mounted) {
        AppDialog.toastError('Failed to pick image: $e');
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    await AppBottomSheet.showCustomBottomSheet(
      context,
      children: [
        ImageSourceItem(
          icon: Icons.camera_alt,
          text: "Camera",
          onTap: () async {
            Navigator.pop(context);
            await _pickImageFromCamera();
          },
        ),
        const SizedBox(height: 12),
        ImageSourceItem(
          icon: Icons.photo_library,
          text: "Gallery",
          onTap: () async {
            Navigator.pop(context);
            await _pickImage();
          },
        ),
        // ✅ Show "Use Google Avatar" option if available
        if (_googleAvatarUrl != null && !_isUsingGoogleAvatar) ...[
          const SizedBox(height: 12),
          ImageSourceItem(
            icon: Icons.account_circle,
            text: "Use Google Avatar",
            color: Colors.blue,
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _imageNotifier.value = null;
                _isUsingGoogleAvatar = true;
              });
              AppLogger.info(
                  LogLabel.supabase, 'User switched back to Google avatar');
            },
          ),
        ],
        if (_imageNotifier.value != null) ...[
          const SizedBox(height: 12),
          ImageSourceItem(
            icon: Icons.delete,
            text: "Remove Photo",
            color: Colors.red,
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _imageNotifier.value = null;
                _imageErrorNotifier.value = null;
                // If had Google avatar, revert to it
                if (_googleAvatarUrl != null) {
                  _isUsingGoogleAvatar = true;
                }
              });
            },
          ),
        ],
      ],
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageNotifier.value = File(pickedFile.path);
          _imageErrorNotifier.value = null;
          _isUsingGoogleAvatar = false; // ✅ User changed avatar
        });
        AppLogger.info(
            LogLabel.supabase, 'User selected new avatar from camera');
      }
    } catch (e) {
      if (mounted) {
        AppDialog.toastError('Failed to take photo: $e');
      }
    }
  }

  // ======================================================================
  // Date Picker
  // ======================================================================
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDateNotifier.value ??
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
      _birthDateNotifier.value = picked;
      _birthDateController.text = DateFormat('dd MMMM yyyy').format(picked);
    }
  }

  // ======================================================================
  // Validation & Submit
  // ======================================================================
  bool _validateImage() {
    if (_isUsingGoogleAvatar && _googleAvatarUrl != null) {
      _imageErrorNotifier.value = null;
      return true;
    }

    if (_imageNotifier.value != null) {
      _imageErrorNotifier.value = null;
      return true;
    }

    _imageErrorNotifier.value = 'Please select a profile image';
    return false;
  }

  void _handleNext() {
    final isImageValid = _validateImage();
    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isImageValid || !isFormValid) {
      if (!isImageValid) {
        AppDialog.toastError('Please select a profile image');
      }
      return;
    }

    AppLogger.warning(LogLabel.supabase, "'STEP 1 DATA'");

    final data = {
      'username': _usernameController.text.trim(),
      'birth_date': _birthDateNotifier.value?.toIso8601String().split('T')[0],
      'gender': _genderNotifier.value,
      // ✅ Pass metadata about avatar
      '_avatar_source': _isUsingGoogleAvatar ? 'google' : 'upload',
      if (_isUsingGoogleAvatar && _googleAvatarUrl != null)
        '_google_avatar_url': _googleAvatarUrl, // Temporary field for next step
      if (!_isUsingGoogleAvatar && _imageNotifier.value != null)
        '_avatar_file_path':
            _imageNotifier.value!.path, // Temporary field for upload
    };

    AppLogger.success(LogLabel.supabase, "Step 1 Complete");

    widget.onNext(data);
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
            // Image Profile dengan ValueListenableBuilder
            // ======================================================================
            Center(
              child: Column(
                children: [
                  ValueListenableBuilder<File?>(
                    valueListenable: _imageNotifier,
                    builder: (context, imageFile, _) {
                      // ✅ Show Google avatar or uploaded image
                      ImageProvider? imageProvider;

                      if (imageFile != null) {
                        // User uploaded new image
                        imageProvider = FileImage(imageFile);
                      } else if (_isUsingGoogleAvatar &&
                          _googleAvatarUrl != null) {
                        // Using Google avatar
                        imageProvider = NetworkImage(_googleAvatarUrl!);
                      }

                      return CustomImageProfile(
                        title: imageProvider == null
                            ? "Add Image Profile"
                            : _isUsingGoogleAvatar
                                ? "Google Avatar"
                                : "Custom Avatar",
                        titleStyle: AppStyles.body1SemiBold.copyWith(
                          color: AppColors.deepBlue,
                        ),
                        size: 100,
                        image: imageProvider,
                        onTap: _showImageSourceDialog,
                        borderColor: AppColors.blueDark,
                        borderWidth: 2,
                      );
                    },
                  ),
                  // Error text untuk image
                  ValueListenableBuilder<String?>(
                    valueListenable: _imageErrorNotifier,
                    builder: (context, errorText, _) {
                      if (errorText == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          errorText,
                          style: AppStyles.body3Regular.copyWith(
                            color: AppColors.red,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            AppGaps.kGap20,
            // ======================================================================
            // Username Field
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
              textCapitalization: TextCapitalization.none,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Username is required';
                }
                if (value.length < 3) {
                  return 'Username must be at least 3 characters';
                }
                if (value.length > 20) {
                  return 'Username must not exceed 20 characters';
                }
                if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                  return 'Username can only contain letters, numbers, and underscore';
                }
                return null;
              },
            ),
            AppGaps.kGap20,
            // ======================================================================
            // Date of Birth Field
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
              readOnly: true,
              onTap: _selectDate,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Date of birth is required';
                }
                if (_birthDateNotifier.value != null) {
                  final age = DateTime.now()
                          .difference(_birthDateNotifier.value!)
                          .inDays ~/
                      365;
                  if (age < 13) {
                    return 'You must be at least 13 years old';
                  }
                }
                return null;
              },
            ),
            AppGaps.kGap20,
            // ======================================================================
            // Gender Field dengan ValueListenableBuilder
            // ======================================================================
            ValueListenableBuilder<String?>(
              valueListenable: _genderNotifier,
              builder: (context, genderValue, _) {
                return CustomTextFormField(
                  title: "Gender",
                  titleStyle: AppStyles.body1SemiBold.copyWith(
                    color: AppColors.deepBlue,
                  ),
                  controller: TextEditingController(text: genderValue ?? ''),
                  readOnly: true,
                  hintText: "Select your gender",
                  backgroundColor: AppColors.blueLight,
                  borderColor: AppColors.blueDark,
                  suffixIcon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.blueDark,
                  ),
                  onTap: () async {
                    final selected = await AppBottomSheet.showCustomBottomSheet(
                      context,
                      children: [
                        GenderSelectionItem(
                          icon: Icons.male_rounded,
                          text: "Male",
                          color: Colors.blue.shade400,
                          onTap: () => Navigator.pop(context, "Male"),
                        ),
                        const SizedBox(height: 12),
                        GenderSelectionItem(
                          icon: Icons.female_rounded,
                          text: "Female",
                          color: Colors.pink.shade400,
                          onTap: () => Navigator.pop(context, "Female"),
                        ),
                      ],
                    );
                    if (selected != null) {
                      _genderNotifier.value = selected;
                    }
                  },
                  validator: (_) {
                    if (genderValue == null || genderValue.isEmpty) {
                      return "Please select your gender";
                    }
                    return null;
                  },
                );
              },
            ),
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
}
