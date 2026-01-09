import 'package:flutter/material.dart';
import 'package:turun/data/model/running/run_session_model.dart';
import 'package:gap/gap.dart';
import 'sections/completion_action_buttons.dart';
import 'sections/completion_header.dart';
import 'sections/completion_message_card.dart';
import 'sections/completion_stats_card.dart';
import 'widgets/completion_particles.dart';

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
          _buildBackground(),
          if (widget.session.territoryConquered) const CompletionParticles(),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
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
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              child: Column(
                children: [
                  CompletionHeader(
                    animationController: _animationController,
                    territoryConquered: widget.session.territoryConquered,
                  ),
                  const Gap(40),
                  FadeTransition(
                    opacity: _animationController,
                    child: Column(
                      children: [
                        CompletionStatsCard(session: widget.session),
                        const Gap(20),
                        CompletionMessageCard(
                          territoryConquered: widget.session.territoryConquered,
                          pace: widget.session.formattedPace,
                        ),
                        const Gap(30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          CompletionActionButtons(session: widget.session),
        ],
      ),
    );
  }
}
