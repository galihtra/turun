import 'package:flutter/material.dart';
import 'package:turun/resources/styles_app.dart';
import 'package:turun/resources/values_app.dart';

import '../../../base_widgets/button/custom_button.dart';
import '../../../base_widgets/text_field/custom_password_textfield.dart';
import '../../../base_widgets/text_field/custom_textfield.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({Key? key}) : super(key: key);

  @override
  SignUpWidgetState createState() => SignUpWidgetState();
}

class SignUpWidgetState extends State<SignUpWidget> {
  final TextEditingController _firstNameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  GlobalKey<FormState>? _formKey;

  final FocusNode _fNameFocus = FocusNode();
  final FocusNode _lNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  bool isEmailVerified = false;

  addUser() async {
    if (_formKey!.currentState!.validate()) {
      _formKey!.currentState!.save();
      isEmailVerified = true;
    } else {
      isEmailVerified = false;
    }
  }

  @override
  void initState() {
    super.initState();

    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s10),
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(
                    left: AppSizes.s15, right: AppSizes.s15),
                child: Row(
                  children: [
                    Expanded(
                        child: CustomTextField(
                      hintText: 'Name',
                      textInputType: TextInputType.name,
                      focusNode: _fNameFocus,
                      nextNode: _lNameFocus,
                      isPhoneNumber: false,
                      capitalization: TextCapitalization.words,
                      controller: _firstNameController,
                    )),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                    left: AppSizes.s15, right: AppSizes.s15, top: AppSizes.s10),
                child: CustomTextField(
                  hintText: 'Email',
                  focusNode: _emailFocus,
                  nextNode: _phoneFocus,
                  textInputType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                    left: AppSizes.s15, right: AppSizes.s15, top: AppSizes.s10),
                child: CustomPasswordTextField(
                  hintTxt: 'Password',
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  nextNode: _confirmPasswordFocus,
                  textInputAction: TextInputAction.next,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                    left: AppSizes.s15, right: AppSizes.s15, top: AppSizes.s10),
                child: CustomPasswordTextField(
                  hintTxt: 'Password Confirmation',
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocus,
                  textInputAction: TextInputAction.done,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(
              left: AppSizes.s20,
              right: AppSizes.s20,
              bottom: AppSizes.s20,
              top: AppSizes.s20),
          child: CustomButton(onTap: addUser, buttonText: 'Sign Up'),
        ),
        Center(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {},
              child: Text(
                'Skip for Now',
                style: AppStyles.label2SemiBold
              ),
            ),
            Icon(
              Icons.arrow_forward,
              size: 15,
              color: Theme.of(context).primaryColor,
            )
          ],
        )),
      ],
    );
  }
}
