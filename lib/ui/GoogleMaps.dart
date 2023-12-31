import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:erazor_partner/common/loader.dart';
import 'package:erazor_partner/controllers/firebase_controller.dart';
import 'package:erazor_partner/models/location_details.dart';
import 'package:erazor_partner/theme/theme.dart';
import 'package:erazor_partner/ui/SignupScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:routemaster/routemaster.dart';

final latlnghashProvider = StateProvider<SalonLocationDetails>(
    (ref) => SalonLocationDetails(uid: '', geoPoint: {}));

class GoogleMapScreen extends ConsumerStatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GoogleMapScreenState();
}

class _GoogleMapScreenState extends ConsumerState<GoogleMapScreen> {
  late GoogleMapController mapController;
  var mapTextController = TextEditingController();
  //GeoHasher geohasher = GeoHasher();
  final geo = GeoFlutterFire();

  List<dynamic> placesList = [];
  //Position? _currentPosition;

  //LatLng _center = const LatLng(28.644800, 77.216721);

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void fetchSuggestions(String input, String sessionToken) async {
    String API_KEY = 'AIzaSyD0Rt39qxznXX1nx7lWUnqrcWtHBc796us';
    String baseUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseUrl?input=$input&key=$API_KEY&sessiontoken=$sessionToken';

    var response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      setState(() {
        placesList = jsonDecode(response.body.toString())['predictions'];
      });
    } else {
      throw Exception('Failed to load data!');
    }
  }

  // Future<bool> _handleLocationPermission() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //           content: Text(
  //               'Location services are disabled. Please enable the services')));
  //     }
  //     serviceEnabled = await Geolocator.openLocationSettings();
  //     setState(() {});
  //     //return false;
  //   }
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(content: Text('Location permissions are denied')));
  //       }
  //       return false;
  //     }
  //   }
  //   if (permission == LocationPermission.deniedForever) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //           content: Text(
  //               'Location permissions are permanently denied, we cannot request permissions.')));
  //     }
  //     return false;
  //   }
  //   return true;
  // }

  // Future<void> _getCurrentPosition() async {
  //   final hasPermission = await _handleLocationPermission();
  //   if (!hasPermission) return;
  //   await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
  //       .then((Position position) {
  //     setState(() {
  //       //_currentPosition = position;
  //       _center = LatLng(position.latitude, position.longitude);
  //     });
  //     //_getAddressFromLatLng(_currentPosition!);
  //   }).catchError((e) {
  //     debugPrint(e);
  //   });
  // }

  @override
  void initState() {
    //_getCurrentPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String sToken = ref.watch(salonDetailsProvider)!.cid;
    //Position pos = ref.watch(currentLocationProvider)!;
    LatLng center = ref.watch(currentLocationProvider)!;

    String currentAddress = ref.watch(currentAddressProvider)!;
    //LatLng center = LatLng(pos.latitude, pos.longitude);
    mapTextController.text = currentAddress;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30))),
        title: const Text('Choose your location'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final gp = geo
              .point(latitude: center.latitude, longitude: center.longitude)
              .data;
          ref
              .watch(latlnghashProvider.notifier)
              .update((state) => SalonLocationDetails(uid: '', geoPoint: gp));
          // ref
          //     .watch(firebaseControllerProvider.notifier)
          //     .insertSalonLocation(context: context, object: gp);
          Routemaster.of(context).pop();
        },
        label: const Text('Confirm Location'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            // markers: {
            //   Marker(
            //       markerId: const MarkerId('myLocation'),
            //       position: center,
            //       draggable: true)
            // },
            initialCameraPosition: CameraPosition(target: center, zoom: 18.0),
            onCameraMove: (position) {
              //center = position.target;
              ref
                  .watch(currentLocationProvider.notifier)
                  .update((state) => position.target);

              //mapController.animateCamera(CameraUpdate.newCameraPosition(position));
            },
            onCameraIdle: () async {
              await placemarkFromCoordinates(center.latitude, center.longitude)
                  .then((value) {
                //print('valueeee $value');
                ref.watch(currentAddressProvider.notifier).update((state) =>
                    '${value[0].street}, ${value[0].subLocality}, ${value[0].locality}, ${value[0].administrativeArea}');
              }).catchError((e) {
                debugPrint(e);
              });
            },
          ),
          const Center(
            child: Icon(
              Icons.location_on,
              size: 40,
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            left: 10,
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      style: Theme.of(context).textTheme.bodySmall,
                      controller: mapTextController,
                      onChanged: (text) => setState(() {
                        ref
                            .watch(currentAddressProvider.notifier)
                            .update((state) => text);
                        fetchSuggestions(text, sToken);
                      }),
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Blue001, width: 2))),
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: placesList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              placesList[index]['description'],
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onTap: () async {
                              var locations = await locationFromAddress(
                                  placesList[index]['description']);
                              var lat = locations.first.latitude;
                              var lng = locations.first.longitude;
                              print('lat $lat lng $lng');
                              setState(() {
                                mapController.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                            target: LatLng(lat, lng),
                                            zoom: 18)));
                              });
                              placesList.clear();
                            },
                          );
                        })
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
