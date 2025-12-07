import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../resources/colors_app.dart';
import '../../resources/styles_app.dart';
import '../../resources/values_app.dart';
import '../spacer/spacer.dart';

class CustomTextFormField extends StatelessWidget {
  final AutovalidateMode? validateMode;
  final String? hintText;
  final String? title;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextEditingController? controller;
  final bool obscureText;
  final String? Function(String? value)? validator;
  final String? errorText;
  final String? helperText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final void Function(String? value)? onSaved;
  final int maxLines;
  final int? maxLength;
  final double height;
  final bool readOnly;
  final Function()? onTap;
  final Function()? onEditingComplete;
  final double spacer;
  final TextCapitalization textCapitalization;
  final TextStyle? titleStyle;
  final Color? backgroundColor;
  final Color? borderColor;
  final TextInputAction? inputAction;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextFormField({
    super.key,
    this.hintText,
    this.title,
    this.controller,
    this.maxLength,
    this.obscureText = false,
    this.validator,
    this.readOnly = false,
    this.errorText,
    this.helperText,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.maxLines = 1,
    this.height = AppSizes.s61,
    this.onTap,
    this.spacer = AppSizes.s8,
    this.suffixIcon,
    this.textCapitalization = TextCapitalization.none,
    this.titleStyle,
    this.backgroundColor,
    this.borderColor,
    this.prefixIcon,
    this.validateMode,
    this.inputFormatters,
    this.onSaved,
    this.onEditingComplete,
    this.focusNode,
    this.inputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title ?? "",
            style: titleStyle ?? AppStyles.body2Regular,
          ),
          SpacerHeight(spacer),
        ],
        SizedBox(
          child: TextFormField(
            focusNode: focusNode,
            inputFormatters: inputFormatters,
            autovalidateMode: validateMode,
            maxLength: maxLength,
            textCapitalization: textCapitalization,
            cursorColor: AppColors.black,
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            onSaved: onSaved,
            onEditingComplete: onEditingComplete,
            textInputAction: inputAction,
            keyboardType: keyboardType,
            onChanged: onChanged,
            readOnly: readOnly,
            maxLines: maxLines,
            onTap: onTap,
            decoration: InputDecoration(
              hintText: hintText,
              fillColor: backgroundColor,
              filled: backgroundColor != null,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.all(AppPaddings.p14),
              // ----------------------------------------------
              // Border hilang saat idle
              // ----------------------------------------------
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.r20),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.r20),
                borderSide: BorderSide.none,
              ),
              // ----------------------------------------------
              // Border muncul saat fokus
              // ----------------------------------------------
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.r20),
                borderSide: const BorderSide(
                  color: AppColors.blueDark,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.r20),
                borderSide: const BorderSide(
                  color: AppColors.red,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.r12),
                borderSide: const BorderSide(
                  color: AppColors.red,
                  width: 1.5,
                ),
              ),
              helperText: helperText,
              errorText: errorText,
            ),
          ),
        ),
      ],
    );
  }
}
