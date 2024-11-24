import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/config/models.dart';
import 'package:flutter_application_1/config/aut_service.dart';

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

  Future<void> registerUser(String user_uid, String email) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user_uid) // Use the user's UID as the document ID
        .set({
      'email': email,
      'favorites': [],
    });
  }

  Future<void> updateUsersFavoriteParkings(
      Map<String, bool> newFavorites) async {
    // Get a list of keys (parking IDs) where the value is true
    List<String> favoriteParkings = newFavorites.entries
        .where((entry) => entry.value) // Filter for entries with value `true`
        .map((entry) => entry.key) // Extract the keys (parking IDs)
        .toList();

    // Get the user's UID
    var userUid = authService.user_credentials!.user!.uid;

    try {
      // Update the user's favorites in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userUid).update({
        'favorites': favoriteParkings,
      });
      print("Favorites updated successfully!");
    } catch (e) {
      print("Error updating favorites: $e");
    }
  }

  Future<Map<String, bool>> readUsersFavorites() async {
    // Get the user's UID
    var userUid = authService.user_credentials!.user!.uid;

    try {
      // Retrieve the user's document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .get();

      // Get the 'favorites' field as a list of IDs
      List<dynamic> favoritesList = userDoc['favorites'] ?? [];

      // Convert the list to a Map<String, bool> with all values set to true
      Map<String, bool> favoritesMap = {
        for (var id in favoritesList) id as String: true,
      };

      return favoritesMap;
    } catch (e) {
      print("Error reading user's favorites: $e");
      return {}; // Return an empty map in case of error
    }
  }
}
