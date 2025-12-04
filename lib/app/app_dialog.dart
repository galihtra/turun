
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';

import '../base_widgets/spacer/spacer.dart';
import '../resources/assets_app.dart';
import '../resources/colors_app.dart';
import '../resources/styles_app.dart';
import '../resources/values_app.dart';
import 'navigator_keys.dart';

class AppDialog {
  //--singleton--
  static final AppDialog _instance = AppDialog._internal();
  AppDialog._internal();
  factory AppDialog() {
    return _instance;
  }

  static Future<void> toastError(String pesan,
      {ToastGravity gravity = ToastGravity.TOP,
      bool longDuration = true}) async {
    // await Fluttertoast.cancel();
    Fluttertoast.showToast(
        fontSize: 14,
        msg: pesan,
        backgroundColor: const Color(0xFFD22027),
        textColor: Colors.white,
        toastLength: longDuration ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
        gravity: gravity);
  }

  static Future<void> toastSuccess(String pesan,
      {ToastGravity gravity = ToastGravity.TOP,
      bool longDuration = true}) async {
    // await Fluttertoast.cancel();
    Fluttertoast.showToast(
        fontSize: 14,
        msg: pesan,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        toastLength: longDuration ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
        gravity: gravity);
  }

  static Future<void> toastInfo(String pesan,
      {ToastGravity gravity = ToastGravity.BOTTOM,
      bool longDuration = true}) async {
    // await Fluttertoast.cancel();
    Fluttertoast.showToast(
        fontSize: 14,
        msg: pesan,
        backgroundColor: Colors.grey.shade200,
        textColor: Colors.black,
        toastLength: longDuration ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
        gravity: gravity);
  }

  static Future<void> dialogLoading() async {
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.wave
      ..loadingStyle = EasyLoadingStyle.light
      ..textStyle = AppStyles.title2Regular
      ..userInteractions = false
      ..radius = 16
      ..dismissOnTap = false
      ..contentPadding =
          const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
    await EasyLoading.show();
    await Future.delayed(const Duration(milliseconds: 300));
  }

  static Future<void> dialogLoadingCircle() async {
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.ring
      ..maskType = EasyLoadingMaskType.black
      ..animationStyle = EasyLoadingAnimationStyle.scale
      ..loadingStyle = EasyLoadingStyle.light
      ..textStyle = AppStyles.title2Regular
      ..userInteractions = false
      ..radius = 100
      ..textPadding = EdgeInsets.zero
      ..contentPadding = const EdgeInsets.all(8)
      ..dismissOnTap = false;
    await EasyLoading.show();
    await Future.delayed(const Duration(milliseconds: 300));
  }

  static Future<void> dialogError(
      {required String message,
      Duration duration = const Duration(seconds: 3)}) async {
    EasyLoading.instance
      ..animationStyle = EasyLoadingAnimationStyle.scale
      ..backgroundColor = Colors.white
      ..loadingStyle = EasyLoadingStyle.light
      ..radius = 12
      ..textPadding = const EdgeInsets.symmetric(
        vertical: 6,
      )
      ..textStyle = AppStyles.title3Regular
      ..contentPadding = const EdgeInsets.all(12)
      ..errorWidget = const Icon(
        Icons.cancel,
        size: 40,
        color: AppColors.red,
      );

    await EasyLoading.showError(
      message,
      duration: duration,
      dismissOnTap: false,
    );
  }

  static Future<void> dialogSuccess(
      {required String message,
      Duration duration = const Duration(seconds: 3)}) async {
    EasyLoading.instance
      ..animationStyle = EasyLoadingAnimationStyle.scale
      ..backgroundColor = Colors.white
      ..loadingStyle = EasyLoadingStyle.light
      ..radius = 12
      ..textPadding = EdgeInsets.zero
      ..textStyle = AppStyles.title2Regular
      ..contentPadding = const EdgeInsets.all(12)
      ..successWidget = Image.asset(
        AppImages.check,
        width: 50,
      );
    await EasyLoading.showSuccess(
      message,
      duration: duration,
      dismissOnTap: true,
    );
  }

  static Future<void> dismissAllDialog() async {
    await EasyLoading.dismiss();
  }

  static void dismissAllToast() async {
    await Fluttertoast.cancel();
  }

  static void alertInfo({required String title, required String message}) =>
      showDialog(
        context: navigatorKey.currentState!.overlay!.context,
        builder: (context) {
          var width = MediaQuery.of(context).size.width * 0.7;
          return AlertDialog(
            insetPadding: EdgeInsets.zero,
            title: SizedBox(
              width: width,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppStyles.label1Medium,
              ),
            ),
            alignment: Alignment.center,
            content: SizedBox(
              width: width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(message, textAlign: TextAlign.center),
                  const SpacerHeight(24),
                  TextButton(
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.r12),
                        ),
                        backgroundColor: AppColors.red),
                    child: Text("Okay",
                        textAlign: TextAlign.center,
                        style: AppStyles.label2SemiBold
                            .copyWith(color: AppColors.white)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.r12)),
          );
        },
      );
}

class AppBottomSheet {
  static Future<void> showBottomSheetInfo(
    BuildContext ctx, {
    required String title,
    required String message,
  }) async {
    await showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.r24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          left: false,
          right: false,
          bottom: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: AppPaddings.p16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: AppSizes.s40,
                      height: AppSizes.s5,
                      margin: const EdgeInsets.symmetric(
                        vertical: AppPaddings.p11,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.black.shade200,
                        borderRadius: BorderRadius.circular(AppRadius.r10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppPaddings.p16,
                      left: AppPaddings.p24,
                      right: AppPaddings.p24,
                    ),
                    child: Text(
                      title,
                      style: AppStyles.title2Medium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppPaddings.p16,
                      left: AppPaddings.p24,
                      right: AppPaddings.p24,
                    ),
                    child: Text(
                      message,
                      style: AppStyles.body1Regular,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<bool> showConfirmBottomsheet(
    BuildContext ctx, {
    String? title,
    String? subtitle,
    bool isDismissable = true,
  }) async {
    return await showModalBottomSheet<bool?>(
          context: ctx,
          isDismissible: isDismissable,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.r24),
            ),
          ),
          builder: (context) {
            return SafeArea(
              top: false,
              left: false,
              right: false,
              bottom: true,
              child: SingleChildScrollView(
                child: PopScope(
                  canPop: isDismissable,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppPaddings.p16,
                        left: AppPaddings.p24,
                        right: AppPaddings.p24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: AppSizes.s35,
                            height: AppSizes.s5,
                            margin: const EdgeInsets.symmetric(
                              vertical: AppPaddings.p11,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.black.shade100,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r10),
                            ),
                          ),
                        ),
                        const SpacerHeight(AppSizes.s6),
                        if (title != null) ...[
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: AppStyles.label1Medium,
                          ),
                        ],
                        if (title != null && subtitle != null) const Gap(10),
                        if (subtitle != null) ...[
                          Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            style: AppStyles.label1Regular,
                          ),
                        ],
                        const Gap(16),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: AppColors.red.shade300),
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.r12,
                                      ),
                                    ),
                                    backgroundColor: AppColors.white),
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text(
                                  "Tidak",
                                  style: AppStyles.label2SemiBold.copyWith(
                                    color: AppColors.red,
                                  ),
                                ),
                              ),
                            ),
                            const SpacerWidth(AppSizes.s10),
                            Expanded(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.r12,
                                    ),
                                  ),
                                  backgroundColor: AppColors.red,
                                ),
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text(
                                  "Ya",
                                  style: AppStyles.label2SemiBold.copyWith(
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ) ??
        false;
  }

  static Future<T?> showCustomBottomSheet<T>(BuildContext ctx,
      {required List<Widget> children,
      bool protectKeyboardOverflow = false,
      bool isDismissable = true,
      bool canPop = true}) async {
    return await showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      isDismissible: isDismissable,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.r24),
        ),
      ),
      builder: (context) {
        double keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
        return PopScope(
          canPop: canPop,
          child: SafeArea(
            top: false,
            left: false,
            right: false,
            bottom: true,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: protectKeyboardOverflow
                      ? keyboardPadding + 16
                      : AppPaddings.p16,
                  left: AppPaddings.p24,
                  right: AppPaddings.p24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: AppSizes.s40,
                        height: AppSizes.s5,
                        margin: const EdgeInsets.symmetric(
                          vertical: AppPaddings.p11,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.black.shade200,
                          borderRadius: BorderRadius.circular(AppRadius.r10),
                        ),
                      ),
                    ),
                    ...children
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<T?> showCustomBottomSheetWithTitle<T>(BuildContext ctx,
      {required List<Widget> children,
      bool protectKeyboardOverflow = false,
      bool isDismissable = true,
      required String title,
      bool canPop = true}) async {
    return await showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      isDismissible: isDismissable,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.r24),
        ),
      ),
      builder: (context) {
        double keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
        return PopScope(
          canPop: canPop,
          child: SafeArea(
            top: false,
            left: false,
            right: false,
            bottom: true,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: protectKeyboardOverflow
                      ? keyboardPadding + 16
                      : AppPaddings.p16,
                  left: AppPaddings.p24,
                  right: AppPaddings.p24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: AppSizes.s40,
                        height: AppSizes.s5,
                        margin: const EdgeInsets.symmetric(
                          vertical: AppPaddings.p11,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.black.shade200,
                          borderRadius: BorderRadius.circular(AppRadius.r10),
                        ),
                      ),
                    ),
                    ...[
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppStyles.label1Medium,
                      ),
                    ],
                    const Divider(thickness: 1.2),
                    ...children
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
