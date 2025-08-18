import 'package:flutter/material.dart';
import 'package:turun/pages/auth/widgets/sign_in_widget.dart';
import 'package:turun/pages/auth/widgets/sign_up_widget.dart';
import 'package:turun/resources/assets_app.dart';
import 'package:turun/resources/styles_app.dart';
import 'package:turun/resources/values_app.dart';

class AuthPage extends StatefulWidget {
  final int initialPage;
  const AuthPage({Key? key, this.initialPage = 0}) : super(key: key);

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
          // Background running track
          Positioned.fill(
            child: Image.asset(
              AppImages.background,
              fit: BoxFit.fill,
            ),
          ),

          // White rounded sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.78,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    const SizedBox(height: 18),

                    // Logo + brand
                    Column(
                      children: [
                        Image.asset(AppImages.logo, height: 62, width: 62),
                        const SizedBox(height: 10),
                        Text(
                          'tuRun',
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Track, Unlocked, Run!',
                          style: AppStyles.body2Regular
                              .copyWith(color: Colors.black54),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Tabs
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24.0),
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
                              _AuthTab(
                                title: 'Sign In',
                                active: _currentIndex == 0,
                                onTap: () => _goTo(0),
                              ),
                              const SizedBox(width: 28),
                              _AuthTab(
                                title: 'SignUp',
                                active: _currentIndex == 1,
                                onTap: () => _goTo(1),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

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

class _AuthTab extends StatelessWidget {
  final String title;
  final bool active;
  final VoidCallback onTap;

  const _AuthTab({
    Key? key,
    required this.title,
    required this.active,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final underlineWidth = (title.length * 9).toDouble();
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: active
                ? AppStyles.body3SemiBold
                : AppStyles.body3Regular.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: active ? underlineWidth : 0,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
