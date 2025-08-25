import 'package:flutter/material.dart';

class TerritoryLeaderboardBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            "# Leaderboard",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Batam, Riau Islands",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16),
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
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
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
      margin: EdgeInsets.symmetric(vertical: 8),
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