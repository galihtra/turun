import 'dart:io' show Platform;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:turun/base_widgets/text/gradient_text.dart';
import 'package:turun/base_widgets/text_field/custom_password_textfield.dart';
import 'package:turun/data/services/auth_service.dart';
import 'package:turun/resources/assets_app.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';
import 'package:turun/base_widgets/button/gradient_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:turun/pages/auth/forgot_password_page.dart';
import '../../../base_widgets/text_field/custom_textfield.dart';
import '../../../app/app_dialog.dart';
import '../../../app/app_logger.dart';

class SignInWidget extends StatefulWidget {
  const SignInWidget({super.key});

  @override
  SignInWidgetState createState() => SignInWidgetState();
}

class SignInWidgetState extends State<SignInWidget> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

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
    _email.dispose();
    _password.dispose();
    _emailNode.dispose();
    _passNode.dispose();
    super.dispose();
  }

  Future<void> _login(AuthService authService) async {
    if (_formKey.currentState?.validate() ?? false) {
      // Unfocus keyboard
      FocusScope.of(context).unfocus();

      AppLogger.debug(LogLabel.auth, 'Login button pressed');
      
      final success = await authService.signInWithEmail(
        _email.text,
        _password.text,
      );

      if (!mounted) return;

      if (success) {
        AppDialog.toastSuccess('Signed in successfully!');
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

  Future<void> _signInWithApple(AuthService authService) async {
    // Unfocus keyboard
    FocusScope.of(context).unfocus();
    
    AppLogger.debug(LogLabel.auth, 'Apple sign in button pressed');
    await authService.signInWithApple();
  }

  void _navigateToForgotPassword() {
    final authService = context.read<AuthService>();
    authService.clearError();
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
    );
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: authService.isLoading ? null : _navigateToForgotPassword,
                    child: GradientText(
                      "Forgot Password?",
                      gradient: AppColors.blueGradient,
                      style: AppStyles.body3Regular,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                authService.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GradientButton(
                        text: 'Sign In',
                        onTap: () => _login(authService),
                      ),
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
                        'Or continue with',
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
                Center(
                  child: Column(
                    children: [
                      // Google button
                      Container(
                        width: double.infinity,
                        height: 50.h,
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        child: OutlinedButton(
                          onPressed: authService.isLoading ? null : () => _signInWithGoogle(authService),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFE0E0E0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                AppIcons.google,
                                width: 20.w,
                                height: 20.w,
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                'Sign in with Google',
                                style: AppStyles.body2Medium.copyWith(
                                  color: Colors.black87,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Apple button (iOS only)
                      if (Platform.isIOS) ...[
                        SizedBox(height: 12.h),
                        Container(
                          width: double.infinity,
                          height: 50.h,
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          child: SignInWithAppleButton(
                          onPressed: () {
                          if (!authService.isLoading) _signInWithApple(authService);
                          },
                          style: SignInWithAppleButtonStyle.black,
                            height: 50.h,
                            borderRadius: BorderRadius.circular(8.r),
                            text: 'Sign in with Apple',
                          ),
                        ),
                      ],
                    ],
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