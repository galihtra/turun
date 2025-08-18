import 'package:flutter/material.dart';
import 'package:turun/base_widgets/button/custom_button.dart';
import 'package:turun/base_widgets/text_field/custom_password_textfield.dart';
import 'package:turun/base_widgets/text_field/custom_textfield.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';
import 'package:turun/resources/values_app.dart';

class SignInWidget extends StatefulWidget {
  const SignInWidget({Key? key}) : super(key: key);

  @override
  SignInWidgetState createState() => SignInWidgetState();
}

class SignInWidgetState extends State<SignInWidget> {
  TextEditingController? _emailController;
  TextEditingController? _passwordController;
  GlobalKey<FormState>? _formKeyLogin;

  @override
  void initState() {
    super.initState();
    _formKeyLogin = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController!.dispose();
    _passwordController!.dispose();
    super.dispose();
  }

  final FocusNode _emailNode = FocusNode();
  final FocusNode _passNode = FocusNode();

  void loginUser() async {
    if (_formKeyLogin!.currentState!.validate()) {
      _formKeyLogin!.currentState!.save();

      String email = _emailController!.text.trim();
      String password = _passwordController!.text.trim();

      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Email'),
          backgroundColor: Colors.red,
        ));
      } else if (password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Password'),
          backgroundColor: Colors.red,
        ));
      } else {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s15),
      child: Form(
        key: _formKeyLogin,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.s10),
          children: [
            Container(
                margin: const EdgeInsets.only(bottom: AppSizes.s10),
                child: CustomTextField(
                  hintText: 'Email',
                  focusNode: _emailNode,
                  nextNode: _passNode,
                  textInputType: TextInputType.emailAddress,
                  controller: _emailController,
                )),
            Container(
                margin: const EdgeInsets.only(bottom: AppSizes.s15),
                child: CustomPasswordTextField(
                  hintTxt: 'Password',
                  textInputAction: TextInputAction.done,
                  focusNode: _passNode,
                  controller: _passwordController,
                )),
            Container(
              margin: const EdgeInsets.only(right: AppSizes.s10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        checkColor: AppColors.white,
                        activeColor: Theme.of(context).primaryColor,
                        value: false,
                        onChanged: (val) {},
                      ),
                      Text(
                        'Remember',
                        style: AppStyles.body2Regular
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {},
                    child: Text(
                      'Forgot Password',
                      style: AppStyles.body2Regular,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 20, top: 30),
              child: CustomButton(onTap: loginUser, buttonText: 'Sign In'),
            ),
            const SizedBox(width: AppSizes.s15),
            const SizedBox(width: AppSizes.s15),
            Center(
              child: Text(
                'OR',
                style: AppStyles.body2Regular,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.only(
                    left: AppSizes.s50, right: AppSizes.s50, top: AppSizes.s10),
                width: double.infinity,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child:
                    Text('Continue as Guest', style: AppStyles.title2Regular),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
