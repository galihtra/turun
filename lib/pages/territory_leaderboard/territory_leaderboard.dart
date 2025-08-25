import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:turun/pages/territory_leaderboard/widgets/territory_leaderboard_content.dart';

class TerritoryLeaderboardPage extends StatefulWidget {
  @override
  _TerritoryLeaderboardPageState createState() => _TerritoryLeaderboardPageState();
}

class _TerritoryLeaderboardPageState extends State<TerritoryLeaderboardPage> {
  GoogleMapController? mapController;
  final DraggableScrollableController _draggableController = DraggableScrollableController();
  bool _isSheetOpen = false;

  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(1.18376, 104.01703),
    zoom: 14.4746,
  );

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
          
          // Draggable Sheet dengan margin bottom yang lebih besar
          DraggableScrollableSheet(
            controller: _draggableController,
            initialChildSize: 0.15,
            minChildSize: 0.15,
            maxChildSize: 0.7,
            snap: true,
            snapSizes: [0.15, 0.7],
            builder: (context, scrollController) {
              return Container(
                margin: EdgeInsets.only(bottom: 80), // Tambahkan margin bottom yang besar
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
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}