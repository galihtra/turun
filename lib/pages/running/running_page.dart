import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RunningPage extends StatefulWidget {
  const RunningPage({super.key});

  @override
  _RunningPageState createState() => _RunningPageState();
}

class _RunningPageState extends State<RunningPage> {
  GoogleMapController? mapController;

  final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(1.18376, 104.01703),
    zoom: 14.4746,
  );

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  int _selectedMode = 0; // 0 = Game, 1 = Solo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          /// Background Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          /// Toggle Game / Solo
          Positioned(
            top: 60,
            left: MediaQuery.of(context).size.width * 0.2,
            right: MediaQuery.of(context).size.width * 0.2,
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMode = 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedMode == 0
                              ? Colors.blue
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.sports_esports,
                                  color: _selectedMode == 0
                                      ? Colors.white
                                      : Colors.black54,
                                  size: 18),
                              const SizedBox(width: 5),
                              Text(
                                "Game",
                                style: TextStyle(
                                  color: _selectedMode == 0
                                      ? Colors.white
                                      : Colors.black54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMode = 1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedMode == 1
                              ? Colors.blue
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            "Solo",
                            style: TextStyle(
                              color: _selectedMode == 1
                                  ? Colors.white
                                  : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Tombol START (tengah bawah)
          Positioned(
            bottom: 40,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Row(
                children: [
                  Text(
                    "START",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.play_arrow, color: Colors.white),
                ],
              ),
            ),
          ),

          /// Tombol Globe (kiri bawah)
          Positioned(
            bottom: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.public, color: Colors.black87),
            ),
          ),

          /// Tombol Lokasi (kanan bawah)
          Positioned(
            bottom: 50,
            right: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.location_on, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
