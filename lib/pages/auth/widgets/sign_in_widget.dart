import 'package:flutter/material.dart';
import 'package:turun/base_widgets/text/gradient_text.dart';
import 'package:turun/base_widgets/text_field/custom_password_textfield.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';
import 'package:turun/base_widgets/button/gradient_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../base_widgets/text_field/custom_textfield.dart';

class SignInWidget extends StatefulWidget {
  const SignInWidget({Key? key}) : super(key: key);

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
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailNode.dispose();
    _passNode.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: sambungkan ke logic auth
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signing in...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              validatorMessage: "Email is required.",
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
              textStyle: AppStyles.label2Regular,
              fillColor: AppColors.blueLight,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                // style: TextButton.styleFrom(padding: EdgeInsets.all(8.w)),
                // child: Text(
                //   'Forgot Password?',
                //   style: AppStyles.body2Regular
                //       .copyWith(color: Theme.of(context).primaryColor),
                // ),
                child: GradientText(
                  "Forgot Password?",
                  gradient: AppColors.blueGradient,
                  style: AppStyles.body3Regular,
                ),
              ),
            ),
            SizedBox(height: 6.h),
            GradientButton(
              text: 'Log In',
              onTap: _login,
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                const Expanded(
                    child: Divider(thickness: 1, color: Color(0xFFE8ECF2))),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child:
                      Text('Or continue with', style: AppStyles.body3Regular),
                ),
                const Expanded(
                    child: Divider(thickness: 1, color: Color(0xFFE8ECF2))),
              ],
            ),
            const SizedBox(height: 16),
            // Google button round
            Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(18.r),
                onTap: () {}, // TODO: Google sign-in
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
                  child: Text('G'),
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
