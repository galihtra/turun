import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turun/base_widgets/button/custom_badge_button.dart';
import 'package:turun/resources/assets_app.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/values_app.dart';
import 'package:circular_seek_bar/circular_seek_bar.dart';

import '../../resources/styles_app.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseClient supabase = Supabase.instance.client;

  final ValueNotifier<double> _valueNotifier = ValueNotifier(0.2);

  double _progress = 90;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(
                        'TuRun',
                        style: AppStyles.titleLogo
                            .copyWith(fontSize: AppSizes.s26),
                      ),
                      AppGaps.kGap6,
                      Text(
                        'Track, Unlocked, Run!',
                        style: AppStyles.body2Regular
                            .copyWith(color: Colors.grey.shade500),
                      ),
                      AppGaps.kGap24,
                      Text(
                        "My Goals",
                        style: AppStyles.title1SemiBold.copyWith(
                          color: AppColors.deepBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppGaps.kGap8,
                      const CustomBadgeButton(
                        buttonText: "Goal Setting",
                        iconData: Icons.arrow_forward_ios,
                      ),
                      AppGaps.kGap24,
                      CircularSeekBar(
                        width: double.infinity,
                        height: 250,
                        barWidth: 25,
                        progress: _progress,
                        startAngle: 45,
                        sweepAngle: 270,
                        strokeCap: StrokeCap.butt,
                        outerThumbStrokeWidth: 30,
                        progressColor: Colors.blue,
                        trackColor: AppColors.blueSecondary,
                        animation: true,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Distance',
                                style: AppStyles.label3SemiBold.copyWith(
                                  color: AppColors.grey.shade500,
                                ),
                              ),
                              Text(
                                '0.2 Km',
                                style: AppStyles.title2SemiBold.copyWith(
                                  color: AppColors.blueDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '/20 Km',
                                style: AppStyles.title3Regular
                                    .copyWith(color: AppColors.blueDark),
                              ),
                              AppGaps.kGap10,
                              Text(
                                'Area',
                                style: AppStyles.label3SemiBold.copyWith(
                                  color: AppColors.grey.shade500,
                                ),
                              ),
                              Text(
                                '0.5 Km²',
                                style: AppStyles.title2SemiBold.copyWith(
                                  color: AppColors.blueDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '/2 Km²',
                                style: AppStyles.label3Regular
                                    .copyWith(color: AppColors.blueDark),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Today",
                                    style: AppStyles.title1SemiBold.copyWith(
                                      color: AppColors.deepBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const CustomBadgeButton(
                                    buttonText: "Detail",
                                    iconData: Icons.arrow_forward_ios,
                                  ),
                                ],
                              ),
                              AppGaps.kGap16,
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    AppIcons.drinkWater,
                                    width: 18,
                                    height: 18,
                                  ),
                                  AppGaps.kGap8,
                                  Text(
                                    "Drink Water",
                                    style: AppStyles.label1SemiBold.copyWith(
                                      color: AppColors.deepBlue,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              AppGaps.kGap8,
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: LinearProgressIndicator(
                                  value: 100 / 1000,
                                  color: AppColors.cyan,
                                  backgroundColor:
                                      AppColors.cyanLight.withOpacity(0.2),
                                  minHeight: 8,
                                ),
                              ),
                              AppGaps.kGap6,
                              Text(
                                "100ml/1000ml",
                                style: AppStyles.body2Regular
                                    .copyWith(color: AppColors.cyan),
                              ),
                              AppGaps.kGap16,
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    AppIcons.steps,
                                    width: 18,
                                    height: 18,
                                  ),
                                  AppGaps.kGap8,
                                  Text(
                                    "Steps",
                                    style: AppStyles.label1SemiBold.copyWith(
                                      color: AppColors.deepBlue,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              AppGaps.kGap8,
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppDimens.r30,
                                ),
                                child: LinearProgressIndicator(
                                  value: 1000 / 3500, // 1000 steps / 3500 steps
                                  color: AppColors.green,
                                  backgroundColor:
                                      AppColors.green.withOpacity(0.2),
                                  minHeight:
                                      8, 
                              ),
                                ),
                              AppGaps.kGap6,
                              Text(
                                "1000/3500",
                                    style: AppStyles.body2Regular.copyWith(
                                      color: AppColors.green,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
