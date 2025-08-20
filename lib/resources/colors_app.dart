import 'package:flutter/material.dart';

mixin AppColors {

  // Color Gradient
  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2979FF), Color(0xFF232EA5)],
  );

  static const Color blueLight = Color(0xFFF1F6FF);
  static const Color deepBlue = Color(0xFF142357);
  static const Color blueLogo = Color(0xFF2870F4);
  static const Color blueDark = Color(0xFF232EA5);
  static const Color whiteLight = Color(0xFFE5E5E5);
  static const Color unselected = Color(0xFFFBFBFB);
  static const Color titleExpansion = Color(0xFF52575D);
  static const Color shimmerBase = Color(0xFFF9F8F8);
  static const Color shimmerHighlight = Color(0xFFE7E5E5);
  static const Color redTulip = Color(0xFFFF8A8C);
  static const Color backgroundRed = Color(0xFFFFDFE1);
  static const Color greenLunatic = Color(0xFF6BFF9A);
  static const Color blueSkyBlue = Color(0xFFACD8FF);
  static const Color yellowBanana = Color(0xFFFFE08A);
  static const Color pinkGum = Color(0xFFFFAEE1);
  static const Color shinyNickel = Color(0xFFCED3D7);
  static const Color purpleMauve = Color(0xFFE1B4FF);
  static const Color blueChromis = Color(0xFF85C6FF);

  static const MaterialColor red = MaterialColor(
    0xFFCD202E, // The main color (value 500)
    <int, Color>{
      50: Color.fromARGB(255, 250, 233, 234), // #fae9ea, rgb(250, 233, 234)
      100: Color.fromARGB(255, 243, 201, 205), // #f3c9cd, rgb(243, 201, 205)
      200: Color.fromARGB(255, 234, 159, 165), // #ea9fa5, rgb(234, 159, 165)
      300: Color.fromARGB(255, 224, 115, 123), // #e0737b, rgb(224, 115, 123)
      400: Color.fromARGB(255, 214, 72, 84), // #d64854, rgb(214, 72, 84)
      500: Color.fromARGB(255, 205, 32, 46), // #cd202e, rgb(205, 32, 46)
      600: Color.fromARGB(255, 174, 27, 39), // #ae1b27, rgb(174, 27, 39)
      700: Color.fromARGB(255, 146, 23, 33), // #921721, rgb(146, 23, 33)
      800: Color.fromARGB(255, 117, 18, 26), // #75121a, rgb(117, 18, 26)
      900: Color.fromARGB(255, 92, 14, 21), // #5c0e15, rgb(92, 14, 21)
    },
  );

  static const MaterialColor blue = MaterialColor(
    0xFF1B4A73, // The main color (value 900)
    <int, Color>{
      50: Color.fromARGB(255, 236, 246, 255), // #ecf6ff, rgb(236, 246, 255)
      100: Color.fromARGB(255, 208, 233, 255), // #d0e9ff, rgb(208, 233, 255)
      200: Color.fromARGB(255, 172, 216, 255), // #acd8ff, rgb(172, 216, 255)
      300: Color.fromARGB(255, 133, 198, 255), // #85c6ff, rgb(133, 198, 255)
      400: Color.fromARGB(255, 96, 181, 255), // #60b5ff, rgb(96, 181, 255)
      500: Color.fromARGB(255, 61, 165, 255), // #3da5ff, rgb(61, 165, 255)
      600: Color.fromARGB(255, 52, 140, 217), // #348cd9, rgb(52, 140, 217)
      700: Color.fromARGB(255, 43, 117, 181), // #2b75b5, rgb(43, 117, 181)
      800: Color.fromARGB(255, 35, 94, 145), // #235e91, rgb(35, 94, 145)
      900: Color.fromARGB(255, 27, 74, 115), // #1b4a73, rgb(27, 74, 115)
    },
  );

  static const MaterialColor white = MaterialColor(
    0xFFFDFDFE, // The main color (value 500)
    <int, Color>{
      50: Color.fromARGB(255, 255, 255, 255), // #ffffff, rgb(255, 255, 255)
      100: Color.fromARGB(255, 255, 255, 255), // #ffffff, rgb(255, 255, 255)
      200: Color.fromARGB(255, 255, 255, 255), // #ffffff, rgb(255, 255, 255)
      300: Color.fromARGB(255, 254, 254, 254), // #fefefe, rgb(254, 254, 254)
      400: Color.fromARGB(255, 254, 254, 254), // #fefefe, rgb(254, 254, 254)
      500: Color.fromARGB(255, 254, 254, 254), // #fefefe, rgb(254, 254, 254)
      600: Color.fromARGB(255, 216, 216, 216), // #d8d8d8, rgb(216, 216, 216)
      700: Color.fromARGB(255, 180, 180, 180), // #b4b4b4, rgb(180, 180, 180)
      800: Color.fromARGB(255, 145, 145, 145), // #919191, rgb(145, 145, 145)
      900: Color.fromARGB(255, 114, 114, 114), // #727272, rgb(114, 114, 114)
    },
  );

  static const MaterialColor black = MaterialColor(
    0xFF333333, // The main color (value 500)
    <int, Color>{
      50: Color.fromARGB(255, 235, 235, 235), // #ebebeb, rgb(235, 235, 235)
      100: Color.fromARGB(255, 206, 206, 206), // #cecece, rgb(206, 206, 206)
      200: Color.fromARGB(255, 167, 167, 167), // #a7a7a7, rgb(167, 167, 167)
      300: Color.fromARGB(255, 126, 126, 126), // #7e7e7e, rgb(126, 126, 126)
      400: Color.fromARGB(255, 88, 88, 88), // #585858, rgb(88, 88, 88)
      500: Color.fromARGB(255, 51, 51, 51), // #333333, rgb(51, 51, 51)
      600: Color.fromARGB(255, 43, 43, 43), // #2b2b2b, rgb(43, 43, 43)
      700: Color.fromARGB(255, 36, 36, 36), // #242424, rgb(36, 36, 36)
      800: Color.fromARGB(255, 29, 29, 29), // #1d1d1d, rgb(29, 29, 29)
      900: Color.fromARGB(255, 23, 23, 23), // #171717, rgb(23, 23, 23)
    },
  );

  static const MaterialColor green = MaterialColor(
    0xFF1DB74E, // The main color (value 500)
    <int, Color>{
      50: Color.fromARGB(255, 232, 248, 237), // #e8f8ed, rgb(232, 248, 237)
      100: Color.fromARGB(255, 201, 238, 213), // #c9eed5, rgb(201, 238, 213)
      200: Color.fromARGB(255, 158, 224, 179), // #9ee0b3, rgb(158, 224, 179)
      300: Color.fromARGB(255, 113, 210, 143), // #71d28f, rgb(113, 210, 143)
      400: Color.fromARGB(255, 70, 196, 110), // #46c46e, rgb(70, 196, 110)
      500: Color.fromARGB(255, 29, 183, 78), // #1db74e, rgb(29, 183, 78)
      600: Color.fromARGB(255, 25, 156, 66), // #199c42, rgb(25, 156, 66)
      700: Color.fromARGB(255, 21, 130, 55), // #158237, rgb(21, 130, 55)
      800: Color.fromARGB(255, 17, 104, 44), // #11682c, rgb(17, 104, 44)
      900: Color.fromARGB(255, 13, 82, 35), // #0d5223, rgb(13, 82, 35)
    },
  );

  static const MaterialColor grey = MaterialColor(
    0xFFCED3D7, // The main color (value 500)
    <int, Color>{
      50: Color.fromARGB(255, 250, 251, 251), // #fafbfb, rgb(250, 251, 251)
      100: Color.fromARGB(255, 243, 244, 245), // #f3f4f5, rgb(243, 244, 245)
      200: Color.fromARGB(255, 234, 236, 238), // #eaecee, rgb(234, 236, 238)
      300: Color.fromARGB(255, 224, 227, 230), // #e0e3e6, rgb(224, 227, 230)
      400: Color.fromARGB(255, 215, 219, 222), // #d7dbde, rgb(215, 219, 222)
      500: Color.fromARGB(255, 206, 211, 215), // #ced3d7, rgb(206, 211, 215)
      600: Color.fromARGB(255, 175, 179, 183), // #afb3b7, rgb(175, 179, 183)
      700: Color.fromARGB(255, 146, 150, 153), // #929699, rgb(146, 150, 153)
      800: Color.fromARGB(255, 117, 120, 123), // #75787b, rgb(117, 120, 123)
      900: Color.fromARGB(255, 93, 95, 97), // #5d5f61, rgb(93, 95, 97)
    },
  );

  static const MaterialColor yellow = MaterialColor(
    0xFFFFB100, // The main color (value 500)
    <int, Color>{
      50: Color.fromARGB(255, 255, 247, 230), // #fff7e6, rgb(255, 247, 230)
      100: Color.fromARGB(255, 255, 236, 194), // #ffecc2, rgb(255, 236, 194)
      200: Color.fromARGB(255, 255, 221, 145), // #ffdd91, rgb(255, 221, 145)
      300: Color.fromARGB(255, 255, 206, 94), // #ffce5e, rgb(255, 206, 94)
      400: Color.fromARGB(255, 255, 191, 46), // #ffbf2e, rgb(255, 191, 46)
      500: Color.fromARGB(255, 255, 177, 0), // #ffb100, rgb(255, 177, 0)
      600: Color.fromARGB(255, 217, 150, 0), // #d99600, rgb(217, 150, 0)
      700: Color.fromARGB(255, 181, 126, 0), // #b57e00, rgb(181, 126, 0)
      800: Color.fromARGB(255, 145, 101, 0), // #916500, rgb(145, 101, 0)
      900: Color.fromARGB(255, 115, 80, 0), // #735000, rgb(115, 80, 0)
    },
  );

  static const MaterialColor purple = MaterialColor(
    0xFF6200EE, // The main color (value 500)
    <int, Color>{
      50: Color.fromARGB(255, 239, 230, 253), // #efe6fd, rgb(239, 230, 253)
      100: Color.fromARGB(255, 217, 194, 251), // #d9c2fb, rgb(217, 194, 251)
      200: Color.fromARGB(255, 187, 145, 248), // #bb91f8, rgb(187, 145, 248)
      300: Color.fromARGB(255, 156, 94, 244), // #9c5ef4, rgb(156, 94, 244)
      400: Color.fromARGB(255, 126, 46, 241), // #7e2ef1, rgb(126, 46, 241)
      500: Color.fromARGB(255, 98, 0, 238), // #6200ee, rgb(98, 0, 238)
      600: Color.fromARGB(255, 83, 0, 202), // #5300ca, rgb(83, 0, 202)
      700: Color.fromARGB(255, 70, 0, 169), // #4600a9, rgb(70, 0, 169)
      800: Color.fromARGB(255, 56, 0, 136), // #380088, rgb(56, 0, 136)
      900: Color.fromARGB(255, 44, 0, 107), // #2c006b, rgb(44, 0, 107)
    },
  );

  static const MaterialColor orange = MaterialColor(
    0xFFFD841F, // The main color (value 500)
    <int, Color>{
      50: Color.fromARGB(255, 255, 243, 233), // #fff3e9, rgb(255, 243, 233)
      100: Color.fromARGB(255, 255, 225, 201), // #ffe1c9, rgb(255, 225, 201)
      200: Color.fromARGB(255, 254, 202, 159), // #feca9f, rgb(254, 202, 159)
      300: Color.fromARGB(255, 254, 178, 114), // #feb272, rgb(254, 178, 114)
      400: Color.fromARGB(255, 253, 154, 71), // #fd9a47, rgb(253, 154, 71)
      500: Color.fromARGB(255, 253, 132, 31), // #fd841f, rgb(253, 132, 31)
      600: Color.fromARGB(255, 215, 112, 26), // #d7701a, rgb(215, 112, 26)
      700: Color.fromARGB(255, 180, 94, 22), // #b45e16, rgb(180, 94, 22)
      800: Color.fromARGB(255, 144, 75, 18), // #904b12, rgb(144, 75, 18)
      900: Color.fromARGB(255, 114, 59, 14), // #723b0e, rgb(114, 59, 14)
    },
  );

  static const MaterialColor pink = MaterialColor(
    0xFFFF71B3, // The main color (value 500)
    <int, Color>{
      50: Color.fromARGB(255, 255, 238, 246), // #ffeef6, rgb(255, 238, 246)
      100: Color.fromARGB(255, 255, 213, 233), // #ffd5e9, rgb(255, 213, 233)
      200: Color.fromARGB(255, 255, 181, 215), // #ffb5d7, rgb(255, 181, 215)
      300: Color.fromARGB(255, 255, 146, 196), // #ff92c4, rgb(255, 146, 196)
      400: Color.fromARGB(255, 255, 113, 179), // #ff71b3, rgb(255, 113, 179)
      500: Color.fromARGB(255, 255, 82, 162), // #ff52a2, rgb(255, 82, 162)
      600: Color.fromARGB(255, 217, 70, 138), // #d9468a, rgb(217, 70, 138)
      700: Color.fromARGB(255, 181, 58, 115), // #b53a73, rgb(181, 58, 115)
      800: Color.fromARGB(255, 145, 47, 92), // #912f5c, rgb(145, 47, 92)
      900: Color.fromARGB(255, 115, 37, 73), // #732549, rgb(115, 37, 73)
    },
  );

  static const MaterialColor teal = MaterialColor(
    0xFF008080, // The main color (value 500)
    <int, Color>{
      50: Color.fromARGB(255, 230, 242, 242), // #e6f2f2
      100: Color.fromARGB(255, 194, 225, 225), // #c2e1e1
      200: Color.fromARGB(255, 145, 200, 200), // #91c8c8
      300: Color.fromARGB(255, 94, 175, 175), // #5eafaf
      400: Color.fromARGB(255, 46, 151, 151), // #2e9797
      500: Color.fromARGB(255, 0, 128, 128), // #008080
      600: Color.fromARGB(255, 0, 109, 109), // #006d6d
      700: Color.fromARGB(255, 0, 91, 91), // #005b5b
      800: Color.fromARGB(255, 0, 73, 73), // #004949
      900: Color.fromARGB(255, 0, 58, 58), // #003a3a
    },
  );

  static const MaterialColor mint = MaterialColor(
    0xFFA3FFD6, // The main color (value 500)
    <int, Color>{
      50: Color.fromARGB(255, 246, 255, 251), // #f6fffb
      100: Color.fromARGB(255, 233, 255, 245), // #e9fff5
      200: Color.fromARGB(255, 215, 255, 237), // #d7ffed
      300: Color.fromARGB(255, 197, 255, 229), // #c5ffe5
      400: Color.fromARGB(255, 180, 255, 221), // #b4ffdd
      500: Color.fromARGB(255, 163, 255, 214), // #a3ffd6
      600: Color.fromARGB(255, 139, 217, 182), // #8bd9b6
      700: Color.fromARGB(255, 116, 181, 152), // #74b598
      800: Color.fromARGB(255, 93, 145, 122), // #5d917a
      900: Color.fromARGB(255, 73, 115, 96), // #497360
    },
  );

  static const MaterialColor sage = MaterialColor(
    0xFFAFBF8D, // The main color (value 500)
    <int, Color>{
      50: Color.fromARGB(255, 247, 249, 244), // #f7f9f4
      100: Color.fromARGB(255, 236, 240, 228), // #ecf0e4
      200: Color.fromARGB(255, 221, 227, 206), // #dde3ce
      300: Color.fromARGB(255, 205, 215, 183), // #cdd7b7
      400: Color.fromARGB(255, 189, 203, 162), // #bdcba2
      500: Color.fromARGB(255, 175, 191, 141), // #afbf8d
      600: Color.fromARGB(255, 149, 162, 120), // #95a278
      700: Color.fromARGB(255, 124, 136, 100), // #7c8864
      800: Color.fromARGB(255, 100, 109, 80), // #646d50
      900: Color.fromARGB(255, 79, 86, 63), // #4f563f
    },
  );

  static const MaterialColor beige = MaterialColor(
    0xFFF1D299, // The main color (value 500)
    <int, Color>{
      50: Color.fromARGB(255, 254, 251, 245), // #fefbf5
      100: Color.fromARGB(255, 252, 244, 231), // #fcf4e7
      200: Color.fromARGB(255, 249, 236, 211), // #f9ecd3
      300: Color.fromARGB(255, 246, 227, 191), // #f6e3bf
      400: Color.fromARGB(255, 244, 218, 171), // #f4daab
      500: Color.fromARGB(255, 241, 210, 153), // #f1d299
      600: Color.fromARGB(255, 205, 179, 130), // #cdb382
      700: Color.fromARGB(255, 171, 149, 109), // #ab956d
      800: Color.fromARGB(255, 137, 120, 87), // #897857
      900: Color.fromARGB(255, 108, 94, 69), // #6c5e45
    },
  );

  static const MaterialColor brown = MaterialColor(
    0xFF986A33, // The main color (value 500)
    <int, Color>{
      50: Color.fromARGB(255, 245, 240, 235), // #f5f0eb
      100: Color.fromARGB(255, 230, 219, 206), // #e6dbce
      200: Color.fromARGB(255, 211, 191, 167), // #d3bfa7
      300: Color.fromARGB(255, 190, 161, 126), // #bea17e
      400: Color.fromARGB(255, 171, 133, 88), // #ab8558
      500: Color.fromARGB(255, 152, 106, 51), // #986a33
      600: Color.fromARGB(255, 129, 90, 43), // #815a2b
      700: Color.fromARGB(255, 108, 75, 36), // #6c4b24
      800: Color.fromARGB(255, 87, 60, 29), // #573c1d
      900: Color.fromARGB(255, 68, 48, 23), // #443017
    },
  );

  static const MaterialColor peach = MaterialColor(
    0xFFEBB4AE, // The main color (value 500)
    <int, Color>{
      50: Color.fromARGB(255, 253, 246, 245), // #fdf6f5
      100: Color.fromARGB(255, 250, 233, 231), // #fae9e7
      200: Color.fromARGB(255, 246, 215, 212), // #f6d7d4
      300: Color.fromARGB(255, 242, 197, 193), // #f2c5c1
      400: Color.fromARGB(255, 239, 180, 174), // #efb4ae
      500: Color.fromARGB(255, 235, 163, 156), // #eba39c
      600: Color.fromARGB(255, 200, 139, 133), // #c88b85
      700: Color.fromARGB(255, 167, 116, 111), // #a7746f
      800: Color.fromARGB(255, 134, 93, 89), // #865d59
      900: Color.fromARGB(255, 106, 73, 70), // #6a4946
    },
  );

  static const MaterialColor maroon = MaterialColor(
    0xFFA72626, // The main color (value 500)
    <int, Color>{
      50: Color.fromARGB(255, 246, 233, 233), // #f6e9e9
      100: Color.fromARGB(255, 234, 203, 203), // #eacbcb
      200: Color.fromARGB(255, 217, 162, 162), // #d9a2a2
      300: Color.fromARGB(255, 200, 118, 118), // #c87676
      400: Color.fromARGB(255, 183, 77, 77), // #b74d4d
      500: Color.fromARGB(255, 167, 38, 38), // #a72626
      600: Color.fromARGB(255, 142, 32, 32), // #8e2020
      700: Color.fromARGB(255, 119, 27, 27), // #771b1b
      800: Color.fromARGB(255, 95, 22, 22), // #5f1616
      900: Color.fromARGB(255, 75, 17, 17), // #4b1111
    },
  );

  static const MaterialColor navy = MaterialColor(
    0xFF414796, // The main color (value 500)
    <int, Color>{
      50: Color.fromARGB(255, 236, 237, 245), // #ecedf5
      100: Color.fromARGB(255, 209, 211, 230), // #d1d3e6
      200: Color.fromARGB(255, 173, 176, 210), // #adb0d2
      300: Color.fromARGB(255, 135, 139, 189), // #878bbd
      400: Color.fromARGB(255, 99, 104, 169), // #6368a9
      500: Color.fromARGB(255, 65, 71, 150), // #414796
      600: Color.fromARGB(255, 55, 60, 128), // #373c80
      700: Color.fromARGB(255, 46, 50, 107), // #2e326b
      800: Color.fromARGB(255, 37, 40, 86), // #252856
      900: Color.fromARGB(255, 29, 32, 68), // #1d2044
    },
  );
}
