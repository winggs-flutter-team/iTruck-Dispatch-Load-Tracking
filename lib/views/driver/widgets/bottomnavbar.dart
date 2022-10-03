import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/dispatcher_dashboard.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/profile_screen.dart';
import 'package:itruck_dispatch/views/driver/screens/driver_dashboard.dart';
import 'package:itruck_dispatch/views/driver/screens/loads_screen.dart';
import 'package:itruck_dispatch/views/driver/screens/profile_screen.dart';
import 'package:itruck_dispatch/views/driver/screens/search_screen.dart';

class DriverBottomNavBar extends StatefulWidget {
  const DriverBottomNavBar({Key? key}) : super(key: key);

  @override
  State<DriverBottomNavBar> createState() => _DriverBottomNavBarState();
}

class _DriverBottomNavBarState extends State<DriverBottomNavBar> {
  _ontap(int index) {
    setState(() {
      switch (index) {
        case 0:
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DriverDashboardScreen()));
          break;
        case 1:
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DriverSearchLoadsScreen()));

          break;
        case 2:
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DriverLoadsScreen()));

          break;
        case 3:
          if (Platform.isAndroid) {
            launchUrl(Uri.parse(
                "https://play.google.com/store/apps/details?id=com.crinoid.breakdown"));
          } else {
            launchUrl(Uri.parse(
                "https://apps.apple.com/in/app/breakdown-inc/id1459289134"));
          }
          break;
        case 4:
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DriverProfileScreen()));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 0),
      child: BottomNavigationBar(
        elevation: 0,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        onTap: (value) => _ontap(value),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              backgroundColor: Colors.transparent,
              icon: Container(
                  width: 20,
                  child: Image(
                      image:
                          AssetImage('assets/navbaricons/navbaricon_1.png'))),
              label: 'create user'),
          BottomNavigationBarItem(
              icon: Container(
                  width: 20,
                  child: Image(
                      image:
                          AssetImage('assets/navbaricons/navbaricon_2.png'))),
              label: 'create user'),
          BottomNavigationBarItem(
              icon: Container(
                  width: 20,
                  child: Image(
                      image:
                          AssetImage('assets/navbaricons/navbaricon_3.png'))),
              label: 'create user'),
          BottomNavigationBarItem(
              icon: Container(
                  width: 20,
                  child: Image(
                      image:
                          AssetImage('assets/navbaricons/navbaricon_4.png'))),
              label: 'create user'),
          BottomNavigationBarItem(
              icon: Container(
                  child: Image(
                      image:
                          AssetImage('assets/navbaricons/navbaricon_5.png'))),
              label: 'profile'),
        ],
      ),
    );
  }
}
