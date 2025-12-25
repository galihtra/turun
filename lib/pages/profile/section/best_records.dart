import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turun/data/model/running/run_session_model.dart';

class BestRecords extends StatefulWidget {
  const BestRecords({super.key});

  @override
  State<BestRecords> createState() => _BestRecordsState();
}

class _BestRecordsState extends State<BestRecords> {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = true;
  double _longestDistance = 0.0;
  double _bestPace = 0.0;
  int _longestDuration = 0;

  @override
  void initState() {
    super.initState();
    _loadBestRecords();
  }

  Future<void> _loadBestRecords() async {
    setState(() => _isLoading = true);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('run_sessions')
          .select()
          .eq('user_id', userId)
          .eq('status', 'completed');

      final runs = (response as List)
          .map((json) => RunSession.fromJson(json as Map<String, dynamic>))
          .toList();

      if (runs.isNotEmpty) {
        // Longest distance
        final longestRun = runs.reduce((a, b) => a.distanceKm > b.distanceKm ? a : b);
        _longestDistance = longestRun.distanceKm;

        // Best pace (fastest = lowest pace value)
        final fastestRun = runs.reduce((a, b) =>
          a.averagePaceMinPerKm < b.averagePaceMinPerKm ? a : b
        );
        _bestPace = fastestRun.averagePaceMinPerKm;

        // Longest duration
        final longestDurationRun = runs.reduce((a, b) =>
          a.durationSeconds > b.durationSeconds ? a : b
        );
        _longestDuration = longestDurationRun.durationSeconds;
      }

      setState(() {});
    } catch (e) {
      // Handle error silently
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatPace(double paceMinPerKm) {
    if (paceMinPerKm == 0) return '0:00';
    final minutes = paceMinPerKm.floor();
    final seconds = ((paceMinPerKm - minutes) * 60).round();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Best Records',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D1B2A),
            ),
          ),
        ),
        _buildRecordCard(
          Icons.polyline,
          'LONGEST DISTANCE',
          _longestDistance.toStringAsFixed(1),
          'km',
          const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          ),
        ),
        const Gap(12),
        _buildRecordCard(
          Icons.speed,
          'BEST PACE',
          _formatPace(_bestPace),
          'min/km',
          const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
          ),
        ),
        const Gap(12),
        _buildRecordCard(
          Icons.timer_outlined,
          'LONGEST DURATION',
          _formatDuration(_longestDuration),
          null,
          const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordCard(
    IconData icon,
    String title,
    String value,
    String? unit,
    Gradient gradient,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const Gap(20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B7280),
                    letterSpacing: 0.8,
                  ),
                ),
                const Gap(6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D1B2A),
                        height: 1,
                      ),
                    ),
                    if (unit != null) ...[
                      const Gap(6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          unit,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Color(0xFFFFD700),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
