// lib/pages/auth/forgot_password_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turun/data/services/auth_service.dart';
import 'package:turun/resources/styles_app.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/base_widgets/button/gradient_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _emailNode.dispose();
    super.dispose();
  }

  Future<void> _resetPassword(AuthService authService) async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await authService.resetPassword(_emailController.text);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email has been sent!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reset Password',
                style: AppStyles.body2Regular,
              ),
              SizedBox(height: 8.h),
              Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: AppStyles.body2Regular.copyWith(color: Colors.grey[600]),
              ),
              SizedBox(height: 24.h),
              TextFormField(
                controller: _emailController,
                focusNode: _emailNode,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),
              authService.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GradientButton(
                      text: 'Send Reset Link',
                      onTap: () => _resetPassword(authService),
                    ),
              if (authService.error != null) ...[
                SizedBox(height: 16.h),
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
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Back to Login',
                    style: AppStyles.body2Regular.copyWith(
                      color: AppColors.blueLogo,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}