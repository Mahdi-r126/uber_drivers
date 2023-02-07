import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../brand_colors.dart';
import '../tabs/earningsTab.dart';
import '../tabs/homeTab.dart';
import '../tabs/profileTab.dart';
import '../tabs/ratingsTab.dart';

class MainPage extends StatefulWidget {
  static const String id = 'mainpage';
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  int selectedIndex = 0;

  void onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController.index = selectedIndex;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: tabController,
        children: const [HomeTab(), EarningsTab(), RatingsTab(), ProfileTab()],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border.all(color: BrandColors.colorIconSelected, width: 1.5),
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(30), topLeft: Radius.circular(30)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "خانه"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.credit_card), label: "پرداخت ها"),
              BottomNavigationBarItem(icon: Icon(Icons.star), label: "امتیاز"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "حساب"),
            ],
            unselectedItemColor: BrandColors.colorIcon,
            selectedItemColor: BrandColors.colorIconSelected,
            unselectedLabelStyle: const TextStyle(fontFamily: "vazir"),
            selectedLabelStyle:
                const TextStyle(fontFamily: "vazir", fontSize: 12),
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            currentIndex: selectedIndex,
            onTap: onItemClicked,
          ),
        ),
      ),
    );
  }
}
