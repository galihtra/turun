// lib/pages/auth/widgets/sign_in_widget.dart
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
    // Clear error ketika widget di-init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      authService.clearError();
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
      final success = await authService.signInWithEmail(
        _email.text,
        _password.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed in successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _signInWithGoogle(AuthService authService) async {
    final success = await authService.signInWithGoogle();
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signed in with Google successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _navigateToForgotPassword() {
    // Clear error sebelum navigasi
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.clearError();
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            SizedBox(height: 6.h),
            CustomTextField(
              controller: _email,
              focusNode: _emailNode,
              hintText: "Email",
              textInputType: TextInputType.emailAddress,
              isValidator: true,
              validatorMessage: "Email is required",
              obscureText: false,
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
                onPressed: _navigateToForgotPassword,
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
              child: InkWell(
                borderRadius: BorderRadius.circular(18.r),
                onTap: () => _signInWithGoogle(authService),
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
                  child: SvgPicture.asset(
                    AppIcons.google,
                    width: 20.w,
                    height: 20.w,
                  ),
                ),
              ),
            ),
            SizedBox(height: 14.h),
          ],
        ),
      ),
    );
  }
}