import 'package:flutter/material.dart';
import 'package:turun/pages/auth/widgets/auth_tab_widget.dart';
import 'package:turun/pages/auth/widgets/sign_in_widget.dart';
import 'package:turun/pages/auth/widgets/sign_up_widget.dart';
import 'package:turun/resources/assets_app.dart';
import 'package:turun/resources/styles_app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthPage extends StatefulWidget {
  final int initialPage;
  const AuthPage({super.key, this.initialPage = 0});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
  }

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Stack(
              children: [
                Image.asset(
                  AppImages.background,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.78,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36.r),
                  topRight: Radius.circular(36.r),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    SizedBox(height: 18.h),
                    Column(
                      children: [
                        Image.asset(
                          AppImages.logo,
                          height: 62.h,
                          width: 62.w,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'TuRun',
                          style: AppStyles.titleLogo,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Track, Unlocked, Run!',
                          style: AppStyles.body2Regular
                              .copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                    SizedBox(height: 22.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Stack(
                        children: [
                          // bottom divider
                          Positioned.fill(
                            bottom: 0,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: 1,
                                color: Colors.black12,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              AuthTab(
                                title: 'Sign In',
                                active: _currentIndex == 0,
                                onTap: () => _goTo(0),
                              ),
                              const SizedBox(width: 28),
                              AuthTab(
                                title: 'SignUp',
                                active: _currentIndex == 1,
                                onTap: () => _goTo(1),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // Pages
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const BouncingScrollPhysics(),
                        onPageChanged: (i) => setState(() {
                          _currentIndex = i;
                        }),
                        children: const [
                          SignInWidget(),
                          SignUpWidget(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
