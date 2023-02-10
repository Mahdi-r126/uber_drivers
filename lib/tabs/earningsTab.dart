import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:uber_drivers/models/tripDetails.dart';
import 'package:uber_drivers/widgets/Text.dart';

import '../brand_colors.dart';
import '../widgets/taxiButton.dart';

///////THIS CODES ARE TEST AND WILL CHANGE AND MOVE TO HOMETAB
class EarningsTab extends StatefulWidget {
  const EarningsTab({super.key});

  @override
  State<EarningsTab> createState() => _EarningsTabState();
}

class _EarningsTabState extends State<EarningsTab> {
  Query? _ref;
  TripDetails tripDetails = TripDetails();
  List tripList = [];

  void fetchTripList() {
    _ref = FirebaseDatabase.instance
        .reference()
        .child("rideRequest")
        .orderByChild("time_created");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTripList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FirebaseAnimatedList(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        query: _ref,
        itemBuilder: (BuildContext context, DataSnapshot snapshot,
            Animation<double> animation, int index) {
          Map item = snapshot.value;
          print(snapshot.key);
          tripDetails.destinationAddress = item["destination_address"];
          tripDetails.pickupAddress = item["pickup_address"];
          tripList.add(tripDetails);
          return TripTile(
            tripDetails: tripList[index],
          );
        },
      ),
    );
  }
}

class TripTile extends StatelessWidget {
  TripDetails tripDetails = TripDetails();
  TripTile({required this.tripDetails});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
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
                text: tripDetails.pickupAddress.toString(),
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
                text: tripDetails.destinationAddress.toString(),
                textSize: 16,
              )
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 120),
            child: TaxiButton(
              title: "قبول سفر",
              color: BrandColors.colorGreen,
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }
}
