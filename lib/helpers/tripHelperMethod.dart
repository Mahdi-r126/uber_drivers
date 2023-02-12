import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:uber_drivers/globalVar.dart';
import 'package:uber_drivers/helpers/helpermethodes.dart';
import 'package:uber_drivers/models/tripDetails.dart';
import 'package:uber_drivers/screens/newTripPage.dart';
import 'package:uber_drivers/widgets/ProgressDialog.dart';

class TripHelperMethods {
  static void checkTripAvailablity(
      TripDetails tripDetails, BuildContext context) async {
    ToastContext().init(context);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            ProgressDialog(status: "Accepting request"));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('id');
    DatabaseReference newtripRef =
        FirebaseDatabase.instance.reference().child('drivers/$id/newtrip');
    newtripRef.once().then((DataSnapshot snapshot) {
      Navigator.pop(context);
      String thisTripId = "";
      if (snapshot.value != null) {
        thisTripId = snapshot.value.toString();
      } else {
        Toast.show("trip not found",
            duration: Toast.lengthShort,
            gravity: Toast.bottom,
            backgroundRadius: 10,
            textStyle: const TextStyle(fontFamily: "vazir"));
      }
      if (thisTripId == "waiting") {
        newtripRef.set("Accepted");
        HelperMethods.disableHomeTabLocationUpdates();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewTripPage(
                      tripDetails: tripDetails,
                    )));
      } else if (thisTripId == "cancelled") {
        Toast.show("سفر لغو شده است",
            duration: Toast.lengthShort,
            gravity: Toast.bottom,
            backgroundRadius: 10,
            textStyle:
                const TextStyle(fontFamily: "vazir", color: Colors.white));
      } else if (thisTripId == "timeout") {
        Toast.show("مهلت سفر به پایان رسیده",
            duration: Toast.lengthShort,
            gravity: Toast.bottom,
            backgroundRadius: 10,
            textStyle:
                const TextStyle(fontFamily: "vazir", color: Colors.white));
      } else {
        Toast.show("خطا در قبول سفر",
            duration: Toast.lengthShort,
            gravity: Toast.bottom,
            backgroundRadius: 10,
            textStyle:
                const TextStyle(fontFamily: "vazir", color: Colors.white));
      }
    });
  }
}
