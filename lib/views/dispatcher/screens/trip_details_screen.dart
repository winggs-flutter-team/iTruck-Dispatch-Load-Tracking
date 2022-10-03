import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/models/delivery_model.dart';
import 'package:itruck_dispatch/models/load_model.dart';
import 'package:itruck_dispatch/models/pickup_model.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/notifications_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/bottomnavbar.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/delivery_detail_view.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/dispatcher_drawer.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/pickup_detail_view.dart';
import 'package:itruck_dispatch/views/widgets/header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DispatcherTripDetailsScreen extends StatefulWidget {
  final LoadModel load;

  const DispatcherTripDetailsScreen({Key? key, required this.load})
      : super(key: key);

  @override
  State<DispatcherTripDetailsScreen> createState() =>
      _DispatcherTripDetailsScreenState();
}

class _DispatcherTripDetailsScreenState
    extends State<DispatcherTripDetailsScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setcompleted();
    getdoc();
  }

  var lastcompleted;
  var nexttobecompleted;
  int? index1;
  int? index2;

  bool anynotifications = false;

  getdoc() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.getString('dispatcheremail');

    await FirebaseFirestore.instance
        .collection('/Users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get()
        .then((value) {
      setState(() {});
      doc = value.docs[0].reference;
      notifications = value.docs[0].data()['notifications'];
    });
    if (notifications.isNotEmpty) {
      anynotifications = true;
    }

    setState(() {});
  }

  List notifications = [];
  DocumentReference? doc;

  setcompleted() {
    int i = 0;
    int j = 0;
    bool found = false;
    for (var pickup in widget.load.pickups!) {
      if (pickup.completed == true) {
        i++;
        lastcompleted = pickup;
      } else {
        nexttobecompleted = pickup;
        found = true;
        break;
      }
    }
    if (!found) {
      for (var delivery in widget.load.deliveries!) {
        if (delivery.completed == true) {
          j++;
          lastcompleted = delivery;
        } else {
          nexttobecompleted = delivery;
          break;
        }
      }
    }
    index1 = i;
    index2 = j;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      drawer: const DispatcherDrawer(),
      bottomNavigationBar: const DispatcherBottomNavBar(),
      body: DefaultTabController(
        length: 2,
        initialIndex: nexttobecompleted is PickupModel ? 0 : 1,
        child: Container(
          height: SizeConfig.screenHeight,
          width: SizeConfig.screenWidth,
          child: Column(
            children: [
              Header(
                height: SizeConfig.screenHeight * 0.28,
                child: Padding(
                  padding: EdgeInsets.only(top: SizeConfig.screenHeight * 0.04),
                  child: Container(
                    height: SizeConfig.screenHeight * 0.17,
                    child: AppBar(
                      elevation: 0,
                      backgroundColor: kPrimaryColor,
                      title: const Text(
                        'Trip Details',
                        style:
                            const TextStyle(fontSize: 30, letterSpacing: 1.3),
                      ),
                      iconTheme: const IconThemeData(color: Colors.black),
                      centerTitle: true,
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Stack(children: <Widget>[
                            IconButton(
                                onPressed: () {
                                  if (doc != null) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DispatcherNotificationsScreen(
                                                  docref: doc!,
                                                )));
                                  }
                                },
                                icon: Icon(
                                  Icons.notifications,
                                  size: 25,
                                )),
                            if (doc != null)
                              StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('/Users')
                                      .doc(doc!.id)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      int noticount = 0;
                                      List notifications = (snapshot.data!
                                          .data()! as Map)['notifications'];
                                      if (notifications.isNotEmpty) {
                                        anynotifications = true;
                                        int seennotificationcount = 0;

                                        for (var noti in notifications) {
                                          if (noti
                                              .toString()
                                              .contains('@seen')) {
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
                      bottom: const TabBar(
                        indicatorColor: Colors.red,
                        tabs: [
                          const Tab(
                              icon: const Text(
                            'Pickup Detail',
                            style: TextStyle(fontSize: 17),
                          )),
                          const Tab(
                              icon: Text(
                            'Delivery Detail',
                            style: const TextStyle(fontSize: 17),
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(children: [
                  DispatcherPickupDetailView(
                    load: widget.load,
                    initindex: nexttobecompleted is PickupModel ? index1 : null,
                  ),
                  DispatcherDeliveryDetailView(
                    load: widget.load,
                    initindex:
                        nexttobecompleted is DeliveryModel ? index2 : null,
                  )
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
