// ignore_for_file: use_build_context_synchronously

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uber_drivers/screens/registrationPage.dart';
import '../brand_colors.dart';
import '../globalVar.dart';
import '../widgets/ProgressDialog.dart';
import '../widgets/taxiButton.dart';
import 'mainpage.dart';

class LoginPage extends StatelessWidget {
  static const String id = "login";
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  void login(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            const ProgressDialog(status: "درحال ورود"));
    try {
      final FirebaseUser user = (await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      ))
          .user;
      if (user != null) {
        DatabaseReference userref =
            FirebaseDatabase.instance.reference().child('drivers/${user.uid}');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        currentFirebaseUser = user;
        prefs.setBool("isLoggedIn", true);
        prefs.setString("id", user.uid);
        Navigator.pop(context);
        Navigator.pushNamedAndRemoveUntil(
            context, MainPage.id, (route) => false);
      }
    } on Exception catch (e) {
      Navigator.pop(context);
      print('Exception details:\n $e');
      showSnackbar("نام کاربری یا رمز عبور اشتباه است", context);
    } catch (e, s) {
      Navigator.pop(context);
      print('Exception details:\n $e');
      print('Stack trace:\n $s');
      showSnackbar("نام کاربری یا رمز عبور اشتباه است", context);
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
            mainAxisSize: MainAxisSize.min,
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
                height: 40,
              ),
              const Text(
                "ورود راننده",
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: "vazir", fontSize: 25),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: "Email Address",
                          labelStyle: TextStyle(fontSize: 14),
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10)),
                      style: const TextStyle(fontSize: 14, fontFamily: "vazir"),
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
                      style: const TextStyle(fontSize: 14, fontFamily: "vazir"),
                    ),
                    const SizedBox(
                      height: 60,
                    ),
                    TaxiButton(
                        title: "ورود",
                        color: BrandColors.colorAccentPurple,
                        onPressed: () async {
                          var connectivityresult =
                              await Connectivity().checkConnectivity();
                          if (connectivityresult != ConnectivityResult.mobile &&
                              connectivityresult != ConnectivityResult.wifi) {
                            showSnackbar("اتصال خود را بررسی کنید", context);
                            return;
                          }
                          if (!emailController.text.contains("@")) {
                            showSnackbar("Your email is invalid", context);
                            return;
                          }
                          login(context);
                        })
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              InkWell(
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context, RegistrationPage.id, (route) => false),
                child: const Text("ایجاد حساب",
                    style: TextStyle(fontFamily: 'vazir', fontSize: 15)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
