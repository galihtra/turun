import 'package:flutter/material.dart';
import 'package:turun/resources/colors_app.dart';
import 'package:turun/resources/styles_app.dart';
import 'package:turun/resources/values_app.dart';

class TerritoryLeaderboardContent extends StatefulWidget {
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
  _TerritoryLeaderboardContentState createState() =>
      _TerritoryLeaderboardContentState();
}

class _TerritoryLeaderboardContentState
    extends State<TerritoryLeaderboardContent> {
  int? _expandedIndex; // Menyimpan index item yang sedang expanded

  void _toggleExpand(int index) {
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null; // Collapse jika sudah expanded
      } else {
        _expandedIndex = index; // Expand item baru
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: widget.scrollController,
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
        if (widget.isExpanded)
          SliverList(
            delegate: SliverChildListDelegate([
              _buildLeaderboardItem(
                index: 0,
                rank: 1,
                name: "Muhammad Maulana Yusuf",
                runs: 10,
                area: "450 Km²",
                isCurrentUser: false,
                medalColor: AppColors.yellow,
              ),
              _buildLeaderboardItem(
                index: 1,
                rank: 2,
                name: "Yuna Seo",
                runs: 4,
                area: "340 Km²",
                isCurrentUser: false,
                medalColor: AppColors.green,
              ),
              _buildLeaderboardItem(
                index: 2,
                rank: 3,
                name: "In-seong Soo",
                runs: 5,
                area: "300 Km²",
                isCurrentUser: false,
                medalColor: AppColors.blue.shade500,
              ),
              _buildLeaderboardItem(
                index: 3,
                rank: 4,
                name: "Hrishita Mrinal",
                runs: 2,
                area: "285 Km²",
                isCurrentUser: false,
              ),
              _buildLeaderboardItem(
                index: 4,
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
    required int index,
    required int rank,
    required String name,
    required int runs,
    required String area,
    required bool isCurrentUser,
    Color? medalColor,
  }) {
    final isExpanded = _expandedIndex == index;

    return Column(
      children: [
        // Item utama
        GestureDetector(
          onTap: () => _toggleExpand(index),
          child: Container(
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
                    style: AppStyles.body3SemiBold
                        .copyWith(color: AppColors.white),
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
                          color: isCurrentUser
                              ? AppColors.blueLogo
                              : AppColors.black,
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
                    color:
                        isCurrentUser ? AppColors.blueLogo : AppColors.deepBlue,
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.grey.shade600,
                ),
              ],
            ),
          ),
        ),

        // Detail content yang expandable
        if (isExpanded) _buildDetailContent(name: name),
      ],
    );
  }

  Widget _buildDetailContent({required String name}) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimens.w16,
        vertical: AppDimens.h8,
      ),
      padding: const EdgeInsets.all(AppPaddings.p16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.shade50,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info
          Text(name,
              style:
                  AppStyles.body1SemiBold.copyWith(color: AppColors.deepBlue)),
          SizedBox(height: AppDimens.h4),
          Text(
            "27 July 2025",
            style:
                AppStyles.body2Medium.copyWith(color: AppColors.grey.shade600),
          ),
          SizedBox(height: AppDimens.h10),
          _buildCapturedArea(),
          SizedBox(height: AppDimens.h10),
          _buildStat(
            valueDuration: "03:10",
            valueAvg: "01:00",
            valueDistance: "0.5",
          ),
        ],
      ),
    );
  }

  Widget _buildCapturedArea() {
    return Container(
      width: double.infinity, // Tambahkan ini untuk full width
      padding: const EdgeInsets.all(AppPaddings.p16),
      decoration: BoxDecoration(
        color: AppColors.yellow.shade50,
        borderRadius: BorderRadius.circular(AppDimens.r12),
        border: Border.all(color: AppColors.yellow.shade50),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "0.02 km²",
            style: AppStyles.title1SemiBold.copyWith(
              color: AppColors.yellow,
              fontSize: AppSizes.s24,
            ),
          ),
          SizedBox(height: AppDimens.h4),
          Text(
            "Captured Area",
            style: AppStyles.body2Medium.copyWith(
              color: AppColors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required String valueDuration,
    required String valueAvg,
    required String valueDistance,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppPaddings.p10),
      child: Column(
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Duration",
                  style: AppStyles.body3Medium.copyWith(
                    color: AppColors.deepBlueOpacity,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  "Avg pace",
                  style: AppStyles.body3Medium.copyWith(
                    color: AppColors.deepBlueOpacity,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  "Distance",
                  style: AppStyles.body3Medium.copyWith(
                    color: AppColors.deepBlueOpacity,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          AppGaps.kGap4,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  valueDuration,
                  style: AppStyles.title2SemiBold.copyWith(
                    color: AppColors.deepBlue,
                    fontSize: AppSizes.s18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  valueAvg,
                  style: AppStyles.title2SemiBold.copyWith(
                    color: AppColors.deepBlue,
                    fontSize: AppSizes.s18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  valueDistance,
                  style: AppStyles.title2SemiBold.copyWith(
                    color: AppColors.deepBlue,
                    fontSize: AppSizes.s18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          AppGaps.kGap4,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "min",
                  style: AppStyles.body3Medium.copyWith(
                    color: AppColors.deepBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  "min/km",
                  style: AppStyles.body3Medium.copyWith(
                    color: AppColors.deepBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  "km",
                  style: AppStyles.body3Medium.copyWith(
                    color: AppColors.deepBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
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
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: AppSizes.s16),
            onPressed: widget.currentPage > 1
                ? () => widget.onPageChanged(widget.currentPage - 1)
                : null,
            color: widget.currentPage > 1 ? AppColors.deepBlue : Colors.grey,
            padding: const EdgeInsets.all(AppPaddings.p8),
          ),
          _buildPageNumber(1),
          AppGaps.kGap8,
          _buildPageNumber(2),
          AppGaps.kGap8,
          _buildPageNumber(3),
          AppGaps.kGap8,
          Text("...",
              style: AppStyles.body1SemiBold
                  .copyWith(color: AppColors.grey.shade600)),
          AppGaps.kGap8,
          _buildPageNumber(widget.totalPages),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: AppSizes.s16),
            onPressed: widget.currentPage < widget.totalPages
                ? () => widget.onPageChanged(widget.currentPage + 1)
                : null,
            color: widget.currentPage < widget.totalPages
                ? AppColors.deepBlue
                : Colors.grey,
            padding: const EdgeInsets.all(AppPaddings.p8),
          ),
        ],
      ),
    );
  }

  Widget _buildPageNumber(int page) {
    bool isActive = page == widget.currentPage;
    return GestureDetector(
      onTap: () => widget.onPageChanged(page),
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
        child: Text("$page",
            style: AppStyles.label2SemiBold.copyWith(
              color: isActive ? AppColors.white : AppColors.grey.shade600,
            )),
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
