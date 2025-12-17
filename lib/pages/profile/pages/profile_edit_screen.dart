import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:turun/app/app_dialog.dart';
import 'package:turun/app/app_logger.dart';
import 'package:turun/app/extensions.dart';
import 'package:turun/base_widgets/button/gradient_button.dart';
import 'package:turun/base_widgets/image/custom_image_profile.dart';
import 'package:turun/base_widgets/text_field/custom_text_form_field.dart';
import 'package:turun/data/providers/user/user_provider.dart';
import 'package:turun/pages/auth/onboarding/stepper/widgets/color_display_card.dart';
import 'package:turun/pages/auth/onboarding/stepper/widgets/color_picker_dialog.dart';
import 'package:turun/pages/auth/onboarding/stepper/widgets/gender_selection_item.dart';
import 'package:turun/pages/auth/onboarding/stepper/widgets/image_source_item.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';
import 'package:turun/resources/values_app.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  final ValueNotifier<String?> _genderNotifier = ValueNotifier(null);
  final ValueNotifier<DateTime?> _birthDateNotifier = ValueNotifier(null);
  final ValueNotifier<File?> _imageNotifier = ValueNotifier(null);
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier(false);

  final ImagePicker _picker = ImagePicker();

  Color _selectedColor = const Color(0xFF0000FF);
  String? _currentAvatarUrl;
  bool _isUsingExistingAvatar = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    if (user != null) {
      _usernameController.text = user.username ?? '';
      _fullNameController.text = user.fullName ?? '';
      _weightController.text = user.weight?.toString() ?? '';
      _heightController.text = user.height?.toString() ?? '';
      _currentAvatarUrl = user.avatarUrl;
      _genderNotifier.value = user.gender;

      if (user.birthDate != null) {
        _birthDateNotifier.value = user.birthDate;
        _birthDateController.text =
            DateFormat('dd MMMM yyyy').format(user.birthDate!);
      }

      if (user.profileColor != null) {
        _selectedColor =
            user.profileColor!.toColorOrNull() ?? const Color(0xFF0000FF);
      }

      AppLogger.info(LogLabel.provider, 'User data loaded for editing');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _birthDateController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _genderNotifier.dispose();
    _birthDateNotifier.dispose();
    _imageNotifier.dispose();
    _isSavingNotifier.dispose();
    super.dispose();
  }

  // ======================================================================
  // Image Picker Functions
  // ======================================================================
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
        if (_imageNotifier.value != null || !_isUsingExistingAvatar) ...[
          const SizedBox(height: 12),
          ImageSourceItem(
            icon: Icons.restore,
            text: "Use Current Avatar",
            color: Colors.blue,
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _imageNotifier.value = null;
                _isUsingExistingAvatar = true;
              });
              AppLogger.info(
                  LogLabel.provider, 'User restored current avatar');
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
                _isUsingExistingAvatar = false;
              });
            },
          ),
        ],
      ],
    );
  }

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
          _isUsingExistingAvatar = false;
        });
        AppLogger.info(LogLabel.provider, 'User selected new avatar from gallery');
      }
    } catch (e) {
      if (mounted) {
        AppDialog.toastError('Failed to pick image: $e');
      }
    }
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
          _isUsingExistingAvatar = false;
        });
        AppLogger.info(LogLabel.provider, 'User selected new avatar from camera');
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

  // ======================================================================
  // Save Profile
  // ======================================================================
  Future<void> _handleSave() async {
    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid) {
      AppDialog.toastError('Please fill all required fields correctly');
      return;
    }

    _isSavingNotifier.value = true;

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Prepare update data
      final Map<String, dynamic> updates = {
        'username': _usernameController.text.trim(),
        'full_name': _fullNameController.text.trim(),
        'birth_date': _birthDateNotifier.value?.toIso8601String().split('T')[0],
        'gender': _genderNotifier.value,
        'weight': double.tryParse(_weightController.text),
        'height': double.tryParse(_heightController.text),
        'profile_color': _selectedColor.toHex(),
      };

      AppLogger.info(LogLabel.provider, 'Updating profile with data: $updates');

      // Handle avatar upload if new image selected
      if (_imageNotifier.value != null && !_isUsingExistingAvatar) {
        final userId = userProvider.currentUser?.id;
        if (userId != null) {
          AppLogger.info(LogLabel.provider, 'Uploading new avatar...');
          final avatarUrl = await userProvider.uploadAvatar(
            _imageNotifier.value!,
            userId,
          );

          if (avatarUrl != null) {
            updates['avatar_url'] = avatarUrl;
            AppLogger.success(LogLabel.provider, 'Avatar uploaded successfully');
          } else {
            AppLogger.warning(LogLabel.provider, 'Avatar upload failed, continuing without update');
          }
        }
      }

      // Update profile
      final success = await userProvider.updateUserProfile(updates);

      if (mounted) {
        _isSavingNotifier.value = false;

        if (success) {
          AppDialog.toastSuccess('Profile updated successfully!');
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          AppDialog.toastError(
              userProvider.error ?? 'Failed to update profile');
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error(LogLabel.provider, 'Error saving profile', e, stackTrace);
      if (mounted) {
        _isSavingNotifier.value = false;
        AppDialog.toastError('An error occurred while saving');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.deepBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: AppStyles.title3SemiBold.copyWith(
            color: AppColors.deepBlue,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ======================================================================
              // Profile Image
              // ======================================================================
              Center(
                child: ValueListenableBuilder<File?>(
                  valueListenable: _imageNotifier,
                  builder: (context, imageFile, _) {
                    ImageProvider? imageProvider;

                    if (imageFile != null) {
                      imageProvider = FileImage(imageFile);
                    } else if (_isUsingExistingAvatar &&
                        _currentAvatarUrl != null &&
                        _currentAvatarUrl!.isNotEmpty) {
                      imageProvider = NetworkImage(_currentAvatarUrl!);
                    }

                    return CustomImageProfile(
                      title: "Change Profile Picture",
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
              ),
              AppGaps.kGap30,

              // ======================================================================
              // Full Name Field
              // ======================================================================
              CustomTextFormField(
                title: "Full Name",
                titleStyle: AppStyles.body1SemiBold.copyWith(
                  color: AppColors.deepBlue,
                ),
                controller: _fullNameController,
                hintText: 'Input your full name',
                backgroundColor: AppColors.blueLight,
                borderColor: AppColors.blueDark,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Full name is required';
                  }
                  if (value.length < 2) {
                    return 'Full name must be at least 2 characters';
                  }
                  return null;
                },
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
              // Gender Field
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
              AppGaps.kGap20,

              // ======================================================================
              // Weight Field
              // ======================================================================
              CustomTextFormField(
                title: "Weight",
                titleStyle:
                    AppStyles.body1SemiBold.copyWith(color: AppColors.deepBlue),
                controller: _weightController,
                hintText: 'Example 60 kg',
                backgroundColor: AppColors.blueLight,
                borderColor: AppColors.blueDark,
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
              // Height Field
              // ======================================================================
              CustomTextFormField(
                title: "Height",
                titleStyle:
                    AppStyles.body1SemiBold.copyWith(color: AppColors.deepBlue),
                controller: _heightController,
                hintText: 'Example 165 cm',
                backgroundColor: AppColors.blueLight,
                borderColor: AppColors.blueDark,
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
              // Save Button
              // ======================================================================
              ValueListenableBuilder<bool>(
                valueListenable: _isSavingNotifier,
                builder: (context, isSaving, _) {
                  return Opacity(
                    opacity: isSaving ? 0.5 : 1.0,
                    child: GradientButton(
                      text: isSaving ? 'Saving...' : 'Save Changes',
                      onTap: isSaving ? () {} : () => _handleSave(),
                    ),
                  );
                },
              ),
              AppGaps.kGap20,
            ],
          ),
        ),
      ),
    );
  }
}
