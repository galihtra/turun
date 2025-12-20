import 'package:flutter/material.dart';
import '../../../data/model/territory/territory_model.dart';

class TerritoryLeaderboardCard extends StatelessWidget {
  final Territory territory;
  final double? distance;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const TerritoryLeaderboardCard({
    super.key,
    required this.territory,
    this.distance,
    required this.onTap,
    this.onLongPress,
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
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: territory.isOwned
                ? _getOwnerColor()
                : Colors.grey.withValues(alpha: 0.2),
            width: territory.isOwned ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Territory Image or Icon
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: territory.isOwned
                        ? _getOwnerColor().withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                  ),
                  child: territory.imageUrl != null
                      ? Image.network(
                          territory.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultIcon();
                          },
                        )
                      : _buildDefaultIcon(),
                ),
              ),

              // Territory Info
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Distance and Difficulty
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (distance != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${distance!.toStringAsFixed(1)} km',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          Text(
                            _getDifficultyStars(),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getDifficultyColor(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Territory Name
                      Text(
                        territory.name ?? 'Unnamed',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 2),

                      // Reward Points
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            size: 12,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${territory.rewardPoints ?? 100} pts',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Owner Info
                      if (territory.isOwned)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _getOwnerColor().withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_rounded,
                                size: 10,
                                color: _getOwnerColor(),
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  territory.ownerName ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: _getOwnerColor(),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.flag_rounded,
                                size: 10,
                                color: Colors.green[700],
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Available',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultIcon() {
    return Icon(
      Icons.location_on_rounded,
      size: 40,
      color: territory.isOwned
          ? _getOwnerColor().withValues(alpha: 0.6)
          : Colors.grey.withValues(alpha: 0.4),
    );
  }
}
