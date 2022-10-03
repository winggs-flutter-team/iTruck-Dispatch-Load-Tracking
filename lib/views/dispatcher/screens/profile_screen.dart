import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/models/dispatcher_model.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'package:itruck_dispatch/textstyles.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/notifications_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/bottomnavbar.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/dispatcher_drawer.dart';
import 'package:itruck_dispatch/views/widgets/header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DispatcherProfileScreen extends StatefulWidget {
  const DispatcherProfileScreen({Key? key}) : super(key: key);

  @override
  State<DispatcherProfileScreen> createState() =>
      _DispatcherProfileScreenState();
}

class _DispatcherProfileScreenState extends State<DispatcherProfileScreen> {
  DispatcherModel dispatcher = DispatcherModel();
  String dispatcherCompanyName = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setDispatcher();
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
        dispatcherCompanyName = documentSnapshot.data()['name'];
      });

      dispatcher = DispatcherModel.fromJson(value.docs[0].data(), companyid);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      drawer: DispatcherDrawer(),
      bottomNavigationBar: DispatcherBottomNavBar(),
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
                    'Profile',
                    style: TextStyle(fontSize: 30, letterSpacing: 1.3),
                  ),
                  iconTheme: IconThemeData(color: Colors.black),
                  centerTitle: true,
                  actions: [
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
                                            padding: const EdgeInsets.all(3.0),
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
            padding: const EdgeInsets.only(top: 80.0),
            child: Container(
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20.0, bottom: 15, top: 15),
                    child: Row(
                      children: [
                        Container(
                          width: SizeConfig.screenWidth * 0.4,
                          child: Text(
                            'Name :',
                            style: profiletextstyle,
                          ),
                        ),
                        Container(
                          width: SizeConfig.screenWidth * 0.5,
                          child: Text(
                            dispatcher.name != null ? dispatcher.name! : '',
                            style: profiletextstyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 0.7,
                    color: Colors.black,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20.0, bottom: 15, top: 15),
                    child: Row(
                      children: [
                        Container(
                          width: SizeConfig.screenWidth * 0.4,
                          child: Text(
                            'Phone Number :',
                            style: profiletextstyle,
                          ),
                        ),
                        Container(
                          child: Text(
                            dispatcher.phonenumber != null
                                ? '(' +
                                    dispatcher.phonenumber!.substring(0, 3) +
                                    ')' +
                                    '-' +
                                    dispatcher.phonenumber!.substring(3, 6) +
                                    '-' +
                                    dispatcher.phonenumber!.substring(6, 10)
                                : '',
                            style: profiletextstyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 0.7,
                    color: Colors.black,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20.0, bottom: 15, top: 15),
                    child: Row(
                      children: [
                        Container(
                          width: SizeConfig.screenWidth * 0.4,
                          child: Text(
                            'Email :',
                            style: profiletextstyle,
                          ),
                        ),
                        Container(
                          width: SizeConfig.screenWidth * 0.5,
                          child: Text(
                            dispatcher.email != null ? dispatcher.email! : '',
                            style: profiletextstyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 0.7,
                    color: Colors.black,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20.0, bottom: 15, top: 15),
                    child: Row(
                      children: [
                        Container(
                          width: SizeConfig.screenWidth * 0.4,
                          child: Text(
                            'Company Name :',
                            style: profiletextstyle,
                          ),
                        ),
                        Container(
                          width: SizeConfig.screenWidth * 0.5,
                          child: Text(
                            dispatcherCompanyName,
                            style: profiletextstyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 0.7,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          )
        ],
      )),
    );
  }
}
