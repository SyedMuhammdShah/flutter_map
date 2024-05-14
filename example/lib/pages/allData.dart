import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_example/misc/tile_providers.dart';
import 'package:flutter_map_example/pages/showData.dart';
import 'package:flutter_map_example/widgets/drawer/menu_drawer.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';

class AllData extends StatefulWidget {
  static const String route = '/AllData';

  const AllData({super.key});

  @override
  _AllDataState createState() => _AllDataState();
}

class _AllDataState extends State<AllData> {
  bool _isLoading = false;
  List<LocationData> _locations = [];
  int _pageSize = 10; // Number of documents to retrieve per page
  DocumentSnapshot? _lastDocument; // Track the last document of the previous page
 final FirebaseFirestore _firestore =    FirebaseFirestore.instance;
 final FirebaseAuth _auth = FirebaseAuth.instance;
 @override
void initState() {
  super.initState();
  _fetchLocations();
}

void _fetchLocations() async {
  setState(() {
    _isLoading = true;
  });
  final querySnapshot = await _firestore
      .collection('savelocation')
      .limit(_pageSize)
      .get();
  setState(() {
    _locations = querySnapshot.docs.map((doc) => LocationData.fromSnapshot(doc)).toList();
    _lastDocument = querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;
    _isLoading = false;
  });
}

void _fetchNextPage(String userId) async {
  setState(() {
    _isLoading = true;
  });
  final querySnapshot = await _firestore
      .collection('savelocation')
      .startAfterDocument(_lastDocument!)
      .limit(_pageSize)
      .get();
  setState(() {
    _locations.addAll(querySnapshot.docs.map((doc) => LocationData.fromSnapshot(doc)));
    _lastDocument = querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;
    _isLoading = false;
  });
}

Future<void> _exportToCSV() async {
  try {
    List<List<dynamic>> csvData = [
      ['Full Name', 'Phone Number', 'Email', 'Locations']
    ];

    // Add data from _locations to csvData
    for (LocationData location in _locations) {
      List<String> locations = location.locations
          .map((latLng) =>
              '${latLng.latitude.toStringAsFixed(3)}, ${latLng.longitude.toStringAsFixed(3)}')
          .toList();
      csvData.add([
        location.fullName,
        location.phoneNumber,
        location.email,
        locations.join(';'), // Join multiple locations with a delimiter
      ]);
    }

    String csv = const ListToCsvConverter().convert(csvData);

    // Get the application documents directory
    final directory = await getApplicationDocumentsDirectory();
    final String path = '${directory.path}/location_data.csv';

    File file = File(path);
    await file.writeAsString(csv);

    // Show a dialog to indicate the file has been saved
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('CSV Exported'),
        content: Text('CSV file has been saved to $path'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  } catch (error) {
    // Show an error dialog if any errors occur
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Error'),
        content: Text('Failed to export CSV file. Error: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Locations'),
        actions: [
           IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportToCSV, // Call _exportToCSV method on button press
          ),
        ],
      ),
      body: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('Please sign in'));
          }

          if (!_isLoading && _locations.isEmpty) {
            _fetchLocations();
          }

          return  SingleChildScrollView(
  child: SingleChildScrollView(
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
                children: location.locations
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key + 1;
                  return Text(
                      'Location ${index}: \n${entry.value.latitude.toStringAsFixed(3)}, ${entry.value.longitude.toStringAsFixed(3)}\n');
                }).toList(),
              ),
            ),
          ])).toList(),
        ),
        ElevatedButton(
          onPressed: () => _fetchNextPage(user.uid),
          child: Text('Load More'),
        ),
      ],
    ),
  ),
);
        },
      ),
    );
  }


}
