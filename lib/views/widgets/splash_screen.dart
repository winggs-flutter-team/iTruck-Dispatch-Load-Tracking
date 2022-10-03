import 'dart:async';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:itruck_dispatch/frebase_dynamic_link.dart';
import 'package:itruck_dispatch/views/admin/screens/admin_dashboard.dart';
import 'package:itruck_dispatch/views/admin/screens/login_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/dispatcher_dashboard.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/login_screen.dart';
import 'package:itruck_dispatch/views/driver/screens/driver_dashboard.dart';
import 'package:itruck_dispatch/views/driver/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    redirect(); //redirect to a screen after a delay
    // FirebaseDynamicLinkService.initDynamicLink(context);
  }

  redirect() async {
    //get session
    SharedPreferences prefs = await SharedPreferences.getInstance();
// after a time of 3 secs go to a screen
    Timer(
        Duration(seconds: 3),
        () => Navigator.pushReplacement(context, MaterialPageRoute(
                //if admin is already loggedin then go to admin dashboard
                //else go to admin login screen
                builder: (context)
                    // prefs.getBool('adminloggedin') != null &&
                    //         prefs.getBool('adminloggedin')!
                    //     ? DispatcherDashboard():
                    {
              if (prefs.getBool('adminloggedin') != null &&
                  prefs.getBool('adminloggedin')!) {
                return AdminDashboard();
              } else if (prefs.getBool('dispatcherloggedin') != null &&
                  prefs.getBool('dispatcherloggedin')!) {
                return DispatcherDashboard();
              } else if (prefs.getBool('driverloggedin') != null &&
                  prefs.getBool('driverloggedin')!) {
                return DriverDashboardScreen();
              } else {
                return DispatcherLoginScreen();
              }
            })));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Container(
              child: Image(image: AssetImage('assets/logo/itruck_logo.png')))),
    );
  }
}
