import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uber_drivers/helpers/helpermethodes.dart';
import 'package:uber_drivers/helpers/tripHelperMethod.dart';
import 'package:uber_drivers/models/driverModel.dart';
import 'package:uber_drivers/models/tripDetails.dart';
import 'package:uber_drivers/widgets/ProgressDialog.dart';
import 'package:uber_drivers/widgets/Text.dart';

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
  late String id;

  var locationOptions = const LocationOptions(
      accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 1);

  String availabilityTitle = "روشن";
  Color availabilityColor = BrandColors.colorOrange;
  bool isAvailable = false;

  Query? _ref;
  TripDetails tripDetails = TripDetails();
  List tripList = [];

  double tripSheetHeight = 0;

  void fetchTripList() {
    setState(() {
      _ref = FirebaseDatabase.instance
          .reference()
          .child("rideRequest")
          .orderByChild("time_created");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTripList();
    getCurrentDriverInfo();
  }

  void SetCurrentLocation() async {
    Position position = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;
    LatLng pos = LatLng(position.latitude, position.longitude);
    print("Lat:${pos.latitude} , Lng:${pos.longitude}");
    CameraPosition cp = CameraPosition(target: pos, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));
  }

  void getCurrentDriverInfo() async {
    currentDriverInfo = DriverModels();
    currentFirebaseUser = await FirebaseAuth.instance.currentUser();
    DatabaseReference driverRef = FirebaseDatabase.instance
        .reference()
        .child("drivers/${currentFirebaseUser.uid}");
    driverRef.once().then((DataSnapshot snapshot) => {
          if (snapshot != null)
            {currentDriverInfo = DriverModels.fromSnapshot(snapshot)}
        });
  }

  //getting trip Data for show
  void fetchRideInfo(String rideId) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            const ProgressDialog(status: "درحال ورود"));
    DatabaseReference rideRef = await FirebaseDatabase.instance
        .reference()
        .child("rideRequest/$rideId");
    Navigator.pop(context);
    rideRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        double pickupLat =
            double.parse(snapshot.value["location"]["lat"].toString());
        double pickupLng =
            double.parse(snapshot.value["location"]["long"].toString());
        String pickupAddress = snapshot.value["pickup_address"].toString();

        double destinationLat =
            double.parse(snapshot.value["destination"]["lat"].toString());
        double destinationLng =
            double.parse(snapshot.value["destination"]["long"].toString());
        String destinationAddress =
            snapshot.value["destination_address"].toString();
        String paymentMethod = snapshot.value["payment-method"];
        String riderName = snapshot.value["rider_name"];
        String riderPhone = snapshot.value["rider_phone"];

        TripDetails tripDetails = TripDetails();
        tripDetails.rideId = rideId;
        tripDetails.pickupAddress = pickupAddress;
        tripDetails.pickup = LatLng(pickupLat, pickupLng);
        tripDetails.destination = LatLng(destinationLat, destinationLng);
        tripDetails.destinationAddress = destinationAddress;
        tripDetails.paymentMethod = paymentMethod;
        tripDetails.riderName = riderName;
        tripDetails.riderPhone = riderPhone;
        print(pickupAddress);
      }
    });
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
                                tripSheetHeight = 250;
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
                                tripSheetHeight = 0;
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
        ),
        //trip sheet
        Positioned(
          right: 0,
          bottom: 0,
          left: 0,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeIn,
            child: Container(
              height: tripSheetHeight,
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
              child: FirebaseAnimatedList(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                query: _ref,
                itemBuilder: (BuildContext context, DataSnapshot snapshot,
                    Animation<double> animation, int index) {
                  Map item = snapshot.value;
                  tripDetails.destinationAddress = item["destination_address"];
                  tripDetails.pickupAddress = item["pickup_address"];
                  tripDetails.destination = LatLng(
                      double.parse(item["destination"]["lat"]),
                      double.parse(item["destination"]["long"]));
                  tripDetails.pickup = LatLng(
                      double.parse(item["location"]["lat"]),
                      double.parse(item["location"]["long"]));
                  tripDetails.paymentMethod = item["payment-method"];
                  tripDetails.riderName = item["rider_name"];
                  tripDetails.riderPhone = item["rider_phone"];
                  tripDetails.tripId = snapshot.key;
                  tripList.add(tripDetails);
                  return TripTile(
                    tripDetails: tripList[index],
                  );
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
      if (isAvailable) {
        Geofire.setLocation(id, position.latitude, position.longitude);
      }
      LatLng pos = LatLng(position.latitude, position.longitude);
      mapController.animateCamera(CameraUpdate.newLatLng(pos));
    });
  }
}

class TripTile extends StatelessWidget {
  TripDetails tripDetails = TripDetails();
  TripTile({required this.tripDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/taxi.png",
              width: 70,
            ),
            const SizedBox(
              height: 5,
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
                  text: "مبدا:",
                  textSize: 17,
                  fontWeight: FontWeight.bold,
                ),
                PersianTextField(
                  text: HelperMethods.splitDisplayName(
                      tripDetails.pickupAddress.toString()),
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
                  text: "مقصد:",
                  textSize: 17,
                  fontWeight: FontWeight.bold,
                ),
                PersianTextField(
                  text: HelperMethods.splitDisplayName(
                      tripDetails.destinationAddress.toString()),
                  textSize: 16,
                )
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 120),
              child: MaterialButton(
                color: BrandColors.colorGreen,
                height: 40,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                onPressed: () {
                  TripHelperMethods.checkTripAvailablity(tripDetails, context);
                },
                child: PersianTextField(
                    text: "قبول سفر", color: Colors.white, textSize: 17),
              ),
            )
          ],
        ),
      ),
    );
  }
}
