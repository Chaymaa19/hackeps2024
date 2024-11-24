import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_application_1/config/firebase_logic.dart';
import 'package:flutter_application_1/config/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  static const String route = '/';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Marker> _markers = [];
  Map<String, bool> favorites = {};
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

  Future<void> _loadUserFavorites() async {
    Map<String, bool> _favorites = await firestoreService.readUsersFavorites();
    // Update the state with the markers
    setState(() {
      favorites = _favorites;
    });
  }

  void _toggleFavorite(String parkingId, bool isFavorite) {
    setState(() {
      favorites[parkingId] = isFavorite;
    });
    firestoreService.updateUsersFavoriteParkings(favorites);
  }

  @override
  void initState() {
    super.initState();
    _loadParkingMarkers();
    _loadUserFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            // Assume you're listening to a Firestore collection `parkings`
            stream: firestoreService
                .getFirestore()
                .collection('parkings')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              // Extract parking data from snapshot
              var parkings = snapshot.data!.docs.map((doc) {
                var data = doc.data() as Map<String, dynamic>;
                return Parking.fromFirestore(doc);
              }).toList();

              // Build markers from updated parking data
              List<Marker> markers = parkings.map((parking) {
                return buildPin(
                  LatLng(parking.coordinates.latitude,
                      parking.coordinates.longitude),
                  parking,
                  context,
                );
              }).toList();

              return FlutterMap(
                options: MapOptions(
                  initialCenter:
                      const LatLng(41.61213179151308, 0.6221237768064511),
                  initialZoom: 15,
                ),
                children: [
                  openStreetMapTileLayer,
                  MarkerLayer(markers: markers),
                ],
              );
            },
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
    bool isFavorite = favorites[parking.id] ?? false;
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
              // Return StreamBuilder inside the AlertDialog
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('parkings')
                    .doc(parking
                        .id) // Assuming 'id' is the Firestore document ID
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Extract the parking details from the updated snapshot
                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  Parking updatedParking =
                      Parking.fromFirestore(snapshot.data!);

                  return AlertDialog(
                    title: StatefulBuilder(
                      builder: (context, setState) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                updatedParking.name,
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Toggle favorite state locally and update parent
                                setState(() {
                                  isFavorite = !isFavorite;
                                });
                                _toggleFavorite(parking.id, isFavorite);
                              },
                              child: Icon(
                                Icons.star,
                                color: isFavorite ? Colors.yellow : Colors.grey,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network('assets/images/parking_logo.png',
                              width: 100, height: 100),
                          SizedBox(height: 10),
                          Text(updatedParking.address,
                              style: TextStyle(fontSize: 16)),
                          SizedBox(height: 10),
                          InkWell(
                            child: Text(
                              updatedParking.mapsUrl,
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 16),
                            ),
                            onTap: () async {
                              if (await canLaunch(updatedParking.mapsUrl)) {
                                await launch(updatedParking.mapsUrl);
                              } else {
                                throw 'Could not launch ${updatedParking.mapsUrl}';
                              }
                            },
                          ),
                          SizedBox(height: 20),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Filled: ${updatedParking.filledCount}/${updatedParking.maxSpots}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _getOccupancyColor(
                                    updatedParking.filledCount,
                                    updatedParking.maxSpots),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
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
