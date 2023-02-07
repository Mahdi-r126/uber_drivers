// ignore_for_file: use_build_context_synchronously

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../brand_colors.dart';
import '../globalVar.dart';
import '../widgets/Text.dart';
import '../widgets/taxiButton.dart';
import 'mainpage.dart';

class VehicleInfo extends StatelessWidget {
  VehicleInfo({super.key});
  static const id = "vehicleInfo";
  TextEditingController carModelController = TextEditingController();
  TextEditingController carColorController = TextEditingController();
  TextEditingController vehicleNumberController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void showSnackbar(String title, BuildContext context) {
    final snackBar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 14, fontFamily: "vazir", color: Colors.black87),
      ),
      backgroundColor: Colors.yellow[50],
      elevation: 20,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void updateProfile(BuildContext context) {
    String id = currentFirebaseUser.uid;
    DatabaseReference dbRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/$id/vehicle_details');

    Map map = {
      'car_model': carModelController.text,
      'car_color': carColorController.text,
      'vehicle_number': vehicleNumberController.text
    };

    dbRef.set(map);
    print("vehicle added");
    Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(children: [
          const SizedBox(
            height: 40,
          ),
          Image.asset(
            "assets/images/logo.png",
            width: 180,
            height: 180,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PersianTextField(
                    text: "مشخصات اتومبیل خود را وارد کنید",
                    textSize: 20,
                    fontWeight: FontWeight.bold),
                const SizedBox(
                  height: 40,
                ),
                TextField(
                  controller: carModelController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: "مدل ماشین",
                    labelStyle: TextStyle(fontFamily: "vazir"),
                  ),
                  style: const TextStyle(fontFamily: "vazir", fontSize: 14),
                  maxLength: 15,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: carColorController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: "رنگ ماشین",
                    labelStyle: TextStyle(fontFamily: "vazir"),
                  ),
                  style: const TextStyle(fontFamily: "vazir", fontSize: 14),
                  maxLength: 15,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: vehicleNumberController,
                  decoration: const InputDecoration(
                    labelText: "شماره پلاک ماشین",
                    labelStyle: TextStyle(fontFamily: "vazir"),
                  ),
                  style: const TextStyle(fontFamily: "vazir", fontSize: 14),
                  maxLength: 15,
                  textAlign: TextAlign.left,
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(
                  height: 60,
                ),
                TaxiButton(
                  title: "تکمیل ثبت نام",
                  color: BrandColors.colorGreen,
                  onPressed: () async {
                    var connectivityresult =
                        await Connectivity().checkConnectivity();
                    if (connectivityresult != ConnectivityResult.mobile &&
                        connectivityresult != ConnectivityResult.wifi) {
                      showSnackbar("اتصال خود را بررسی یکنید", context);
                      return;
                    }
                    if (carColorController.text.length < 2) {
                      showSnackbar(
                          "مدل ماشین باید بیش از یک حرف باشد", context);
                      return;
                    }

                    if (carColorController.text.length < 2) {
                      showSnackbar(
                          "رنگ ماشین باید بیش از یک حرف باشد", context);
                      return;
                    }

                    if (vehicleNumberController.text.length < 8) {
                      showSnackbar("شماره پلاک صحیح نیست", context);
                      return;
                    }
                    updateProfile(context);
                  },
                ),
              ],
            ),
          )
        ]),
      )),
    );
  }
}
