import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:turun/data/model/running/run_session_model.dart';
import 'package:turun/resources/colors_app.dart';
import '../run_share_screen.dart';

class CompletionActionButtons extends StatelessWidget {
  final RunSession session;

  const CompletionActionButtons({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Share Run button
          _buildShareButton(context),
          const Gap(12),

          // View Leaderboard button (if conquered)
          if (session.territoryConquered) ...[
            _buildLeaderboardButton(context),
            const Gap(12),
          ],

          // Done button
          _buildDoneButton(context),
        ],
      ),
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RunShareScreen(
                distance: session.formattedDistance,
                pace: session.formattedPace,
                duration: session.formattedDuration,
                avgSpeed: session.formattedSpeed,
                calories: '${session.caloriesBurned} kcal',
                routePoints: session.routePoints,
                territoryConquered: session.territoryConquered,
                territoryName: session.territoryId.toString(),
                userAvatarUrl: session.userAvatarUrl,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.blueLogo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          shadowColor: Colors.black.withValues(alpha: 0.2),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.share_rounded, size: 20),
            Gap(10),
            Text(
              'Share Run',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.4),
              width: 2,
            ),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard_rounded, size: 20),
            Gap(8),
            Text(
              'See Leaderboard',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.15),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          elevation: 0,
        ),
        child: Text(
          session.territoryConquered ? 'Done' : 'Back to Map',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
