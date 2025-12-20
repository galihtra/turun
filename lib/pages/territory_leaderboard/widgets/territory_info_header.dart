import 'package:flutter/material.dart';
import '../../../data/model/territory/territory_model.dart';
import '../../../data/services/territory_leaderboard_service.dart';

class TerritoryInfoHeader extends StatelessWidget {
  final Territory territory;
  final TerritoryStats? stats;

  const TerritoryInfoHeader({
    super.key,
    required this.territory,
    this.stats,
  });

  String _getDifficultyStars() {
    switch (territory.difficulty?.toLowerCase()) {
      case 'easy':
        return '★☆☆';
      case 'medium':
        return '★★☆';
      case 'hard':
        return '★★★';
      default:
        return '★☆☆';
    }
  }

  Color _getDifficultyColor() {
    switch (territory.difficulty?.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getOwnerColor() {
    if (territory.ownerColor != null) {
      try {
        return Color(int.parse(territory.ownerColor!.replaceAll('#', '0xFF')));
      } catch (e) {
        return Colors.blue;
      }
    }
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Territory Image
          if (territory.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.network(
                territory.imageUrl!,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultImage();
                },
              ),
            )
          else
            _buildDefaultImage(),

          // Territory Info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Difficulty
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        territory.name ?? 'Unnamed Territory',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor().withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getDifficultyStars(),
                        style: TextStyle(
                          fontSize: 16,
                          color: _getDifficultyColor(),
                        ),
                      ),
                    ),
                  ],
                ),

                if (territory.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    territory.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Stats Row
                Row(
                  children: [
                    _buildStatItem(
                      icon: Icons.landscape_rounded,
                      label: 'Area',
                      value: '${territory.areaSizeKm?.toStringAsFixed(2) ?? '0.0'} km²',
                    ),
                    const SizedBox(width: 24),
                    _buildStatItem(
                      icon: Icons.emoji_events_rounded,
                      label: 'Rewards',
                      value: '${territory.rewardPoints ?? 100} pts',
                      iconColor: Colors.amber[700],
                    ),
                  ],
                ),

                if (stats != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatItem(
                        icon: Icons.directions_run_rounded,
                        label: 'Total Runs',
                        value: '${stats!.totalRuns}',
                      ),
                      const SizedBox(width: 24),
                      _buildStatItem(
                        icon: Icons.people_rounded,
                        label: 'Runners',
                        value: '${stats!.uniqueRunners}',
                      ),
                    ],
                  ),
                ],

                // Owner Info
                if (territory.isOwned) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getOwnerColor().withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          size: 20,
                          color: _getOwnerColor(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Owner',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              territory.ownerName ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _getOwnerColor(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.flag_rounded,
                          color: Colors.green[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'This territory is available to conquer!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: territory.isOwned
            ? _getOwnerColor().withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Icon(
        Icons.location_on_rounded,
        size: 64,
        color: territory.isOwned
            ? _getOwnerColor().withValues(alpha: 0.5)
            : Colors.grey.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: iconColor ?? Colors.grey[600],
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
