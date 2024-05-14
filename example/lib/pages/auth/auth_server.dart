import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_example/pages/auth/login.dart';
import 'package:flutter_map_example/pages/dashboard.dart';
import 'package:flutter_map_example/pages/screen_point_to_latlng.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

class AuthService{
final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String usersCollection = 'users'; // Name of your user collection in Firestore

  // Register a new user with email and password, saving their data to Firestore
  Future<User?> registerUser(String email, String password, String fullName) async {
       print("data save");

    try {
        print("Data ${fullName} + ${email}");

      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
       print("data save");

      final user = userCredential.user;
       print("data save");
        print("Data ${fullName} + ${email} + ${user?.uid}}} ");

      if (user != null) {
        // Create a new user document in Firestore with additional data
        await _firestore.collection(usersCollection).doc(user.uid).set({
          'fullName': fullName,
          'email': email,
          'userId': user.uid, // Consider if necessary (user.uid already provides the ID)
          'userType': "User", // Consider if necessary (user.uid already provides the ID)
        });
        print("Data ${fullName} + ${email} + ${user.uid}}} ");
       print("data save")
;        return user;
      } else {
        return null; // Handle empty user case if needed
      }
    } on FirebaseAuthException catch (e) {
      print('Error creating user: $e');
      return null; // Handle specific FirebaseAuthException errors if desired
    } catch (e) {
      print('Error registering user: $e');
      return null; // Handle other general errors
    }
  }

  // Future<User?> loginUserWithEmailAndPassword(String email, String password) async {
  //   try {
  //     final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
  //     return userCredential.user;
  //   } catch (e) {
  //     print('Error signing in: $e');
  //     return null;
  //   }
  // }
  Future<User?> loginUserWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  Future<bool> isUserLoggedIn() async {
    final user = _auth.currentUser;
    return user != null;
  }

  Future getUserType(User user) async {
    // Implement logic to fetch user type from a reliable source (e.g., Firestore)
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      return data?['userType']; // Assuming 'userType' field exists in the document
    } else {
      print('No user document found for ${user.uid}');
      return null;
    }
  }

  Future<void> navigateToAppropriateScreen(BuildContext context) async {
    final loggedIn = await isUserLoggedIn();
    if (loggedIn) {
      final user = _auth.currentUser!;
      final userType = await getUserType(user);
      if (userType == 'admin') {
        Get.to(Dashboard());
        // Replace with actual admin screen route
      } else {
        ScreenPointToLatLngPage();
        // Replace with actual user screen route
      }
    } else {
      // Handle the case where the user is not logged in (e.g., show a login screen)
      print('User is not logged in');
    }
  }
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      Get.to(LoginScreen());
    } catch (e) {
      print('Error signing out: $e');
    }
  }

 Future<Map<String, dynamic>?> getUserData(String userId) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (snapshot.exists) {
      return snapshot.data();
    } else {
      return null;
    }
  } catch (e) {
    print('Error fetching user data: $e');
    return null;
  }
}

//  Future<void> storeUserData(String userId, String fullName, String email) async {
  
//     print('User data stored successfully');
//   try {
//     await FirebaseFirestore.instance.collection('users').doc(userId).set({
//       'fullName': fullName,
//       'email': email,
//       'userId': userId,
//     });
//     print('User data stored successfully');
//   } catch (e) {
//     print('Failed to store user data: $e');
//   }
// }


}