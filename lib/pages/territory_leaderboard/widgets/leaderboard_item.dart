import 'package:flutter/material.dart';
import '../../../data/model/running/run_session_model.dart';
import '../user_runs_detail_page.dart';

class LeaderboardItem extends StatelessWidget {
  final RunSession runSession;
  final int rank;
  final bool isCurrentUser;
  final int territoryId;

  const LeaderboardItem({
    super.key,
    required this.runSession,
    required this.rank,
    required this.territoryId,
    this.isCurrentUser = false,
  });

  Color _getRankColor() {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey.withValues(alpha: 0.3);
    }
  }

  IconData _getRankIcon() {
    switch (rank) {
      case 1:
        return Icons.workspace_premium_rounded;
      case 2:
        return Icons.workspace_premium_rounded;
      case 3:
        return Icons.workspace_premium_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  Color _getProfileColor() {
    if (runSession.userProfileColor != null) {
      try {
        return Color(
          int.parse(runSession.userProfileColor!.replaceAll('#', '0xFF')),
        );
      } catch (e) {
        return Colors.blue;
      }
    }
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserRunsDetailPage(
              territoryId: territoryId,
              userId: runSession.userId,
              userName: runSession.userDisplayName,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? Colors.blue.withValues(alpha: 0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
          // Rank Badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getRankColor(),
              shape: BoxShape.circle,
            ),
            child: rank <= 3
                ? Icon(
                    _getRankIcon(),
                    color: Colors.white,
                    size: 20,
                  )
                : Center(
                    child: Text(
                      '$rank',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
          ),

          const SizedBox(width: 12),

          // User Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getProfileColor().withValues(alpha: 0.2),
              border: Border.all(
                color: _getProfileColor(),
                width: 2,
              ),
            ),
            child: runSession.userAvatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      runSession.userAvatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar();
                      },
                    ),
                  )
                : _buildDefaultAvatar(),
          ),

          const SizedBox(width: 12),

          // User Info and Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        runSession.userDisplayName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isCurrentUser ? Colors.blue[700] : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'You',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_rounded,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        runSession.formattedPaceWithUnit,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.route_rounded,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        runSession.formattedDistance,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        runSession.formattedDuration,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Territory Conquered Badge
          if (runSession.territoryConquered)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                size: 18,
                color: Colors.amber[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Icon(
      Icons.person_rounded,
      color: _getProfileColor(),
      size: 24,
    );
  }
}
