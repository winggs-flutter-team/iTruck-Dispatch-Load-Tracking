import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/web_symbols_icons.dart';
import 'package:itruck_dispatch/auth/auth_functions.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/models/driver_model.dart';
import 'package:itruck_dispatch/textstyles.dart';
import 'package:itruck_dispatch/views/driver/screens/complete_loads_screen.dart';
import 'package:itruck_dispatch/views/driver/screens/driver_dashboard.dart';
import 'package:itruck_dispatch/views/driver/screens/loads_screen.dart';
import 'package:itruck_dispatch/views/driver/screens/login_screen.dart';
import 'package:itruck_dispatch/views/driver/screens/profile_screen.dart';
import 'package:itruck_dispatch/views/driver/screens/trip_details_pre_screen.dart';
import 'package:itruck_dispatch/views/driver/screens/trip_details_screen.dart';
import 'package:itruck_dispatch/views/driver/screens/trip_history_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverDrawer extends StatefulWidget {
  const DriverDrawer({Key? key}) : super(key: key);

  @override
  State<DriverDrawer> createState() => _DriverDrawerState();
}

class _DriverDrawerState extends State<DriverDrawer> {
  DriverModel driver = DriverModel();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setDispatcher();
  }

  _setDispatcher() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var phonenumber = prefs.getString('driverphonenumber');

    await FirebaseFirestore.instance
        .collection('/Users')
        .where('role', isEqualTo: 'Driver')
        .where('phonenumber', isEqualTo: phonenumber)
        .limit(1)
        .get()
        .then((value) async {
      driver =
          DriverModel.fromJson(value.docs[0].data(), value.docs[0].reference);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: kPrimaryColor,
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: Container(
        decoration: BoxDecoration(border: Border.all(width: 1)),
        child: Column(
          // Important: Remove any padding from the ListView.
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 70.0),
              child: Container(
                height: 100,
                decoration: BoxDecoration(),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DriverProfileScreen()));
                  },
                  child: Center(
                      child: Text(
                    driver.name ?? '',
                    style: drawertextstyle,
                  )),
                ),
              ),
            ),
            ListTile(
              title: Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: const Text(
                  'Dashboard',
                  style: drawertextstyle,
                ),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DriverDashboardScreen()));
              },
            ),
            Divider(
              color: Colors.black,
            ),
            ListTile(
              title: Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: const Text(
                  'Loads',
                  style: drawertextstyle,
                ),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DriverLoadsScreen()));
              },
            ),
            Divider(
              color: Colors.black,
            ),
            ListTile(
              title: Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: const Text(
                  'Trip Details',
                  style: drawertextstyle,
                ),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DriverTripDetailsPreScreen()));
              },
            ),
            Divider(
              color: Colors.black,
            ),
            ListTile(
              title: Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: const Text(
                  'Trip History',
                  style: drawertextstyle,
                ),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DriverTripHistoryScreen()));
              },
            ),
            Divider(
              color: Colors.black,
            ),
            ListTile(
              title: Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: const Text(
                  'Complete Loads',
                  style: drawertextstyle,
                ),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DriverCompleteLoadScreen()));
              },
            ),
            Divider(
              color: Colors.black,
            ),
            Expanded(
              child: Container(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20.0, bottom: 50),
                  child: IconButton(
                      onPressed: () {
                        AuthMethods().driverlogout();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DriverLoginScreen()));
                      },
                      icon: Icon(
                        WebSymbols.logout,
                        size: 30,
                        color: Colors.white,
                      )),
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 25, left: 25),
                  child: Container(
                      height: 41,
                      width: 34,
                      child: Image(
                          image: AssetImage('assets/logo/itruck_logo.png'))),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 25.0),
                  child: Text(
                    'iTruck Dispatch',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
