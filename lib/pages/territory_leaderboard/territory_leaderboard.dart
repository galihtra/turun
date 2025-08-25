import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TerritoryLeaderboard extends StatefulWidget {
  @override
  _TerritoryLeaderboardState createState() => _TerritoryLeaderboardState();
}

class _TerritoryLeaderboardState extends State<TerritoryLeaderboard> {
  GoogleMapController? mapController;

  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(1.18376, 104.01703),
    zoom: 14.4746,
  );

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: _kGooglePlex,
      ),
    );
  }
}