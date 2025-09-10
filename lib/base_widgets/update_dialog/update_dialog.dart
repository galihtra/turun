import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../resources/assets_app.dart';
import '../../resources/colors_app.dart';
import '../../resources/styles_app.dart';
import '../../resources/values_app.dart'; 

class UpdateDialog extends StatelessWidget {
  const UpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      backgroundColor: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Lottie.asset(AppLotties.rocket,
                  fit: BoxFit.fitHeight, height: 200),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('About Update', style: AppStyles.label1Medium),
                    Text(
                      "V2.3.4",
                      style: AppStyles.body2Regular.copyWith(color: AppColors.red),
                    )
                  ],
                ),
                AppGaps.kGap10,
                Text(
                  '1. New Game for you aslkask;lask ;ak;la ;lasd;lad;laskd;laskd;lask;laskd ;ld;las ;las ;lask ;laskd ;alskda;lska;lkda;lskda;ls k;a as;lkd as;lkdas;kda;lkd;laskd;lasd;lasd;lasdk;alskd;',
                  textAlign: TextAlign.start,
                  style: AppStyles.body2Regular,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                      ),
                      child: const Text(
                        "Later",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    AppGaps.kGap10,
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                      ),
                      child: const Text("Update Now",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
