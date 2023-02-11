import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_drivers/brand_colors.dart';
import 'package:uber_drivers/models/tripDetails.dart';
import 'package:uber_drivers/widgets/Text.dart';

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

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

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
          markers: _markers,
          polylines: _polyLines,
          circles: _circles,
          initialCameraPosition: _kLake,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            rideMapController = controller;
          },
        ),
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: Container(
            padding: EdgeInsets.all(20),
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
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    Image.asset("assets/images/pickicon.png", width: 20),
                    const SizedBox(
                      width: 3,
                    ),
                    PersianTextField(
                      text: "مخعهسبخسبسبخستابنسیعهشب",
                      textSize: 16,
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
                    PersianTextField(
                      text: "عهبتذسیهعتاسهعتاسعه",
                      textSize: 16,
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
}
