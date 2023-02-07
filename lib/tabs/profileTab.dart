import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../brand_colors.dart';
import '../screens/loginPage.dart';
import '../widgets/Text.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MaterialButton(
        onPressed:() async{
          SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('isLoggedIn',false);
              // ignore: use_build_context_synchronously
              Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);
        }, 
        color: BrandColors.colorPrimary,
        child: PersianTextField(text: "خروج",color: Colors.white),
        ),
    );
  }
}