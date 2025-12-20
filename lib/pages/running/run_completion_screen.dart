import 'package:flutter/material.dart';
import 'package:turun/data/model/running/run_session_model.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:gap/gap.dart';
import 'run_share_screen.dart';

class RunCompletionScreen extends StatefulWidget {
  final RunSession session;

  const RunCompletionScreen({
    super.key,
    required this.session,
  });

  @override
  State<RunCompletionScreen> createState() => _RunCompletionScreenState();
}

class _RunCompletionScreenState extends State<RunCompletionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2979FF),
                  Color(0xFF232EA5),
                ],
              ),
            ),
          ),

          // Animated particles effect for conquest
          if (widget.session.territoryConquered)
            ...List.generate(20, (index) {
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 1000 + (index * 50)),
                builder: (context, value, child) {
                  final distance = value * 200;
                  return Positioned(
                    top: MediaQuery.of(context).size.height * 0.3 +
                        (distance * (index.isEven ? 1 : -1) * 0.5),
                    left: MediaQuery.of(context).size.width / 2 +
                        (distance * (index.isEven ? 1 : -1)),
                    child: Opacity(
                      opacity: 1 - value,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: [
                            Colors.amber,
                            Colors.orange,
                            Colors.green,
                            Colors.blue,
                            Colors.purple,
                          ][index % 5],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                    child: Column(
                      children: [
                        // Trophy/Check icon with animation
                        FadeTransition(
                          opacity: _animationController,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: Curves.elasticOut,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                widget.session.territoryConquered
                                    ? Icons.emoji_events_rounded
                                    : Icons.check_circle_rounded,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const Gap(30),

                        // Title
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, -0.5),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Curves.easeOut,
                            ),
                          ),
                          child: FadeTransition(
                            opacity: _animationController,
                            child: Text(
                              widget.session.territoryConquered
                                  ? '🎉 Territory Conquered! 🎉'
                                  : 'Run Completed!',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                        const Gap(10),

                        // Subtitle
                        FadeTransition(
                          opacity: _animationController,
                          child: Text(
                            widget.session.territoryConquered
                                ? 'You are now the owner of this territory!'
                                : 'Great job on completing your run!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const Gap(40),

                        // Stats cards
                        FadeTransition(
                          opacity: _animationController,
                          child: Column(
                            children: [
                              // Main stats card
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // Distance
                                    _StatItem(
                                      icon: Icons.straighten_rounded,
                                      label: 'Distance',
                                      value: widget.session.formattedDistance,
                                      color: AppColors.blueLogo,
                                    ),
                                    const Divider(height: 32),

                                    // Duration
                                    _StatItem(
                                      icon: Icons.timer_rounded,
                                      label: 'Duration',
                                      value: widget.session.formattedDuration,
                                      color: AppColors.cyan,
                                    ),
                                    const Divider(height: 32),

                                    // Pace
                                    _StatItem(
                                      icon: Icons.speed_rounded,
                                      label: 'Average Pace',
                                      value: widget.session.formattedPace,
                                      color: AppColors.green[500]!,
                                    ),
                                    const Divider(height: 32),

                                    // Speed
                                    _StatItem(
                                      icon: Icons.directions_run_rounded,
                                      label: 'Average Speed',
                                      value: widget.session.formattedSpeed,
                                      color: AppColors.orange[500]!,
                                    ),
                                    const Divider(height: 32),

                                    // Calories
                                    _StatItem(
                                      icon: Icons.local_fire_department_rounded,
                                      label: 'Calories Burned',
                                      value: '${widget.session.caloriesBurned} kcal',
                                      color: AppColors.red[500]!,
                                    ),
                                  ],
                                ),
                              ),

                              const Gap(20),

                              // Territory conquest message
                              if (widget.session.territoryConquered)
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withValues(alpha: 0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.emoji_events,
                                          color: Colors.amber,
                                          size: 28,
                                        ),
                                      ),
                                      const Gap(16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Fastest Runner!',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Gap(4),
                                            Text(
                                              'You beat the previous record with your pace of ${widget.session.formattedPace}',
                                              style: TextStyle(
                                                color: Colors.white.withValues(alpha: 0.9),
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withValues(alpha: 0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.info_outline,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                      const Gap(16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Keep Improving!',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Gap(4),
                                            Text(
                                              'Beat the current record to claim this territory!',
                                              style: TextStyle(
                                                color: Colors.white.withValues(alpha: 0.9),
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              const Gap(30),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Share Run button - Primary action
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RunShareScreen(
                                  distance: widget.session.formattedDistance,
                                  pace: widget.session.formattedPace,
                                  duration: widget.session.formattedDuration,
                                  avgSpeed: widget.session.formattedSpeed,
                                  calories: '${widget.session.caloriesBurned} kcal',
                                  routePoints: widget.session.routePoints,
                                  territoryConquered: widget.session.territoryConquered,
                                  territoryName: widget.session.territoryId.toString(),
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
                                'Bagikan Lari',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Gap(12),

                      // View Leaderboard button (if conquered)
                      if (widget.session.territoryConquered)
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to leaderboard
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
                                  'Lihat Leaderboard',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      if (widget.session.territoryConquered) const Gap(12),

                      // Done button
                      SizedBox(
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
                            widget.session.territoryConquered ? 'Selesai' : 'Kembali ke Peta',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Stat Item Widget
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const Gap(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
