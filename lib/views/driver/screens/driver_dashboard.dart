import 'package:flutter/material.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/frebase_dynamic_link.dart';
import 'package:itruck_dispatch/functions/geolocation_functions.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'package:itruck_dispatch/textstyles.dart';
import 'package:itruck_dispatch/views/driver/screens/complete_loads_screen.dart';
import 'package:itruck_dispatch/views/driver/screens/driver_drawer.dart';
import 'package:itruck_dispatch/views/driver/screens/loads_screen.dart';
import 'package:itruck_dispatch/views/driver/screens/trip_details_pre_screen.dart';
import 'package:itruck_dispatch/views/driver/screens/trip_details_screen.dart';
import 'package:itruck_dispatch/views/driver/screens/trip_history_screen.dart';
import 'package:itruck_dispatch/views/driver/widgets/bottomnavbar.dart';
import 'package:itruck_dispatch/views/driver/widgets/load_data_table.dart';
import 'package:itruck_dispatch/views/widgets/dashboard_icon.dart';
import 'package:itruck_dispatch/views/widgets/disclouser_screen.dart';
import 'package:itruck_dispatch/views/widgets/header.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:shared_preferences/shared_preferences.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({Key? key}) : super(key: key);

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseDynamicLinkService.initDynamicLink(context);
    GeolocationMethods().addgeofences();

    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      // print('[location] - $location-');
      print('ok');
      GeolocationMethods().ondriverlocationchange(location);
    });
    // print(bg.BackgroundGeolocation.geofences.);
    bg.BackgroundGeolocation.onGeofence(
        (bg.GeofenceEvent event) => GeolocationMethods().ongeofence(event));
    ////
    // 2.  Configure the plugin
    //
    bg.BackgroundGeolocation.ready(bg.Config(
            locationAuthorizationRequest: "Always",
            // disableLocationAuthorizationAlert: true,
            desiredAccuracy: bg.Config.DESIRED_ACCURACY_NAVIGATION,
            distanceFilter: 10.0,
            backgroundPermissionRationale: bg.PermissionRationale(
                message:
                    '\'iTruck Dispatch\' collects location data to enable "load tracking" even when the app is running in the background.'),
            reset: false,
            stopOnTerminate: false,
            startOnBoot: true,
            heartbeatInterval: 60,
            enableHeadless: true,
            stopTimeout: 1,
            autoSync: true,
            // debug: true,
            foregroundService: true,
            logLevel: bg.Config.LOG_LEVEL_VERBOSE))
        .then((bg.State state) async {
      if (!state.enabled) {
        print('ok');
        ////
        // 3.  Start the plugin.
        //
        if (await checkforuselocation()) {
          bg.BackgroundGeolocation.start();
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DisclouserScreen()));
        }
      }
    });
    // bg.BackgroundGeolocation.reset();

    // bg.BackgroundGeolocation.ready(bg.Config(
    //         locationAuthorizationRequest: "Always",
    //         reset: false,
    //         desiredAccuracy: bg.Config.DESIRED_ACCURACY_NAVIGATION,
    //         distanceFilter: 10.0,
    //         stopOnTerminate: false,
    //         startOnBoot: true,
    //         enableHeadless: true,
    //         stopTimeout: 1,
    //         autoSync: true,
    //         debug: true,
    //         logLevel: bg.Config.LOG_LEVEL_VERBOSE,
    //         heartbeatInterval: 60,
    //         foregroundService: true))
    //     .then((bg.State state) {
    //   bool isWelcomHome = SharedPreferencesHelper.getIsWelcomHomeEnabled();
    //   if (!state.enabled && isWelcomHome) {
    //     //// // 3. Start the plugin. // print("Service Started"); bg.BackgroundGeolocation.start();
    //   }
    // });
    // bg.BackgroundGeolocation.getCurrentPosition()
  }

  Future<bool> checkforuselocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
//set dispatcher loggedin session to true
    bool? uselocation = prefs.getBool('uselocation');
    if (uselocation == true) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      drawer: DriverDrawer(),
      bottomNavigationBar: DriverBottomNavBar(),
      body: Column(
        children: [
          Header(
            height: SizeConfig.screenHeight * 0.2,
            child: Padding(
              padding: EdgeInsets.only(top: SizeConfig.screenHeight * 0.06),
              child: Container(
                height: 80,
                child: AppBar(
                  elevation: 0,
                  backgroundColor: kPrimaryColor,
                  title: Text(
                    'Dashboard',
                    style: TextStyle(fontSize: 30, letterSpacing: 1.3),
                  ),
                  iconTheme: IconThemeData(color: Colors.black),
                  centerTitle: true,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: IconButton(
                          onPressed: () async {
                            // await AuthMethods().adminLogout();
                          },
                          icon: Icon(
                            Icons.notifications,
                            color: Colors.black,
                          )),
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 90.0, left: 10, right: 10),
            child: Container(
              child: StaggeredGrid.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  Material(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    color: Colors.transparent,
                    elevation: 10,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DriverLoadsScreen()));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: dashBoardCardColor1,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Loads',
                              style: dashboardbuttonsstyle,
                            ),
                            DashboardIcon(
                                icon: 'assets/dashboardicons/loads.png'),
                          ],
                        ),
                        height: SizeConfig.screenHeight * 0.20,
                      ),
                    ),
                  ),
                  Material(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    color: Colors.transparent,
                    elevation: 10,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DriverTripDetailsPreScreen()));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: dashBoardCardColor2,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Trip Details',
                              style: dashboardbuttonsstyle,
                            ),
                            DashboardIcon(
                                icon: 'assets/dashboardicons/trip_detail.png'),
                          ],
                        ),
                        height: SizeConfig.screenHeight * 0.30,
                      ),
                    ),
                  ),
                  Material(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    color: Colors.transparent,
                    elevation: 10,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DriverTripHistoryScreen()));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: dashBoardCardColor3,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Trip History',
                              style: dashboardbuttonsstyle,
                            ),
                            DashboardIcon(
                                icon: 'assets/dashboardicons/trip_history.png'),
                          ],
                        ),
                        height: SizeConfig.screenHeight * 0.30,
                      ),
                    ),
                  ),
                  Material(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    color: Colors.transparent,
                    elevation: 10,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DriverCompleteLoadScreen()));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: dashBoardCardColor4,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Complete Loads',
                              style: dashboardbuttonsstyle,
                            ),
                            DashboardIcon(
                                icon:
                                    'assets/dashboardicons/complete_loads.png'),
                          ],
                        ),
                        height: SizeConfig.screenHeight * 0.20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
