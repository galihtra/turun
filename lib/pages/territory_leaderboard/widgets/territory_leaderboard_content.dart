import 'package:flutter/material.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';
import 'package:turun/resources/values_app.dart';

class TerritoryLeaderboardContent extends StatelessWidget {
  final ScrollController scrollController;
  final bool isExpanded;
  final VoidCallback onToggle;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const TerritoryLeaderboardContent({
    Key? key,
    required this.scrollController,
    required this.isExpanded,
    required this.onToggle,
    this.currentPage = 1,
    this.totalPages = 5,
    required this.onPageChanged,
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
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Header
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Leaderboard Row - diubah menjadi Column untuk rata tengah sempurna
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Leaderboard",
                                style: AppStyles.title1SemiBold),
                            AppGaps.kGap4,
                            const Icon(Icons.emoji_events,
                                color: AppColors.yellow),
                          ],
                        ),
                      ],
                    ),

                    AppGaps.kGap10,

                    // Location Row - diubah menjadi Column untuk rata tengah sempurna
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on,
                                size: 16, color: Colors.red),
                            SizedBox(width: 4),
                            Text(
                              "Batam, Riau Islands",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppGaps.kGap16,
            ],
          ),
        ),

        // Content (hanya terlihat ketika expanded)
        if (isExpanded)
          SliverList(
            delegate: SliverChildListDelegate([
              _buildLeaderboardItem(
                rank: 1,
                name: "Muhammad Maulana Yusuf",
                runs: 10,
                area: "450 Km²",
                isCurrentUser: false,
                medalColor: Color(0xFFFFD700), // Emas untuk peringkat 1
              ),
              _buildLeaderboardItem(
                rank: 2,
                name: "Yuna Seo",
                runs: 4,
                area: "340 Km²",
                isCurrentUser: false,
                medalColor: Color(0xFFC0C0C0), // Perak untuk peringkat 2
              ),
              _buildLeaderboardItem(
                rank: 3,
                name: "In-seong Soo",
                runs: 5,
                area: "300 Km²",
                isCurrentUser: false,
                medalColor: Color(0xFFCD7F32), // Perunggu untuk peringkat 3
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
                name: "You",
                runs: 3,
                area: "100 Km²",
                isCurrentUser: true,
              ),
              SizedBox(height: 16),
              _buildPagination(),
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
    Color? medalColor,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser ? Color(0xFFE3F2FD) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(color: Color(0xFF2196F3), width: 1.5)
            : Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank Number dengan latar belakang bulat
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: medalColor ?? _getRankColor(rank),
              shape: BoxShape.circle,
            ),
            child: Text(
              "$rank",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(width: 12),

          // Profile Icon (Avatar)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: Colors.grey[600],
              size: 24,
            ),
          ),

          SizedBox(width: 12),

          // Name and Runs
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isCurrentUser ? Color(0xFF2196F3) : Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
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
          AppGaps.kGap10,
          // Area
          Text(
            area,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isCurrentUser ? Color(0xFF2196F3) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Tombol Previous
          IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 16),
            onPressed:
                currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            color: currentPage > 1 ? Colors.blue : Colors.grey,
            padding: EdgeInsets.all(8),
          ),

          // Halaman 1
          _buildPageNumber(1),
          SizedBox(width: 8),

          // Halaman 2
          _buildPageNumber(2),
          SizedBox(width: 8),

          // Halaman 3
          _buildPageNumber(3),
          SizedBox(width: 8),

          // Ellipsis (...)
          Text(
            "...",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(width: 8),
          _buildPageNumber(totalPages),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: currentPage < totalPages
                ? () => onPageChanged(currentPage + 1)
                : null,
            color: currentPage < totalPages ? Colors.blue : Colors.grey,
            padding: EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }

  Widget _buildPageNumber(int page) {
    bool isActive = page == currentPage;

    return GestureDetector(
      onTap: () => onPageChanged(page),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.transparent,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
          border: isActive ? null : Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          "$page",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isActive ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Color(0xFFFFD700); // Emas solid
      case 2:
        return Color(0xFFC0C0C0); // Perak solid
      case 3:
        return Color(0xFFCD7F32); // Perunggu solid
      default:
        return Color(0xFF2196F3); // Biru untuk peringkat lainnya
    }
  }
}
