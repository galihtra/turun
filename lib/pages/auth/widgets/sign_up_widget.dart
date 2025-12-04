import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:turun/base_widgets/text_field/custom_password_textfield.dart';
import 'package:turun/data/services/auth_service.dart';
import 'package:turun/resources/assets_app.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';
import 'package:turun/base_widgets/button/gradient_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../base_widgets/text_field/custom_textfield.dart';
import '../../../app/app_dialog.dart';
import '../../../app/app_logger.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({super.key});

  @override
  SignUpWidgetState createState() => SignUpWidgetState();
}

class SignUpWidgetState extends State<SignUpWidget> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  final _fullNameNode = FocusNode();
  final _emailNode = FocusNode();
  final _passNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authService = context.read<AuthService>();
        authService.clearError();
      }
    });
  }

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    _fullNameNode.dispose();
    _emailNode.dispose();
    _passNode.dispose();
    super.dispose();
  }

  Future<void> _signUp(AuthService authService) async {
    if (_formKey.currentState?.validate() ?? false) {
      // Unfocus keyboard
      FocusScope.of(context).unfocus();

      AppLogger.debug(LogLabel.auth, 'Sign up button pressed');

      final success = await authService.signUpWithEmail(
        _email.text,
        _password.text,
        _fullName.text,
      );

      if (!mounted) return;

      if (success) {
        AppDialog.toastSuccess('Success! Confirmation email sent');
        
        // Clear form setelah sukses
        _fullName.clear();
        _email.clear();
        _password.clear();
      } else if (authService.error != null) {
        AppDialog.toastError(authService.error!);
      }
    }
  }

  Future<void> _signInWithGoogle(AuthService authService) async {
    // Unfocus keyboard
    FocusScope.of(context).unfocus();
    
    AppLogger.debug(LogLabel.google, 'Google sign in button pressed');
    await authService.signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      child: Form(
        key: _formKey,
        child: Consumer<AuthService>(
          builder: (context, authService, _) {
            return ListView(
              children: [
                SizedBox(height: 6.h),
                CustomTextField(
                  controller: _fullName,
                  focusNode: _fullNameNode,
                  nextNode: _emailNode,
                  hintText: "Full Name",
                  textInputType: TextInputType.name,
                  isValidator: true,
                  validatorMessage: "Full name is required",
                  isEnable: !authService.isLoading,
                  textStyle: AppStyles.label2Regular,
                  fillColor: AppColors.blueLight,
                ),
                SizedBox(height: 14.h),
                CustomTextField(
                  controller: _email,
                  focusNode: _emailNode,
                  nextNode: _passNode,
                  hintText: "Email",
                  textInputType: TextInputType.emailAddress,
                  isValidator: true,
                  validatorMessage: "Email is required",
                  isEnable: !authService.isLoading,
                  textStyle: AppStyles.label2Regular,
                  fillColor: AppColors.blueLight,
                ),
                SizedBox(height: 14.h),
                CustomPasswordTextField(
                  controller: _password,
                  hintTxt: 'Password',
                  focusNode: _passNode,
                  textInputAction: TextInputAction.done,
                  isValidator: true,
                  validatorMessage: "Password is required",
                  textStyle: AppStyles.label2Regular,
                  fillColor: AppColors.blueLight,
                ),
                SizedBox(height: 30.h),
                authService.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GradientButton(
                        text: 'Sign Up',
                        onTap: () => _signUp(authService),
                      ),

                // Error display
                if (authService.error != null) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[600], size: 20.w),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            authService.error!,
                            style: AppStyles.body3Regular.copyWith(color: Colors.red[700]),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 18.w, color: Colors.red[600]),
                          onPressed: () => authService.clearError(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],
                
                SizedBox(height: 16.h),
                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        thickness: 1,
                        color: AppColors.whiteLight,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Text(
                        'Or register with',
                        style: AppStyles.body2Regular.copyWith(
                          color: AppColors.deepBlue,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        thickness: 1,
                        color: AppColors.whiteLight,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // Google button
                Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18.r),
                    onTap: authService.isLoading ? null : () => _signInWithGoogle(authService),
                    child: Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(18.r),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 8,
                            color: Color(0x11000000),
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: authService.isLoading
                          ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: const CircularProgressIndicator(strokeWidth: 2),
                            )
                          : SvgPicture.asset(
                              AppIcons.google,
                              width: 20.w,
                              height: 20.h,
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
              ],
            );
          },
        ),
      ),
    );
  }
}