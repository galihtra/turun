import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../data/providers/leaderboard/territory_leaderboard_provider.dart';
import '../../data/model/territory/territory_model.dart';
import 'widgets/territory_leaderboard_content.dart';

class TerritoryLeaderboardPage extends StatefulWidget {
  const TerritoryLeaderboardPage({super.key});

  @override
  State<TerritoryLeaderboardPage> createState() =>
      _TerritoryLeaderboardPageState();
}

class _TerritoryLeaderboardPageState extends State<TerritoryLeaderboardPage> {
  final DraggableScrollableController _draggableController =
      DraggableScrollableController();
  bool _isSheetOpen = true;
  bool _isInitialized = false;
  Set<Polygon> _polygons = {};

  @override
  void initState() {
    super.initState();
    _draggableController.addListener(() {
      if (_draggableController.size > 0.4 && !_isSheetOpen) {
        setState(() => _isSheetOpen = true);
      } else if (_draggableController.size <= 0.4 && _isSheetOpen) {
        setState(() => _isSheetOpen = false);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePage();
    });
  }

  Future<void> _initializePage() async {
    if (_isInitialized) return;

    final provider = context.read<TerritoryLeaderboardProvider>();
    await provider.initialize();
    _createPolygons();

    setState(() {
      _isInitialized = true;
    });
  }

  void _createPolygons() {
    final provider = context.read<TerritoryLeaderboardProvider>();
    final territories = provider.territories;

    final polygons = <Polygon>{};

    for (int i = 0; i < territories.length; i++) {
      final territory = territories[i];
      if (territory.points.isEmpty) continue;

      // Use owner color if available, otherwise use default color
      Color fillColor = const Color(0xFF2196F3).withOpacity(0.3);
      Color strokeColor = const Color(0xFF2196F3);

      if (territory.ownerColor != null) {
        try {
          final colorValue = int.parse(
            territory.ownerColor!.replaceAll('#', '0xFF'),
          );
          fillColor = Color(colorValue).withOpacity(0.3);
          strokeColor = Color(colorValue);
        } catch (e) {
          // Use default color if parsing fails
        }
      }

      polygons.add(
        Polygon(
          polygonId: PolygonId('territory_${territory.id}'),
          points: territory.points,
          fillColor: fillColor,
          strokeColor: strokeColor,
          strokeWidth: 2,
          consumeTapEvents: true,
          onTap: () => _onTerritoryTap(territory),
        ),
      );
    }

    setState(() {
      _polygons = polygons;
    });
  }

  void _onTerritoryTap(Territory territory) {
    final provider = context.read<TerritoryLeaderboardProvider>();
    provider.moveToTerritory(territory);

    // Minimize bottom sheet to show map
    if (_draggableController.size > 0.35) {
      _draggableController.animateTo(
        0.35,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    final provider = context.read<TerritoryLeaderboardProvider>();
    provider.setMapController(controller);
  }

  @override
  void dispose() {
    _draggableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TerritoryLeaderboardProvider>(
        builder: (context, provider, child) {
          if (!_isInitialized || provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
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
                    provider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initializePage,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final userLocation = provider.userLocation ??
              const LatLng(1.18376, 104.01703);

          return Stack(
            children: [
              // Google Map
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: userLocation,
                  zoom: provider.currentZoom,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                polygons: _polygons,
                onMapCreated: _onMapCreated,
              ),

              // Zoom controls
              Positioned(
                left: 16,
                bottom: MediaQuery.of(context).size.height * 0.35 + 20,
                child: Column(
                  children: [
                    _buildZoomButton(
                      icon: Icons.add_rounded,
                      onPressed: provider.zoomIn,
                    ),
                    const SizedBox(height: 8),
                    _buildZoomButton(
                      icon: Icons.remove_rounded,
                      onPressed: provider.zoomOut,
                    ),
                  ],
                ),
              ),

              // Recenter button
              Positioned(
                right: 16,
                bottom: MediaQuery.of(context).size.height * 0.35 + 20,
                child: _buildZoomButton(
                  icon: Icons.my_location_rounded,
                  onPressed: provider.recenterMap,
                ),
              ),

              // Bottom Sheet
              SafeArea(
                top: true,
                bottom: false,
                child: DraggableScrollableSheet(
                  controller: _draggableController,
                  initialChildSize: 0.50,
                  minChildSize: 0.35,
                  maxChildSize: 1,
                  snap: true,
                  snapSizes: const [0.35, 0.7, 1],
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 80),
                        child: TerritoryLeaderboardContent(
                          scrollController: scrollController,
                          isExpanded: _isSheetOpen,
                          onTerritoryTap: _onTerritoryTap,
                          onSearchChanged: (query) async {
                            await provider.searchTerritories(query);
                            _createPolygons();
                          },
                          onClearSearch: () {
                            provider.clearSearch();
                            _createPolygons();
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      elevation: 4,
      shape: const CircleBorder(),
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.white,
        child: IconButton(
          icon: Icon(icon, color: Colors.black87),
          onPressed: onPressed,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
