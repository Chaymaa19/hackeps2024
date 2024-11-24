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

  Future<List<Parking>> getParkingsByIds(List<String> documentIds) async {
  try {
    // Fetch documents by their IDs
    List<Parking> parkingList = [];
    
    // Loop through each document ID and fetch the corresponding document
    for (String docId in documentIds) {
      // Fetch a single document by ID
      DocumentSnapshot docSnapshot = await _firestore.collection('parkings').doc(docId).get();

      // Check if the document exists
      if (docSnapshot.exists) {
        // Convert the document to a Parking object and add to the list
        parkingList.add(Parking.fromFirestore(docSnapshot));
      } else {
        print('Document with ID $docId not found');
      }
    }

    return parkingList;
  } catch (e) {
    // Handle any errors (e.g., network issue, permission issue)
    print('Error fetching parkings by IDs: $e');
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

  // Stream to listen for real-time updates of the user's favorites
  Stream<Map<String, bool>> readUsersFavoritesStream() {
    // Get the user's UID
    var userUid = authService.user_credentials!.user!.uid;

    return _firestore.collection('users').doc(userUid).snapshots().map((userDocSnapshot) {
      // Get the 'favorites' field as a list of IDs
      List<dynamic> favoritesList = userDocSnapshot['favorites'] ?? [];

      // Convert the list to a Map<String, bool> with all values set to true
      Map<String, bool> favoritesMap = {
        for (var id in favoritesList) id as String: true,
      };

      return favoritesMap;
    });
  }

  // Stream to listen for real-time updates of parking details based on IDs
  Stream<List<Parking>> getParkingsByIdsStream(List<String> documentIds) {
    // Return a stream of parking documents that updates in real time
    return FirebaseFirestore.instance
        .collection('parkings')
        .where(FieldPath.documentId, whereIn: documentIds) // Query based on the list of IDs
        .snapshots()
        .map((querySnapshot) {
      // Convert the query snapshot into a list of `Parking` objects
      return querySnapshot.docs.map((doc) {
        return Parking.fromFirestore(doc);
      }).toList();
    });
  }

  Future<void> removeParkingFromFavorites(String parkingId) async {
  try {
    // Get the user's UID
    var userUid = authService.user_credentials!.user!.uid;

    // Retrieve the user's document from Firestore
    DocumentSnapshot userDocSnapshot = await _firestore.collection('users').doc(userUid).get();

    // Get the current 'favorites' list
    List<dynamic> favoritesList = userDocSnapshot['favorites'] ?? [];

    // Remove the parking ID from the list if it exists
    favoritesList.remove(parkingId);

    // Update the user's favorites in Firestore
    await _firestore.collection('users').doc(userUid).update({
      'favorites': favoritesList,
    });

    print("Parking ID removed from favorites successfully.");
  } catch (e) {
    print("Error removing parking ID from favorites: $e");
  }
}

}
