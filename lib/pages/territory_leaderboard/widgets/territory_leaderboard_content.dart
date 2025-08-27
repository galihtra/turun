import 'package:flutter/material.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';
import 'package:turun/resources/values_app.dart';

class TerritoryLeaderboardContent extends StatelessWidget {
  final ScrollController scrollController;
  final bool isExpanded;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const TerritoryLeaderboardContent({
    super.key,
    required this.scrollController,
    required this.isExpanded,
    this.currentPage = 1,
    this.totalPages = 5,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.w16,
                  vertical: AppDimens.h16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: AppSizes.s16,
                              color: AppColors.red,
                            ),
                            AppGaps.kGap4,
                            Text(
                              "Batam, Riau Islands",
                              style: AppStyles.body2Medium
                                  .copyWith(color: AppColors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppGaps.kGap12,
            ],
          ),
        ),
        if (isExpanded)
          SliverList(
            delegate: SliverChildListDelegate([
              _buildLeaderboardItem(
                rank: 1,
                name: "Muhammad Maulana Yusuf",
                runs: 10,
                area: "450 Km²",
                isCurrentUser: false,
                medalColor: AppColors.yellow,
              ),
              _buildLeaderboardItem(
                rank: 2,
                name: "Yuna Seo",
                runs: 4,
                area: "340 Km²",
                isCurrentUser: false,
                medalColor: AppColors.green,
              ),
              _buildLeaderboardItem(
                rank: 3,
                name: "In-seong Soo",
                runs: 5,
                area: "300 Km²",
                isCurrentUser: false,
                medalColor: AppColors.blue.shade500,
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
              AppGaps.kGap16,
              _buildPagination(),
              AppGaps.kGap24,
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
      margin: EdgeInsets.symmetric(
        vertical: AppDimens.h6,
        horizontal: AppDimens.w16,
      ),
      padding: const EdgeInsets.all(AppPaddings.p16),
      decoration: BoxDecoration(
        color: isCurrentUser ? AppColors.blueLight : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(color: AppColors.blueLogo, width: 1.5)
            : Border.all(color: AppColors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.shade50,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: AppDimens.w26,
            height: AppDimens.h26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: medalColor ?? _getRankColor(rank),
              shape: BoxShape.circle,
            ),
            child: Text(
              "$rank",
              style: AppStyles.body3SemiBold.copyWith(color: AppColors.white),
            ),
          ),
          AppGaps.kGap12,
          Container(
            width: AppDimens.w40,
            height: AppDimens.h40,
            decoration: BoxDecoration(
              color: AppColors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: AppColors.grey.shade600,
              size: AppSizes.s24,
            ),
          ),
          AppGaps.kGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppStyles.body2SemiBold.copyWith(
                    color: isCurrentUser ? AppColors.blueLogo : AppColors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Total Runs: $runs",
                  style: AppStyles.body3Regular
                      .copyWith(color: AppColors.deepBlueOpacity),
                ),
              ],
            ),
          ),
          AppGaps.kGap10,
          Text(
            area,
            style: AppStyles.body1SemiBold.copyWith(
              color: isCurrentUser ? AppColors.blueLogo : AppColors.deepBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.w16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Tombol Previous
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: AppSizes.s16),
            onPressed:
                currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            color: currentPage > 1 ? AppColors.deepBlue : Colors.grey,
            padding: const EdgeInsets.all(AppPaddings.p8),
          ),

          // Halaman 1
          _buildPageNumber(1),
          AppGaps.kGap8,

          // Halaman 2
          _buildPageNumber(2),
          AppGaps.kGap8,

          // Halaman 3
          _buildPageNumber(3),
          AppGaps.kGap8,
          Text(
            "...",
            style: AppStyles.body1SemiBold
                .copyWith(color: AppColors.grey.shade600),
          ),
          AppGaps.kGap8,
          _buildPageNumber(totalPages),
          IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios,
              size: AppSizes.s16,
            ),
            onPressed: currentPage < totalPages
                ? () => onPageChanged(currentPage + 1)
                : null,
            color: currentPage < totalPages ? AppColors.deepBlue : Colors.grey,
            padding: const EdgeInsets.all(AppPaddings.p8),
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
        width: AppDimens.w36,
        height: AppDimens.h36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppColors.deepBlue : Colors.transparent,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(AppDimens.r10),
          border: isActive ? null : Border.all(color: AppColors.grey.shade500),
        ),
        child: Text(
          "$page",
          style: AppStyles.label2SemiBold.copyWith(
            color: isActive ? AppColors.white : AppColors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.yellow;
      case 2:
        return AppColors.green;
      case 3:
        return AppColors.blue.shade500;
      default:
        return AppColors.grey;
    }
  }
}
