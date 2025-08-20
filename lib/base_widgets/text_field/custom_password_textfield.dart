import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:turun/resources/colors_app.dart';

class CustomPasswordTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintTxt;
  final FocusNode? focusNode;
  final FocusNode? nextNode;
  final TextInputAction? textInputAction;
  final bool isValidator;
  final String? validatorMessage;
  final TextStyle? textStyle;
  final Color? fillColor;

  const CustomPasswordTextField({
    Key? key,
    this.controller,
    this.hintTxt,
    this.focusNode,
    this.nextNode,
    this.textInputAction,
    this.isValidator = false,
    this.validatorMessage,
    this.fillColor,
    this.textStyle,
  }) : super(key: key);

  @override
  CustomPasswordTextFieldState createState() => CustomPasswordTextFieldState();
}

class CustomPasswordTextFieldState extends State<CustomPasswordTextField> {
  bool _obscureText = true;

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Theme.of(context).primaryColor,
      controller: widget.controller,
      obscureText: _obscureText,
      focusNode: widget.focusNode,
      textInputAction: widget.textInputAction ?? TextInputAction.next,
      onFieldSubmitted: (v) {
        setState(() {
          widget.textInputAction == TextInputAction.done
              ? FocusScope.of(context).consumeKeyboardToken()
              : FocusScope.of(context).requestFocus(widget.nextNode);
        });
      },
      validator: (input) {
        if (input!.isEmpty) {
          if (widget.isValidator) {
            return widget.validatorMessage ?? "This field is required.";
          }
        }
        return null;
      },
      style: widget.textStyle ?? TextStyle(fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: widget.hintTxt ?? '',
        contentPadding:
            EdgeInsets.symmetric(vertical: 16.h, horizontal: 18.w),
        isDense: true,
        filled: true,
        fillColor: widget.fillColor,
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.blueDark),
          borderRadius: BorderRadius.circular(22.r),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(22.r),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: _toggle,
        ),
      ),
    );
  }
}
