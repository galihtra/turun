import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:turun/pages/territory_leaderboard/widgets/territory_leaderboard_content.dart';

class TerritoryLeaderboardPage extends StatefulWidget {
  @override
  _TerritoryLeaderboardPageState createState() =>
      _TerritoryLeaderboardPageState();
}

class _TerritoryLeaderboardPageState extends State<TerritoryLeaderboardPage> {
  GoogleMapController? mapController;
  final DraggableScrollableController _draggableController =
      DraggableScrollableController();
  bool _isSheetOpen = true;
  int _currentPage = 1;
  final int _totalPages = 5;

  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(1.18376, 104.01703),
    zoom: 14.4746,
  );

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _handlePageChange(int newPage) {
    setState(() {
      _currentPage = newPage;
    });
    // Di sini Anda bisa menambahkan logika untuk mengambil data halaman baru
  }

  void _toggleSheet() {
    if (_isSheetOpen) {
      _draggableController.animateTo(
        0.15,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _draggableController.animateTo(
        0.7,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    setState(() {
      _isSheetOpen = !_isSheetOpen;
    });
  }

  @override
  void initState() {
    super.initState();
    _draggableController.addListener(() {
      if (_draggableController.size > 0.2 && !_isSheetOpen) {
        setState(() => _isSheetOpen = true);
      } else if (_draggableController.size <= 0.2 && _isSheetOpen) {
        setState(() => _isSheetOpen = false);
      }
    });
  }

  @override
  void dispose() {
    _draggableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _kGooglePlex,
          ),
          SafeArea(
            top: true,
            bottom: false,
            child: DraggableScrollableSheet(
              controller: _draggableController,
              initialChildSize: 0.35,
              minChildSize: 0.35,
              maxChildSize: 1,
              snap: true,
              snapSizes: [0.35, 1],
              builder: (context, scrollController) {
                return Container(
                  margin: EdgeInsets.only(bottom: 80),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: TerritoryLeaderboardContent(
                    scrollController: scrollController,
                    isExpanded: _isSheetOpen,
                    onToggle: _toggleSheet,
                    currentPage: _currentPage,
                    totalPages: _totalPages,
                    onPageChanged: _handlePageChange,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
