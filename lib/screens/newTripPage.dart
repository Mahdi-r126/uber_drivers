import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_drivers/brand_colors.dart';
import 'package:uber_drivers/globalVar.dart';
import 'package:uber_drivers/models/directionDetails.dart';
import 'package:uber_drivers/models/tripDetails.dart';
import 'package:uber_drivers/widgets/Text.dart';

import '../helpers/helpermethodes.dart';
import '../widgets/ProgressDialog.dart';

class NewTripPage extends StatefulWidget {
  final TripDetails tripDetails;
  NewTripPage({required this.tripDetails});

  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  late GoogleMapController rideMapController;
  final Completer<GoogleMapController> _controller = Completer();
  final CameraPosition _kLake = const CameraPosition(
      target: LatLng(37.43296265331129, -122.08832357078792),
      zoom: 19.151926040649414);

  Set<Marker> _markers = Set<Marker>();
  Set<Circle> _circles = Set<Circle>();
  Set<Polyline> _polyLines = Set<Polyline>();
  var latLngCoordinates;

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  var directionDetails;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    acceptTrip();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        GoogleMap(
          padding: const EdgeInsets.only(top: 50),
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          zoomControlsEnabled: false,
          zoomGesturesEnabled: true,
          markers: _markers,
          polylines: _polyLines,
          circles: _circles,
          initialCameraPosition: _kLake,
          onMapCreated: (GoogleMapController controller) async {
            _controller.complete(controller);
            rideMapController = controller;

            var currentLatLng =
                LatLng(currentPosition.latitude, currentPosition.longitude);
            var pickupLatLng = widget.tripDetails.pickup;
            await getDirection(currentLatLng, pickupLatLng!);
          },
        ),
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 250,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 15,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7))
                ]),
            child: Column(
              textDirection: TextDirection.rtl,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: PersianTextField(
                    text: "14 دقیقه",
                    textSize: 14,
                    fontWeight: FontWeight.bold,
                    color: BrandColors.colorAccentPurple,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  textDirection: TextDirection.rtl,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PersianTextField(
                      text: "مهدی رضایی",
                      textSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    const Icon(
                      Icons.call,
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    Image.asset("assets/images/pickicon.png", width: 20),
                    const SizedBox(
                      width: 3,
                    ),
                    Expanded(
                      child: PersianTextField(
                        text: widget.tripDetails.pickupAddress.toString(),
                        textSize: 16,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    Image.asset("assets/images/redmarker.png", width: 20),
                    const SizedBox(
                      width: 3,
                    ),
                    Expanded(
                      child: PersianTextField(
                        text: widget.tripDetails.destinationAddress.toString(),
                        textSize: 16,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: MaterialButton(
                    color: BrandColors.colorGreen,
                    height: 40,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    onPressed: () {},
                    child: PersianTextField(
                        text: "رسیدن به مقصد",
                        color: Colors.white,
                        textSize: 17),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    ));
  }

  void acceptTrip() {
    String tripId = widget.tripDetails.tripId.toString();
    acceptTripRef =
        FirebaseDatabase.instance.reference().child("rideRequest/$tripId");

    acceptTripRef.child("status").set("accepted");
    acceptTripRef.child("driver_name").set(currentDriverInfo.fullName);
    acceptTripRef
        .child("car_details")
        .set("${currentDriverInfo.carColor} - ${currentDriverInfo.carModel}");
    acceptTripRef.child("driver_phone").set(currentDriverInfo.phone);
    acceptTripRef.child("driver_id").set(currentDriverInfo.id);

    Map locationMap = {
      'latitude': currentPosition.latitude.toString(),
      'longitude': currentPosition.longitude.toString()
    };
    acceptTripRef.child("driver_location").set(locationMap);
  }

  Future<void> getDirection(
      LatLng pickupLatLng, LatLng destinationLatLng) async {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            const ProgressDialog(status: "please wait..."));

    directionDetails = await HelperMethods.getDirectionDetails(
        pickupLatLng, destinationLatLng);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    try {
      for (int i = 0; i < directionDetails!.points!.length; i++) {
        latLngCoordinates = directionDetails.points
            ?.map<LatLng>((coord) => LatLng(coord[1], coord[0]))
            .toList();
      }
    } catch (_) {}

    print(latLngCoordinates.toString());

    _polyLines.clear();
    setState(() {
      Polyline polyline = Polyline(
          polylineId: PolylineId('polyid'),
          color: const Color.fromARGB(255, 16, 38, 235),
          points: latLngCoordinates,
          jointType: JointType.round,
          width: 4,
          visible: true,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true);

      _polyLines.add(polyline);
    });

    LatLngBounds bounds;

    if (pickupLatLng.latitude > destinationLatLng.latitude &&
        pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: destinationLatLng, northeast: pickupLatLng);
    } else if (pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickupLatLng.latitude, destinationLatLng.longitude),
          northeast:
              LatLng(destinationLatLng.latitude, pickupLatLng.longitude));
    } else if (pickupLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, pickupLatLng.longitude),
          northeast:
              LatLng(pickupLatLng.latitude, destinationLatLng.longitude));
    } else {
      bounds =
          LatLngBounds(southwest: pickupLatLng, northeast: destinationLatLng);
    }
    rideMapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(
      markerId: MarkerId("pickup"),
      position: pickupLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId("destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      _markers.add(pickupMarker);
      _markers.add(destinationMarker);
    });
  }
}
