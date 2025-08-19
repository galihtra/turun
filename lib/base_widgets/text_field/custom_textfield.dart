import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:turun/resources/colors_app.dart';

// Extension for Email Validation
extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? textInputType;
  final int? maxLine;
  final FocusNode? focusNode;
  final FocusNode? nextNode;
  final TextInputAction? textInputAction;
  final bool isPhoneNumber;
  final bool isValidator;
  final String? validatorMessage;
  final Color? fillColor;
  final TextCapitalization capitalization;
  final bool isBorder;
  final TextAlign? textAlign;
  final bool isEnable;
  final bool obscureText;
  final TextStyle? textStyle;

  const CustomTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.textInputType,
    this.maxLine,
    this.focusNode,
    this.nextNode,
    this.textInputAction,
    this.isPhoneNumber = false,
    this.isValidator = false,
    this.validatorMessage,
    this.capitalization = TextCapitalization.none,
    this.fillColor,
    this.isBorder = false,
    this.textAlign,
    this.isEnable = true,
    this.obscureText = false,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLine ?? 1,
      textAlign: textAlign ?? TextAlign.start,
      textCapitalization: capitalization,
      enabled: isEnable,
      maxLength: isPhoneNumber ? 15 : null,
      keyboardType: textInputType ?? TextInputType.text,
      textInputAction: textInputAction ?? TextInputAction.next,
      onFieldSubmitted: (v) {
        FocusScope.of(context).requestFocus(nextNode);
      },
      inputFormatters: [
        if (isPhoneNumber)
          FilteringTextInputFormatter.digitsOnly
        else
          FilteringTextInputFormatter.singleLineFormatter
      ],
      validator: (input) {
        if (input!.isEmpty) {
          if (isValidator) {
            return validatorMessage ?? "This field is required.";
          }
        }
        if (isPhoneNumber && input.length != 10) {
          return 'Please enter a valid phone number.';
        }
        if (isValidator && hintText == "Email" && !input.isValidEmail()) {
          return 'Please enter a valid email address.';
        }
        return null;
      },
      obscureText: obscureText,
      style: textStyle ?? TextStyle(fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: hintText ?? '',
        filled: fillColor != null,
        fillColor: fillColor ?? Colors.transparent,
        contentPadding: EdgeInsets.symmetric(
          vertical: 16.0.h,
          horizontal: 18.w,
        ),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22.r),
          borderSide: BorderSide.none,
        ),
        counterText: '',
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22.r),
          borderSide: const BorderSide(color: AppColors.blueDark),
        ),
        errorStyle: TextStyle(height: 1.5.h),
        suffixIcon: obscureText
            ? IconButton(
                icon: Icon(obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () {
                  // Handle visibility toggle
                },
              )
            : null,
      ),
    );
  }
}
