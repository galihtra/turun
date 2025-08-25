import 'package:flutter/material.dart';

class TerritoryLeaderboardContent extends StatelessWidget {
  final ScrollController scrollController;
  final bool isExpanded;
  final VoidCallback onToggle;

  const TerritoryLeaderboardContent({
    Key? key,
    required this.scrollController,
    required this.isExpanded,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle drag
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 40,
                  height: 5,
                  margin: EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              
              // Header (selalu terlihat)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "# Leaderboard",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Batam, Riau Islands",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                        color: Colors.blue,
                      ),
                      onPressed: onToggle,
                    ),
                  ],
                ),
              ),
              
              // Divider
              Divider(height: 24, thickness: 1),
            ],
          ),
        ),
        
        // Content (hanya terlihat ketika expanded)
        if (isExpanded)
          SliverList(
            delegate: SliverChildListDelegate([
              _buildLeaderboardItem(
                rank: 1,
                name: "Muhammad Mau...",
                runs: 10,
                area: "450 Km²",
                isCurrentUser: false,
              ),
              _buildLeaderboardItem(
                rank: 2,
                name: "Yuna Seo",
                runs: 4,
                area: "340 Km²",
                isCurrentUser: false,
              ),
              _buildLeaderboardItem(
                rank: 3,
                name: "In-seong Soo",
                runs: 5,
                area: "300 Km²",
                isCurrentUser: false,
              ),
              _buildLeaderboardItem(
                rank: 4,
                name: "Hrishita Mrinal",
                runs: 2,
                area: "285 Km²",
                isCurrentUser: false,
              ),
              _buildLeaderboardItem(
                rank: 5,
                name: "Gulian Tiejun",
                runs: 3,
                area: "210 Km²",
                isCurrentUser: false,
              ),
              SizedBox(height: 16),
              _buildLeaderboardItem(
                rank: 1,
                name: "You",
                runs: 3,
                area: "100 Km²",
                isCurrentUser: true,
              ),
              SizedBox(height: 24),
            ]),
          ),
      ],
    );
  }

  Widget _buildLeaderboardItem({
    required int rank,
    required String name,
    required int runs,
    required String area,
    required bool isCurrentUser,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.blue[50] : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser ? Border.all(color: Colors.blue) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            alignment: Alignment.center,
            child: Text(
              "$rank",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isCurrentUser ? Colors.blue : Colors.black,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isCurrentUser ? Colors.blue : Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Total Runs: $runs",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            area,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isCurrentUser ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}