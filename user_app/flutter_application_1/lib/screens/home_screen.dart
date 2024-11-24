import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/constants.dart';
import 'package:flutter_application_1/config/aut_service.dart';
import 'package:flutter_application_1/pages/pages.dart';
import 'package:flutter_application_1/widgets/widgets.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/config/firebase_logic.dart';
import 'package:flutter_application_1/config/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = authService.isLoggedIn();
    if (!isLoggedIn) {
      context.go("/login");
    }

    bool mobile =
        MediaQuery.of(context).size.width > maxMobileSize ? false : true;
    if (mobile || !kIsWeb) {
      return Scaffold(
        appBar: const CustomAppBar(title: "Home"),
        drawer: customDrawer(context),
        body: Column(
          children: [
            // Left side: HomePage (or other main content)
            Expanded(
              flex: 4, // This takes 3 parts of the width
              child: const HomePage(), // Your HomePage widget
            ),
            // Right side: List of favorite cards
            Expanded(
              flex: 1, // This takes 2 parts of the width
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildFavoriteCards(context),
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: const CustomAppBar(title: "Login"),
        drawer: customDrawer(context),
        body: Row(
          children: [
            // Left side: HomePage (or other main content)
            Expanded(
              flex: 4, // This takes 3 parts of the width
              child: const HomePage(), // Your HomePage widget
            ),
            // Right side: List of favorite cards
            Expanded(
              flex: 1, // This takes 2 parts of the width
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildFavoriteCards(context),
              ),
            ),
          ],
        ),
      );
    }
  }
}

// This method builds the list of favorite cards
Widget _buildFavoriteCards(BuildContext context) {
  return StreamBuilder<Map<String, bool>>(
    stream: firestoreService
        .readUsersFavoritesStream(), // Listen for changes in favorites
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        print("Error fetching favorites: ${snapshot.error}");
        return const Center(child: Text('Error fetching favorites.'));
      }

      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(child: Text('No favorites available.'));
      }

      // Get the list of document IDs from the favorite parking map
      List<String> favoriteParkingIds = snapshot.data!.keys.toList();

      return StreamBuilder<List<Parking>>(
        stream: firestoreService.getParkingsByIdsStream(
            favoriteParkingIds), // Use your stream method here
        builder: (context, parkingSnapshot) {
          if (parkingSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (parkingSnapshot.hasError) {
            print("Error fetching parkings: ${parkingSnapshot.error}");
            return const Center(child: Text('Error fetching parking details.'));
          }

          if (!parkingSnapshot.hasData || parkingSnapshot.data!.isEmpty) {
            return const Center(child: Text('No parking details available.'));
          }

          List<Parking> parkings = parkingSnapshot.data!;

          return ListView.builder(
            itemCount: parkings.length,
            itemBuilder: (context, index) {
              Parking parking = parkings[index];
              bool isFavorite = snapshot.data![parking.id] ?? false;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.star, color: Colors.yellow),
                  title: Text(parking.name),
                  subtitle: Text(parking.address),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('parkings')
                              .doc(parking.id)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            var data =
                                snapshot.data!.data() as Map<String, dynamic>;
                            Parking updatedParking =
                                Parking.fromFirestore(snapshot.data!);

                            return AlertDialog(
                              title: StatefulBuilder(
                                builder: (context, setState) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          updatedParking.name,
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isFavorite = !isFavorite;
                                          });
                                          firestoreService
                                              .removeParkingFromFavorites(
                                                  parking.id);
                                        },
                                        child: Icon(
                                          Icons.star,
                                          color: isFavorite
                                              ? Colors.yellow
                                              : Colors.grey,
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
                                    Image.network(
                                        'assets/images/parking_logo.png',
                                        width: 100,
                                        height: 100),
                                    const SizedBox(height: 10),
                                    Text(updatedParking.address,
                                        style: const TextStyle(fontSize: 16)),
                                    const SizedBox(height: 10),
                                    InkWell(
                                      child: Text(
                                        updatedParking.mapsUrl,
                                        style: const TextStyle(
                                            color: Colors.blue, fontSize: 16),
                                      ),
                                      onTap: () async {
                                        if (await canLaunch(
                                            updatedParking.mapsUrl)) {
                                          await launch(updatedParking.mapsUrl);
                                        } else {
                                          throw 'Could not launch ${updatedParking.mapsUrl}';
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 20),
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
                                    const SizedBox(height: 20),
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
                ),
              );
            },
          );
        },
      );
    },
  );
}

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
