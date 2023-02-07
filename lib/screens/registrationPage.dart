// ignore_for_file: use_build_context_synchronously

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uber_drivers/screens/vehicleInfo.dart';
import '../brand_colors.dart';
import '../globalVar.dart';
import '../widgets/ProgressDialog.dart';
import '../widgets/Text.dart';
import '../widgets/taxiButton.dart';
import 'loginPage.dart';

class RegistrationPage extends StatelessWidget {
  static const String id = "registration";

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var fullNameController = TextEditingController();
  var emailController = TextEditingController();
  var phoneNumberController = TextEditingController();
  var passwordController = TextEditingController();

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

  void registerUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            const ProgressDialog(status: "در حال ثبت اطلاعات"));
    try {
      FirebaseUser driver = (await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      ))
          .user;
      //check if Registeration is successful
      if (driver != null) {
        DatabaseReference newDriver = FirebaseDatabase.instance
            .reference()
            .child('drivers/${driver.uid}');
        Map driverMap = {
          "fullname": fullNameController.text,
          "email": emailController.text,
          "phone": phoneNumberController.text
        };
        newDriver.set(driverMap);
        currentFirebaseUser = driver;

        Navigator.pop(context);
        //Go to MainPage
        Navigator.pushNamed(
            context, VehicleInfo.id);
      }
      print("Driver added");
    } catch (_) {
      Navigator.pop(context);
      //Check error and display message
      showSnackbar("آدرس ایمیل قبلا ثبت شده است", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 70,
              ),
              const Image(
                alignment: Alignment.center,
                height: 150,
                width: 150,
                fit: BoxFit.contain,
                image: AssetImage("assets/images/logo.png"),
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                "ایجاد حساب",
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: "vazir", fontSize: 25),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    TextField(
                      controller: fullNameController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: "نام کاربری",
                          labelStyle:
                              TextStyle(fontSize: 14, fontFamily: "vazir"),
                          hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                              fontFamily: "vazir")),
                      style: const TextStyle(fontSize: 14, fontFamily: "vazir"),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: "آدرس ایمیل",
                          labelStyle:
                              TextStyle(fontSize: 14, fontFamily: "vazir"),
                          hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                              fontFamily: "vazir")),
                      style: const TextStyle(fontSize: 14, fontFamily: "vazir"),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                          labelText: "شماره همراه",
                          labelStyle:
                              TextStyle(fontSize: 14, fontFamily: "vazir"),
                          hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                              fontFamily: "vazir")),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(fontSize: 14),
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10)),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(
                      height: 60,
                    ),
                    TaxiButton(
                      color: BrandColors.colorAccentPurple,
                      title: "ایجاد حساب",
                      onPressed: () async {
                        // check network avaibility
                        var connectivityresult =
                            await Connectivity().checkConnectivity();
                        if (connectivityresult != ConnectivityResult.mobile &&
                            connectivityresult != ConnectivityResult.wifi) {
                          showSnackbar("اتصال خود را بررسی یکنید", context);
                          return;
                        }
                        if (fullNameController.text.length < 7) {
                          showSnackbar(
                              "نام و نام خانوادگی باید بیش از هفت حرف باشد",
                              context);
                          return;
                        }

                        if (phoneNumberController.text.length < 10) {
                          showSnackbar(
                              "شماره همراه خود را درست وارد کنید", context);
                          return;
                        }

                        if (!emailController.text.contains("@")) {
                          showSnackbar(
                              "آدرس ایمیل خود را درست وراد کنید", context);
                          return;
                        }

                        if (passwordController.text.length < 8) {
                          showSnackbar(
                              "لطفا رمز عبور قوی تری را وارد کنید", context);
                          return;
                        }
                        registerUser(context);
                      },
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context, LoginPage.id, (route) => false),
                child: PersianTextField(
                    text: "قبلا ثبت نام کرده اید؟ورود", textSize: 15),
              )
            ],
          ),
        ),
      ),
    );
    
  }
}
