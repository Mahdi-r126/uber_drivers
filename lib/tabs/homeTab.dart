import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../brand_colors.dart';
import '../globalVar.dart';
import '../widgets/confirmSheet.dart';
import '../widgets/taxiButton.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();

  var geolocator = Geolocator();
  late Position currentPosition;
  late String id;

  var locationOptions = LocationOptions(
      accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 1);

  String availabilityTitle = "روشن";
  Color availabilityColor = BrandColors.colorOrange;
  bool isAvailable = false;

  void SetCurrentLocation() async {
    Position position = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;
    LatLng pos = LatLng(position.latitude, position.longitude);
    print("Lat:${pos.latitude} , Lng:${pos.longitude}");
    CameraPosition cp = CameraPosition(target: pos, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));
  }

  static const CameraPosition _kLake = CameraPosition(
      target: LatLng(37.43296265331129, -122.08832357078792),
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        GoogleMap(
          padding: const EdgeInsets.only(top: 135),
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          zoomControlsEnabled: false,
          zoomGesturesEnabled: true,
          initialCameraPosition: _kLake,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            mapController = controller;
            SetCurrentLocation();
          },
        ),
        Positioned(
          top: 0,
          right: 0,
          left: 0,
          child: Container(
            height: 135,
            color: BrandColors.colorPrimary,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 70, bottom: 20, right: 110, left: 110),
              child: TaxiButton(
                color: availabilityColor,
                title: availabilityTitle,
                onPressed: () {
                  if (isAvailable == false) {
                    showModalBottomSheet(
                        isDismissible: false,
                        context: context,
                        builder: (BuildContext context) => ConfirmSheet(
                            title: "آیا برای پذیرفتن مسافر مطمئنید؟",
                            isOn: true,
                            onPressed: () {
                              GeoOnline();
                              getLocationUpdate();
                              Navigator.pop(context);
                              setState(() {
                                isAvailable = true;
                                availabilityColor = BrandColors.colorGreen;
                                availabilityTitle = "خاموش";
                              });
                            }));
                  } else {
                    showModalBottomSheet(
                        isDismissible: false,
                        context: context,
                        builder: (BuildContext context) => ConfirmSheet(
                            title: "آیا برای توقف مسافرگیری مطمئنید؟",
                            isOn: false,
                            onPressed: () {
                              goOffline();
                              Navigator.pop(context);
                              setState(() {
                                isAvailable = false;
                                availabilityColor = BrandColors.colorOrange;
                                availabilityTitle = "روشن";
                              });
                            }));
                  }
                },
              ),
            ),
          ),
        )
      ],
    ));
  }

  void GeoOnline() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id');
    Geofire.initialize("driversAvailable");
    Geofire.setLocation(
        id, currentPosition.latitude, currentPosition.longitude);

    tripRequestRef =
        FirebaseDatabase.instance.reference().child("drivers/${id}/newtrip");

    tripRequestRef.set("waiting");

    tripRequestRef.onValue.listen((event) {});
  }

  void goOffline() {
    Geofire.removeLocation(id);
    tripRequestRef.onDisconnect();
    tripRequestRef.remove();
  }

  void getLocationUpdate() {
    homeTabPositionStream = geolocator
        .getPositionStream(locationOptions)
        .listen((Position position) {
      currentPosition = position;
      if(isAvailable){
        Geofire.setLocation(id, position.latitude, position.longitude);
      }
      LatLng pos = LatLng(position.latitude, position.longitude);
      mapController.animateCamera(CameraUpdate.newLatLng(pos));
    });
  }
}
