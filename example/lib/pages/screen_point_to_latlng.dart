// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_map_example/misc/tile_providers.dart';
// import 'package:flutter_map_example/widgets/drawer/menu_drawer.dart';
// import 'package:latlong2/latlong.dart';

// class ScreenPointToLatLngPage extends StatefulWidget {
//   static const String route = '/screen_point_to_latlng';

//   const ScreenPointToLatLngPage({super.key});

//   @override
//   PointToLatlngPage createState() => PointToLatlngPage();
// }

// class PointToLatlngPage extends State<ScreenPointToLatLngPage> {
//   static const double pointSize = 65;
//   static const double pointY = 250;

//   final mapController = MapController();

//   LatLng? latLng;
//   LatLng? location1;
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => updatePoint(context));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Screen Point Lat/Lng')),
//       drawer: const MenuDrawer(ScreenPointToLatLngPage.route),
//       body: Stack(
//         children: [
//           FlutterMap(
//             mapController: mapController,
//             options: MapOptions(
//               onPositionChanged: (_, __) => updatePoint(context),
//               initialCenter: const LatLng(51.5, -0.09),
//               initialZoom: 5,
//               minZoom: 3,
//             ),
//             children: [
//               openStreetMapTileLayer,
//               if (latLng != null)
//                 MarkerLayer(
//                   markers: [
//                     Marker(
//                       width: pointSize,
//                       height: pointSize,
//                       point: latLng!,
//                       child: const Icon(
//                         Icons.circle,
//                         size: 10,
//                         color: Colors.black,
//                       ),
//                     )
//                   ],
//                 ),
//             ],
//           ),
//           Positioned(
//             top: pointY - pointSize / 2,
//             left: _getPointX(context) - pointSize / 2,
//             child: const IgnorePointer(
//               child: Icon(
//                 Icons.center_focus_strong_outlined,
//                 size: pointSize,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//           Positioned(
//             top: pointY + pointSize / 2 + 6,
//             left: 0,
//             right: 0,
//             child: IgnorePointer(
//                 child: Column(
//               children: [
//                 Text(
//                   '(${latLng?.latitude.toStringAsFixed(3)},${latLng?.longitude.toStringAsFixed(3)})',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             )),
//           ),
//           Row(
//             children: [
//               ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       setState(() {
//                         location1 =
//                             latLng; // Update location1 with current latLng
//                       });
//                     });
//                   },
//                   child: Text("Get Locaiton")),
//               Column(children: [

//                 Text("Location 1: ${location1?.toString() ?? ''}"), 
//               ],)
//             ],
//           )
//         ],
//       ),
//     );
//   }

//   void updatePoint(BuildContext context) => setState(() => latLng =
//       mapController.camera.pointToLatLng(Point(_getPointX(context), pointY)));

//   double _getPointX(BuildContext context) =>
//       MediaQuery.sizeOf(context).width / 2;
// }
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
class ScreenPointToLatLngPage extends StatefulWidget {
  static const String route = '/screen_point_to_latlng';

  const ScreenPointToLatLngPage({super.key});

  @override
  PointToLatlngPage createState() => PointToLatlngPage();
}

class PointToLatlngPage extends State<ScreenPointToLatLngPage> {
  static const double pointSize = 65;
  static const double pointY = 250;
String newId = Uuid().v4();
  final mapController = MapController();
  LatLng? latLng;
  List<LatLng?> locations = []; // List to store picked locations

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => updatePoint(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      drawer: const MenuDrawer(ScreenPointToLatLngPage.route),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              onPositionChanged: (_, __) => updatePoint(context),
              initialCenter: const LatLng(51.5, -0.09),
              initialZoom: 5,
              minZoom: 3,
            ),
            children: [
              openStreetMapTileLayer,
              if (latLng != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: pointSize,
                      height: pointSize,
                      point: latLng!,
                      child: const Icon(
                        Icons.circle,
                        size: 10,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: pointY - pointSize / 2,
            left: _getPointX(context) - pointSize / 2,
            child: const IgnorePointer(
              child: Icon(
                Icons.center_focus_strong_outlined,
                size: pointSize,
                color: Colors.black,
              ),
            ),
          ),
                    Positioned(
            top: pointY + pointSize / 2 + 6,
            left: 0,
            right: 0,
            child: IgnorePointer(
                child: Column(
              children: [
                Text(
                  '(${latLng?.latitude.toStringAsFixed(3)},${latLng?.longitude.toStringAsFixed(3)})',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            )),
          ),
          Positioned(
            top: 20.0, // Adjust position as needed
            left: 10.0, // Adjust position as needed
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30,),
                for (int i = 0; i < locations.length; i++)
                  Text(
                    'Location ${i + 1}: ${locations[i]?.latitude.toStringAsFixed(3)}, ${locations[i]?.longitude.toStringAsFixed(3)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    color: Colors.red,

                      fontSize: 16,
                    ),
                  ),
              ],
            ),
          ),
         Positioned(
          top: 10.0, // Adjust position as needed
            left: 10.0,
          child:  Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (locations.length < 30) {
                      locations.add(latLng); // Add current latLng to list
                    } else {
                      // Show a message or handle exceeding limit
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Maximum 2 locations allowed'),
                        ),
                      );
                    }
                  });
                },
                child: const Text("Get Location"),
              ),
            ],
          ),),
        Positioned(
          top: 10.0, // Adjust position as needed
            left: 200.0,
          child:  Row(
            children: [
              ElevatedButton(
                onPressed: () {
                Get.to(ShowDataScreen());
                },
                child: const Text("All Data"),
              ),
            ],
          ),),
        ],
      ),
        floatingActionButton: FloatingActionButton(
      onPressed: () {
       _showFormDialog(context);
      },
      child: const Icon(Icons.add)
        )
    );
  }

  void updatePoint(BuildContext context) => setState(() => latLng =
      mapController.camera.pointToLatLng(Point(_getPointX(context), pointY)));

  double _getPointX(BuildContext context) => MediaQuery.sizeOf(context).width / 2;

   void _showFormDialog(BuildContext context) {
    String fullName = '';
    String email = '';
    String phoneNumber = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (int i = 0; i < locations.length; i++)
                  Text(
                    'Location ${i + 1}: ${locations[i]?.latitude.toStringAsFixed(3)}, ${locations[i]?.longitude.toStringAsFixed(3)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                TextField(
                  onChanged: (value) {
                    fullName = value;
                  },
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                TextField(
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  onChanged: (value) {
                    phoneNumber = value;
                  },
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _submitForm(fullName, email, phoneNumber, locations);
                    Navigator.of(context).pop(); // Close the dialog
                    _showSuccessDialog(context);
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
Future<void> _submitForm(
  String fullName,
  String email,
  String phoneNumber,
  List<LatLng?> locations,
) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    if (user != null) {
       print("Data ${fullName} + ${email} +  ${phoneNumber} + ${user.uid} +  ${locations} +  ${newId}");
      //  await _firestore.collection("savelocation").doc(user.uid).set({
      //   'locId': newId,
      //   'fullName': fullName,
      //   'email': email,
      //   'phoneNumber': phoneNumber,
      //   'userId': user.uid,
      //   'locations': _prepareLocationsData(locations),// Consider if necessary (user.uid already provides the ID)
      //   });
       // Prepare data to be saved
      Map<String, dynamic> userData = {
        'locId': newId,
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'userId': user.uid,
        'locations': _prepareLocationsData(locations),
      };

      // Add a new document to the collection using add() method
      await _firestore.collection('savelocation').add(userData);
         print("Data ${fullName} + ${email} +  ${phoneNumber} + ${user.uid} +  ${locations} + ${newId}");


      // Display success message
      _showSuccessDialog(context);
    }
  } catch (e) {
    // Handle errors
    Get.snackbar('Error', 'Something went wrong');
    print('Error submitting form: $e');
  }
}

List<Map<String, double>> _prepareLocationsData(List<LatLng?> locations) {
  return locations
      .where((location) => location != null)
      .map((location) => {
            'latitude': location!.latitude,
            'longitude': location.longitude,
          })
      .toList();
}
  
  
    void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Form Submitted Successfully'),
          content: const Text('Thank you for submitting the form.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

