import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_application_1/config/firebase_logic.dart';
import 'package:flutter_application_1/config/models.dart';

class HomePage extends StatefulWidget {
  static const String route = '/';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Marker> _markers = [];
  // Function to fetch parking data and generate markers
  Future<void> _loadParkingMarkers() async {
    List<Parking> parkings = await firestoreService.getParkings();
    List<Marker> markers = parkings.map((parking) {
      return buildPin(
          LatLng(parking.coordinates.latitude, parking.coordinates.longitude),
          parking,
          context);
    }).toList();
    // Update the state with the markers
    setState(() {
      _markers = markers;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadParkingMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter:
                  const LatLng(41.61213179151308, 0.6221237768064511),
              initialZoom: 15,
              cameraConstraint: CameraConstraint.contain(
                bounds: LatLngBounds(
                  const LatLng(-90, -180),
                  const LatLng(90, 180),
                ),
              ),
            ),
            children: [
              openStreetMapTileLayer,
              RichAttributionWidget(
                popupInitialDisplayDuration: const Duration(seconds: 5),
                animationConfig: const ScaleRAWA(),
                showFlutterMapAttribution: false,
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () async => launchUrl(
                      Uri.parse('https://openstreetmap.org/copyright'),
                    ),
                  ),
                  const TextSourceAttribution(
                    'This attribution is the same throughout this app, except '
                    'where otherwise specified',
                    prependCopyright: false,
                  ),
                ],
              ),
              MarkerLayer(markers: _markers)
            ],
          ),
        ],
      ),
    );
  }

  TileLayer get openStreetMapTileLayer => TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'dev.fleaflet.flutter_map.example',
        // Use the recommended flutter_map_cancellable_tile_provider package to
        // support the cancellation of loading tiles.
        tileProvider: CancellableNetworkTileProvider(),
      );

  Marker buildPin(LatLng point, Parking parking, BuildContext context) {
    return Marker(
      point: point,
      width: 60,
      height: 60,
      child: GestureDetector(
        onTap: () {
          // Show a custom dialog when the marker is tapped
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  parking.name,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold), // Larger and bold parking name
                ),
                content: SingleChildScrollView(
                  // Make content scrollable
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display an image
                      Image.network('assets/images/parking_logo.png',
                          width: 100, height: 100),
                      SizedBox(height: 10),
                      // Parking details
                      Text(
                        parking.address,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      // Make the maps URL clickable
                      InkWell(
                        child: Text(
                          parking.mapsUrl,
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                        ),
                        onTap: () async {
                          // Open the URL in a web browser
                          if (await canLaunch(parking.mapsUrl)) {
                            await launch(parking.mapsUrl);
                          } else {
                            throw 'Could not launch ${parking.mapsUrl}';
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      // Make "Filled" bigger and center it
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Filled: ${parking.filledCount}/${parking.maxSpots}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _getOccupancyColor(parking.filledCount, parking.maxSpots)
                          ),
                        ),
                      ),
                      SizedBox(height: 20), // More space between sections
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.location_pin, size: 60, color: Colors.black),
      ),
    );
  }

  // Function to determine color based on occupancy percentage
  Color _getOccupancyColor(int filledCount, int maxSpots) {
    if (maxSpots == 0)
      return Colors.grey; // In case maxSpots is 0, avoid division by zero

    double occupancyPercentage = (filledCount / maxSpots) * 100;

    if (occupancyPercentage <= 33) {
      return Colors.green; // 0% to 33%
    } else if (occupancyPercentage <= 67) {
      return Colors.orange; // 34% to 67%
    } else {
      return Colors.red; // 68% and above
    }
  }
}
