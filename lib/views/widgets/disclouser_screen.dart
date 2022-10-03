import 'package:flutter/material.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'package:itruck_dispatch/views/driver/screens/driver_dashboard.dart';
import 'package:itruck_dispatch/views/widgets/dashboard_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DisclouserScreen extends StatefulWidget {
  const DisclouserScreen({super.key});

  @override
  State<DisclouserScreen> createState() => _DisclouserScreenState();
}

class _DisclouserScreenState extends State<DisclouserScreen> {
  setuselocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('uselocation', true);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Container(
            //   child: DashboardIcon(icon: 'assets/user-location.png'),
            // ),
            Center(
              child: Container(
                child: Text(
                  'Use Your Location',
                  style: TextStyle(
                      fontSize: 25,
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                child: Text(
                  '\'iTruck Dispatch\' collects location data to enable "load tracking" even when the app is running in the background.',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              height: 200,
              width: 200,
              // child: DashboardIcon(icon: 'assets/map-marker.png'),
              child: Image(
                image: AssetImage('assets/user-location.png'),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            ElevatedButton(
                onPressed: () async {
                  //push to admin dashboard
                  await setuselocation();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DriverDashboardScreen()));
                },
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    )),
                    backgroundColor: MaterialStateProperty.all(kPrimaryColor)),
                child: Container(
                  height: 50,
                  width: SizeConfig.screenWidth * 0.2,
                  child: const Center(
                    child: const Text(
                      'OK',
                      style: TextStyle(
                          color: Colors.white, fontSize: 20, letterSpacing: 1),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
