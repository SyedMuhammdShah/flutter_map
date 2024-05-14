import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class LocationData {
  final String email;
  final String fullName;
  final String locId;
  final List<LatLng> locations; // List of LatLng objects
  final String phoneNumber; // Optional phone number
  final String userId;

  LocationData(this.email, this.fullName, this.locId, this.locations, this.phoneNumber, this.userId);

  // Factory constructor to create from a Firestore document snapshot
  factory LocationData.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    final locations = (data['locations'] as List)
        .map((location) => LatLng(location['latitude'] as double, location['longitude'] as double))
        .toList();
    return LocationData(
      data['email'] as String,
      data['fullName'] as String,
      data['locId'] as String,
      locations,
      data['phoneNumber'] as String,
      
      snapshot.id, // Use document ID as userId
    );
  }
}

class ShowDataScreen extends StatefulWidget {
   static const String route = '/showData';
  const ShowDataScreen({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ShowDataScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance
  List<LocationData> _locations = []; // List to store fetched LocationData

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Locations'),
        actions: [
          // Add a logout button if needed
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _auth.signOut(), // Handle sign out
          ),
        ],
      ),
      body: StreamBuilder<User?>(
        stream: _auth.authStateChanges(), // Listen to user changes
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('Please sign in')); // Handle non-authenticated users
          }

          // Fetch data only when a user is signed in
          if (_locations.isEmpty) {
            _fetchLocations(user.uid); // Fetch locations for the current user
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                DataTable(
              columns: const [
                DataColumn(label: Text('Full Name')),
                DataColumn(label: Text('Phone Number')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Locations')),
              ],
              rows: _locations.map((location) => DataRow(cells: [
                DataCell(Text(location.fullName)),
                DataCell(Text(location.phoneNumber)),
                DataCell(Text(location.email)),
                DataCell(
                  Wrap(
                    children: location.locations.asMap().entries.map((entry) {
            final index = entry.key + 1;
            return Text('Location ${index}: \n${entry.value.latitude.toStringAsFixed(3)}, ${entry.value.longitude.toStringAsFixed(3)}\n');
                    }).toList(),
                  ),
                ),
              ])).toList(),
            ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _fetchLocations(String userId) async {
    final querySnapshot = await _firestore
        .collection('savelocation') // Replace 'locations' with your actual collection name
        .where('userId', isEqualTo: userId) // Filter by user ID
        .get();
   print( "Hello $querySnapshot");
    setState(() {
      _locations = querySnapshot.docs.map((doc) => LocationData.fromSnapshot(doc)).toList();
    });
  }
}
