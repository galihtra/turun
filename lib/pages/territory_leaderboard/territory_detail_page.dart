import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/model/territory/territory_model.dart';
import '../../data/model/running/run_session_model.dart';
import '../../data/services/territory_leaderboard_service.dart';
import 'widgets/leaderboard_item.dart';
import 'widgets/territory_info_header.dart';

class TerritoryDetailPage extends StatefulWidget {
  final Territory territory;

  const TerritoryDetailPage({
    super.key,
    required this.territory,
  });

  @override
  State<TerritoryDetailPage> createState() => _TerritoryDetailPageState();
}

class _TerritoryDetailPageState extends State<TerritoryDetailPage> {
  final TerritoryLeaderboardService _service = TerritoryLeaderboardService();
  List<RunSession> _leaderboard = [];
  TerritoryStats? _stats;
  RunSession? _userBestRun;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentUser = Supabase.instance.client.auth.currentUser;

      final results = await Future.wait([
        _service.getTerritoryLeaderboard(
          territoryId: widget.territory.id,
          limit: 50,
        ),
        _service.getTerritoryStats(widget.territory.id),
        if (currentUser != null)
          _service.getUserBestRunForTerritory(
            territoryId: widget.territory.id,
            userId: currentUser.id,
          ),
      ]);

      setState(() {
        _leaderboard = results[0] as List<RunSession>;
        _stats = results[1] as TerritoryStats?;
        if (results.length > 2) {
          _userBestRun = results[2] as RunSession?;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load leaderboard: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.territory.name ?? 'Territory',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadLeaderboard,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadLeaderboard,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Territory Info Header
                        TerritoryInfoHeader(
                          territory: widget.territory,
                          stats: _stats,
                        ),

                        const SizedBox(height: 16),

                        // User's Best Run (if exists)
                        if (_userBestRun != null) ...[
                          _buildUserBestRunSection(),
                          const SizedBox(height: 16),
                        ],

                        // Leaderboard
                        _buildLeaderboardSection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildUserBestRunSection() {
    if (_userBestRun == null) return const SizedBox.shrink();

    // Find user's rank
    int userRank = _leaderboard.indexWhere(
      (run) => run.id == _userBestRun!.id,
    );
    userRank = userRank == -1 ? _leaderboard.length + 1 : userRank + 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events_rounded,
                color: Colors.blue[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Your Best Run',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LeaderboardItem(
            runSession: _userBestRun!,
            rank: userRank,
            territoryId: widget.territory.id,
            isCurrentUser: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.leaderboard_rounded,
                  color: Colors.black87,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Leaderboard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_leaderboard.length} runners',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_leaderboard.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.sports_score_rounded,
                      size: 48,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No runs yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Be the first to conquer this territory!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _leaderboard.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                indent: 72,
              ),
              itemBuilder: (context, index) {
                final run = _leaderboard[index];
                final currentUser = Supabase.instance.client.auth.currentUser;
                final isCurrentUser = currentUser?.id == run.userId;

                return LeaderboardItem(
                  runSession: run,
                  rank: index + 1,
                  territoryId: widget.territory.id,
                  isCurrentUser: isCurrentUser,
                );
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
