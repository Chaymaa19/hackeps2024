import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/config/firebase_logic.dart';

AuthService authService = AuthService();

class AuthService {
  // Private constructor for singleton pattern
  AuthService._privateConstructor();

  static final AuthService _instance = AuthService._privateConstructor();

  // Factory constructor to return the singleton instance
  factory AuthService() {
    return _instance;
  }

  // Declare user_credentials as nullable
  UserCredential? user_credentials;

  // Method to check if the user is logged in
  bool isLoggedIn() {
    return user_credentials != null;
  }

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      user_credentials = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return user_credentials;
    } catch (e) {
      print("Error signing in: $e");
      return null;
    }
  }

  Future<UserCredential?> signUp(String email, String password) async {
    try {
      user_credentials =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add a user entry to Firestore
      if (user_credentials != null) {
        await firestoreService.registerUser(user_credentials!.user!.uid, email);
      }

      return user_credentials;
    } catch (e) {
      print("Error signing up: $e");
      return null;
    }
  }

  // Example method to sign out
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    user_credentials = null; // Clear the user_credentials when signing out
  }
}
