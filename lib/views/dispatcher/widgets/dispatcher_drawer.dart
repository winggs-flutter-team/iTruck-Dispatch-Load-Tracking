import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/web_symbols_icons.dart';
import 'package:itruck_dispatch/auth/auth_functions.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/models/dispatcher_model.dart';
import 'package:itruck_dispatch/textstyles.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/complete_load_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/dispatcher_dashboard.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/login_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/post_load_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/profile_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/trip_details_pre_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/trip_history_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DispatcherDrawer extends StatefulWidget {
  const DispatcherDrawer({Key? key}) : super(key: key);

  @override
  State<DispatcherDrawer> createState() => _DispatcherDrawerState();
}

class _DispatcherDrawerState extends State<DispatcherDrawer> {
  DispatcherModel dispatcher = DispatcherModel();
  _setDispatcher() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.getString('dispatcheremail');

    await FirebaseFirestore.instance
        .collection('/Users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get()
        .then((value) async {
      var companyid = '';
      await value.docs[0].data()['company'].get().then((documentSnapshot) {
        companyid = documentSnapshot.id;
      });

      dispatcher = DispatcherModel.fromJson(value.docs[0].data(), companyid);
    });
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setDispatcher();
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
                            builder: (context) => DispatcherProfileScreen()));
                  },
                  child: Center(
                      child: Text(
                    dispatcher.name ?? '',
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
                        builder: (context) => DispatcherDashboard()));
              },
            ),
            Divider(
              color: Colors.black,
            ),
            ListTile(
              title: Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: const Text(
                  'Create Loads',
                  style: drawertextstyle,
                ),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PostLoadScreen()));
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
                        builder: (context) =>
                            DispatcherTripDetailsPreScreen()));
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
                        builder: (context) => DispatcherTripHistoryScreen()));
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
                        builder: (context) => DispatcherCompleteLoadScreen()));
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
                        AuthMethods().dispatcherLogout();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DispatcherLoginScreen()));
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
