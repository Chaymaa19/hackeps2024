import 'package:cloud_firestore/cloud_firestore.dart';

class Parking {
  String name;
  String description;
  String address;
  GeoPoint coordinates;
  int maxSpots;
  int filledCount; // Number of filled spots
  String mapsUrl;

  Parking({
    required this.name,
    required this.description,
    required this.address,
    required this.coordinates,
    required this.maxSpots,
    required this.mapsUrl,
    this.filledCount = 0, // Default filled count is 0
  });

  factory Parking.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Retrieve individual parameters
    String name = data['name'] ?? '';
    String description = data['description'] ?? '';
    String address = data['address'] ?? '';
    GeoPoint coordinates = data['coordinates'] as GeoPoint;
    int maxSpots = data['maxSpots'] ?? 0;
    List<dynamic> spots = data['spots'] ?? [];
    String mapsUrl = data['mapsUrl'] ?? '';

    // Count filled spots
    int filledCount = spots.where((spot) => spot['filled'] == true).length;

    return Parking(
        name: name,
        description: description,
        address: address,
        coordinates: coordinates,
        maxSpots: maxSpots,
        filledCount: filledCount,
        mapsUrl: mapsUrl);
  }
}
