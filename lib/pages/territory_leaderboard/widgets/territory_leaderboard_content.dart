import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/leaderboard/territory_leaderboard_provider.dart';
import '../../../data/model/territory/territory_model.dart';
import 'territory_leaderboard_card.dart';
import 'territory_search_bar.dart';
import '../territory_detail_page.dart';

class TerritoryLeaderboardContent extends StatefulWidget {
  final ScrollController scrollController;
  final bool isExpanded;
  final Function(Territory) onTerritoryTap;
  final Function(String) onSearchChanged;
  final VoidCallback onClearSearch;

  const TerritoryLeaderboardContent({
    super.key,
    required this.scrollController,
    required this.isExpanded,
    required this.onTerritoryTap,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  @override
  State<TerritoryLeaderboardContent> createState() =>
      _TerritoryLeaderboardContentState();
}

class _TerritoryLeaderboardContentState
    extends State<TerritoryLeaderboardContent> {
  int _currentPage = 1;
  final int _itemsPerPage = 6;

  int get _totalPages {
    final provider = context.watch<TerritoryLeaderboardProvider>();
    return (provider.territories.length / _itemsPerPage).ceil().clamp(1, 999);
  }

  List<Territory> get _currentPageTerritories {
    final provider = context.watch<TerritoryLeaderboardProvider>();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage)
        .clamp(0, provider.territories.length);

    if (startIndex >= provider.territories.length) {
      return [];
    }

    return provider.territories.sublist(startIndex, endIndex);
  }

  void _handlePageChange(int newPage) {
    setState(() {
      _currentPage = newPage.clamp(1, _totalPages);
    });
  }

  void _onTerritoryCardTap(Territory territory) {
    // Just move map to territory location
    widget.onTerritoryTap(territory);
  }

  void _onTerritoryCardLongPress(Territory territory) {
    // Open detail page on long press
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TerritoryDetailPage(territory: territory),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Icon(
                Icons.leaderboard_rounded,
                color: Colors.black87,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Territory Leaderboard',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        if (widget.isExpanded) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TerritorySearchBar(
              onSearchChanged: (query) {
                widget.onSearchChanged(query);
                setState(() {
                  _currentPage = 1;
                });
              },
              onClearSearch: () {
                widget.onClearSearch();
                setState(() {
                  _currentPage = 1;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        Expanded(
          child: Consumer<TerritoryLeaderboardProvider>(
            builder: (context, provider, child) {
              if (provider.territories.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No territories found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                controller: widget.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 8,
                    bottom: 100, // Add extra padding for bottom navigation
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7, // Increased height for cards
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _currentPageTerritories.length,
                    itemBuilder: (context, index) {
                      final territory = _currentPageTerritories[index];
                      final distance = provider.getDistanceToTerritory(territory);

                      return TerritoryLeaderboardCard(
                        territory: territory,
                        distance: distance,
                        onTap: () => _onTerritoryCardTap(territory),
                        onLongPress: () => _onTerritoryCardLongPress(territory),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),

        if (widget.isExpanded && _totalPages > 1) ...[
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _currentPage > 1
                      ? () => _handlePageChange(_currentPage - 1)
                      : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                  color: Colors.black87,
                  disabledColor: Colors.grey[300],
                ),

                Text(
                  'Page $_currentPage of $_totalPages',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),

                IconButton(
                  onPressed: _currentPage < _totalPages
                      ? () => _handlePageChange(_currentPage + 1)
                      : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                  color: Colors.black87,
                  disabledColor: Colors.grey[300],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
