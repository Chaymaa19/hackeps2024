import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/config/models.dart';

FirebaseService firestoreService = FirebaseService();

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseFirestore getFirestore() {
    return _firestore;
  }

  Future<List<Parking>> getParkings() async {
    try {
      // Fetch all documents in the 'parkings' collection
      QuerySnapshot snapshot = await _firestore.collection('parkings').get();

      // Map the documents to a list of `Parking` objects
      List<Parking> parkingList = snapshot.docs.map((doc) {
        return Parking.fromFirestore(doc);
      }).toList();

      return parkingList;
    } catch (e) {
      // Handle error (e.g., network error, permission issue)
      print('Error fetching parkings: $e');
      return [];
    }
  }
}
