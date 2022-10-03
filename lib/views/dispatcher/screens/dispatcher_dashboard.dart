import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttericon/web_symbols_icons.dart';
import 'package:itruck_dispatch/auth/auth_functions.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/frebase_dynamic_link.dart';
import 'package:itruck_dispatch/models/load_model.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'package:itruck_dispatch/textstyles.dart';
import 'package:itruck_dispatch/views/admin/screens/creat_user_screen.dart';
import 'package:itruck_dispatch/views/admin/screens/manage_user_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/complete_load_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/loads_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/login_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/notifications_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/post_load_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/trip_details_pre_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/trip_details_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/trip_history_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/bottomnavbar.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/dispatcher_drawer.dart';
import 'package:itruck_dispatch/views/widgets/dashboard_icon.dart';
import 'package:itruck_dispatch/views/widgets/header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DispatcherDashboard extends StatefulWidget {
  const DispatcherDashboard({Key? key}) : super(key: key);

  @override
  State<DispatcherDashboard> createState() => _DispatcherDashboardState();
}

class _DispatcherDashboardState extends State<DispatcherDashboard> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseDynamicLinkService.initDynamicLink(context);
    checkfornotifications();
  }

  bool anynotifications = false;

  checkfornotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.getString('dispatcheremail');
    await FirebaseFirestore.instance
        .collection('/Users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get()
        .then((value) {
      docref = value.docs[0].reference;
      notifications = value.docs[0].data()['notifications'];
    });
    if (notifications.isNotEmpty) {
      anynotifications = true;
    }
    setState(() {});
  }

  DocumentReference? docref;
  List notifications = [];
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      bottomNavigationBar: DispatcherBottomNavBar(),
      drawer: DispatcherDrawer(),
      body: SingleChildScrollView(
        child: Column(
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
                      // Padding(
                      //   padding: const EdgeInsets.only(right: 12.0),
                      //   child: IconButton(
                      //       onPressed: () async {
                      //         // await AuthMethods().dispatcherLogout();
                      //         // Navigator.push(
                      //         //     context,
                      //         //     MaterialPageRoute(
                      //         //         builder: (context) =>
                      //         //             DispatcherLoginScreen()));
                      //       },
                      //       icon: Icon(
                      //         WebSymbols.logout,
                      //         color: Colors.black,
                      //       )),
                      // )
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Stack(children: <Widget>[
                          IconButton(
                              onPressed: () {
                                if (docref != null) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DispatcherNotificationsScreen(
                                                docref: docref!,
                                              )));
                                }
                              },
                              icon: Icon(
                                Icons.notifications,
                                size: 25,
                              )),
                          if (docref != null)
                            StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('/Users')
                                    .doc(docref!.id)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    int noticount = 0;
                                    List notifications = (snapshot.data!.data()!
                                        as Map)['notifications'];
                                    if (notifications.isNotEmpty) {
                                      anynotifications = true;
                                      int seennotificationcount = 0;

                                      for (var noti in notifications) {
                                        if (noti.toString().contains('@seen')) {
                                          seennotificationcount++;
                                        }
                                      }
                                      noticount = notifications.length -
                                          seennotificationcount;
                                    }
                                    if (noticount != 0) {
                                      return Positioned(
                                        // draw a red marble
                                        top: 5.0,
                                        right: 12.0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red),
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              child: Text(
                                                noticount.toString(),
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Container();
                                    }
                                  } else {
                                    return Container();
                                  }
                                })
                        ]),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 50.0, left: 30, right: 30, bottom: 20),
              child: Container(
                child: StaggeredGrid.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 20,
                  children: [
                    StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 0.7,
                      child: Material(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        color: Colors.transparent,
                        elevation: 10,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PostLoadScreen()));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: dashBoardCardColor5,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'Create Loads',
                                  style: dashboardbuttonsstyle,
                                ),
                                DashboardIcon(
                                    icon:
                                        'assets/dashboardicons/load_post.png'),
                              ],
                            ),
                            height: SizeConfig.screenHeight * 0.1,
                          ),
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
                                      DispatcherLoadsScreen()));
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
                                      DispatcherTripDetailsPreScreen()));
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
                                  icon:
                                      'assets/dashboardicons/trip_detail.png'),
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
                                      DispatcherTripHistoryScreen()));
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
                                  icon:
                                      'assets/dashboardicons/trip_history.png'),
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
                                      DispatcherCompleteLoadScreen()));
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
      ),
    );
  }
}
