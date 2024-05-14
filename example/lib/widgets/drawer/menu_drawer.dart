import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_example/pages/allData.dart';
import 'package:flutter_map_example/pages/animated_map_controller.dart';
import 'package:flutter_map_example/pages/bundled_offline_map.dart';
import 'package:flutter_map_example/pages/cancellable_tile_provider.dart';
import 'package:flutter_map_example/pages/circle.dart';
import 'package:flutter_map_example/pages/custom_crs/custom_crs.dart';
import 'package:flutter_map_example/pages/debouncing_tile_update_transformer.dart';
import 'package:flutter_map_example/pages/epsg3413_crs.dart';
import 'package:flutter_map_example/pages/epsg4326_crs.dart';
import 'package:flutter_map_example/pages/fallback_url_page.dart';
import 'package:flutter_map_example/pages/home.dart';
import 'package:flutter_map_example/pages/interactive_test_page.dart';
import 'package:flutter_map_example/pages/latlng_to_screen_point.dart';
import 'package:flutter_map_example/pages/many_circles.dart';
import 'package:flutter_map_example/pages/many_markers.dart';
import 'package:flutter_map_example/pages/map_controller.dart';
import 'package:flutter_map_example/pages/map_inside_listview.dart';
import 'package:flutter_map_example/pages/markers.dart';
import 'package:flutter_map_example/pages/overlay_image.dart';
import 'package:flutter_map_example/pages/plugin_zoombuttons.dart';
import 'package:flutter_map_example/pages/polygon.dart';
import 'package:flutter_map_example/pages/polygon_perf_stress.dart';
import 'package:flutter_map_example/pages/polyline.dart';
import 'package:flutter_map_example/pages/polyline_perf_stress.dart';
import 'package:flutter_map_example/pages/reset_tile_layer.dart';
import 'package:flutter_map_example/pages/retina.dart';
import 'package:flutter_map_example/pages/scalebar.dart';
import 'package:flutter_map_example/pages/screen_point_to_latlng.dart';
import 'package:flutter_map_example/pages/secondary_tap.dart';
import 'package:flutter_map_example/pages/showData.dart';
import 'package:flutter_map_example/pages/sliding_map.dart';
import 'package:flutter_map_example/pages/tile_builder.dart';
import 'package:flutter_map_example/pages/tile_loading_error_handle.dart';
import 'package:flutter_map_example/pages/wms_tile_layer.dart';
import 'package:flutter_map_example/widgets/drawer/menu_item.dart';
import 'package:url_launcher/url_launcher.dart';

class MenuDrawer extends StatelessWidget {
  final String currentRoute;

  const MenuDrawer(this.currentRoute, {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _getCurrentUserDocStream(), // Get user doc stream
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final userData = snapshot.data!.data();
          if (userData != null) {
            final String userName = userData['fullName'] as String;
            final String userEmail =
                userData['email'] as String; // Cast to String
                final String userType =
                userData['userType'] as String;
                
            return Drawer(
              child: ListView(
                children: <Widget>[
                  DrawerHeader(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/ProjectIcon.png',
                          height: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          userEmail,
                        ),
                        
                      ],
                    ),
                  ),
                  MenuItemWidget(
                    caption: 'Home',
                    routeName: ScreenPointToLatLngPage.route,
                    currentRoute: currentRoute,
                    icon: const Icon(Icons.home),
                  ),
                  const Divider(),
               if(userType == 'admin')
                MenuItemWidget(
                    caption: 'All Data',
                    routeName: AllData.route,
                    currentRoute: currentRoute,
                    icon: const Icon(Icons.home),
                  ),
                  const Divider(),
                  
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: InkWell(
                        onTap: _launchURL,
                        child: const Text(
                          '@Powered by Supersoft Technologies',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ),
                  

                ],
              ),
            );
          } else {
            // Handle case where user data is null
            return const Text('Error retrieving user data');
          }
        } else if (snapshot.hasError) {
          print('Error fetching user data: ${snapshot.error}');
          return const Text('Error retrieving user data');
        }

        // Display a loading indicator while fetching data (optional)
        return const DrawerHeader(
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  // Stream to get current user document
  Stream<DocumentSnapshot<Map<String, dynamic>>> _getCurrentUserDocStream() {
    final FirebaseAuth auth = FirebaseAuth.instance;

    final String? userId = auth.currentUser?.uid; // Get current user ID
    if (userId == null) {
      return Stream.error('No user signed in'); // Handle no signed-in user
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots();
  }
}

_launchURL() async {
  Uri _url = Uri.parse('https://supersofttechnology.com/');
  if (await launchUrl(_url)) {
    await launchUrl(_url);
  } else {
    throw 'Could not launch $_url';
  }
}
  // MenuItemWidget(
          //   caption: 'Polygon Layer',
          //   routeName: PolygonPage.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Polyline Layer',
          //   routeName: PolylinePage.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Circle Layer',
          //   routeName: CirclePage.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Overlay Image Layer',
          //   routeName: OverlayImagePage.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Scale Bar Layer',
          //   routeName: ScaleBarPage.route,
          //   currentRoute: currentRoute,
          // ),
          // const Divider(),
          // MenuItemWidget(
          //   caption: 'Map Controller',
          //   routeName: MapControllerPage.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Animated Map Controller',
          //   routeName: AnimatedMapControllerPage.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Interactive Flags',
          //   routeName: InteractiveFlagsPage.route,
          //   currentRoute: currentRoute,
          // ),
          // const Divider(),
          // MenuItemWidget(
          //   caption: 'WMS Sourced Map',
          //   routeName: WMSLayerPage.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Bundled Offline Map',
          //   routeName: BundledOfflineMapPage.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Fallback URL',
          //   routeName: FallbackUrlPage.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Cancellable Tile Provider',
          //   routeName: CancellableTileProviderPage.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Debouncing Tile Update Transformer',
          //   routeName: DebouncingTileUpdateTransformerPage.route,
          //   currentRoute: currentRoute,
          // ),
          // const Divider(),
          // MenuItemWidget(
          //   caption: 'Polygon Stress Test',
          //   routeName: PolygonPerfStressPage.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Polyline Stress Test',
          //   routeName: PolylinePerfStressPage.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Many Markers',
          //   routeName: ManyMarkersPage.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Many Circles',
          //   routeName: ManyCirclesPage.route,
          //   currentRoute: currentRoute,
          // ),
          // const Divider(),
          // MenuItemWidget(
          //   caption: 'Zoom Buttons Plugin',
          //   routeName: PluginZoomButtons.route,
          //   currentRoute: currentRoute,
          // ),
          // const Divider(),
          // MenuItemWidget(
          //   caption: 'Custom CRS',
          //   routeName: CustomCrsPage.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'EPSG4326 CRS',
          //   currentRoute: currentRoute,
          //   routeName: EPSG4326Page.route,
          // ),
          // MenuItemWidget(
          //   caption: 'EPSG3413 CRS',
          //   currentRoute: currentRoute,
          //   routeName: EPSG3413Page.route,
          // ),
          // const Divider(),
          // MenuItemWidget(
          //   caption: 'Sliding Map',
          //   routeName: SlidingMapPage.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Map Inside Scrollable',
          //   routeName: MapInsideListViewPage.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Secondary Tap',
          //   routeName: SecondaryTapPage.route,
          //   currentRoute: currentRoute,
          // ),
          // const Divider(),
          // MenuItemWidget(
          //   caption: 'Custom Tile Error Handling',
          //   routeName: TileLoadingErrorHandle.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Custom Tile Builder',
          //   routeName: TileBuilderPage.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Retina Tile Layer',
          //   routeName: RetinaPage.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Reset Tile Layer',
          //   routeName: ResetTileLayerPage.route,
          //   currentRoute: currentRoute,
          // ),
