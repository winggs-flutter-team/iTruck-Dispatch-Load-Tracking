import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/models/load_model.dart';
import 'package:itruck_dispatch/providers/all_users_provider.dart';
import 'package:itruck_dispatch/providers/dispatcher_loads_provider.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/notifications_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/trip_details_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/bottomnavbar.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/dispatcher_drawer.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/load_data_table.dart';
import 'package:itruck_dispatch/views/widgets/header.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DispatcherTripHistoryScreen extends StatefulWidget {
  const DispatcherTripHistoryScreen({Key? key}) : super(key: key);

  @override
  State<DispatcherTripHistoryScreen> createState() =>
      _DispatcherTripHistoryScreenState();
}

class _DispatcherTripHistoryScreenState
    extends State<DispatcherTripHistoryScreen> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  List<bool> showdatatable = [];

  _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: kPrimaryColor,
                onPrimary: Colors.white,
                onSurface: kPrimaryColor,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: kPrimaryColor,
                ),
              ),
            ),
            child: child!,
          );
        },
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));

    if (picked != null && picked != selectedStartDate) {
      setState(() {
        selectedStartDate = picked;
        // searchandfilter();
      });
    }
  }

  _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: kPrimaryColor, // <-- SEE HERE
                onPrimary: Colors.white, // <-- SEE HERE
                onSurface: kPrimaryColor, // <-- SEE HERE
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: kPrimaryColor, // button text color
                ),
              ),
            ),
            child: child!,
          );
        },
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));

    if (picked != null && picked != selectedEndDate) {
      setState(() {
        selectedEndDate = picked;
        // searchandfilter();
      });
    }
  }

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
  List pickupdocs = [];
  searchandfilter() async {
    pickupdocs.clear();
    if (selectedStartDate != null || selectedEndDate != null) {
      await FirebaseFirestore.instance
          .collection('/Pickups')
          .where('pickupdatetime', isGreaterThanOrEqualTo: selectedStartDate)
          .where('pickupdatetime', isLessThanOrEqualTo: selectedEndDate)
          .get()
          .then((value) {
        for (var pickupdoc in value.docs) {
          pickupdocs.add(pickupdoc.reference);
        }
        setState(() {});
      });
    }
    print(pickupdocs.length);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdoc();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    // context
    //     .read<DispatcherLoadsProvider>()
    //     .fetchAllLoads(selectedStartDate, selectedEndDate);
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
                      'Trip History',
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
              padding: const EdgeInsets.only(top: 10.0, left: 10, right: 10),
              child: Container(
                decoration: BoxDecoration(
                    color: dashBoardCardColor4,
                    borderRadius: BorderRadius.circular(12)),
                width: SizeConfig.screenWidth,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Container(
                        child: Text(
                          'Search and Filter',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Start Date',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                      onPressed: () =>
                                          _selectStartDate(context),
                                      icon:
                                          Icon(Icons.calendar_today_outlined)),
                                  if (selectedStartDate != null)
                                    Text(DateFormat("yyyy-MM-dd")
                                        .format(selectedStartDate!))
                                ],
                              )
                            ],
                          ),
                          Container(
                            height: 50,
                            child: VerticalDivider(
                              color: Colors.black,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                'End Date',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                      onPressed: () => _selectEndDate(context),
                                      icon:
                                          Icon(Icons.calendar_today_outlined)),
                                  if (selectedEndDate != null)
                                    Text(DateFormat("yyyy-MM-dd")
                                        .format(selectedEndDate!))
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
                stream: pickupdocs.isNotEmpty
                    ? FirebaseFirestore.instance
                        .collection('Loads')
                        .where('dispatcher', isEqualTo: doc)
                        .snapshots()
                    : FirebaseFirestore.instance
                        .collection('Loads')
                        .where('dispatcher', isEqualTo: doc)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return Container(
                        child: ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return FutureBuilder(
                                  future: LoadModel().loadModelfromJson(
                                      snapshot.data!.docs[index].data() as Map,
                                      snapshot.data!.docs[index].reference),
                                  builder: ((context, snapshot) {
                                    if (!snapshot.hasData)
                                      return Container();
                                    else {
                                      LoadModel load =
                                          snapshot.data as LoadModel;

                                      if ((selectedEndDate == null &&
                                              selectedStartDate == null) ||
                                          (selectedStartDate != null &&
                                              selectedEndDate == null &&
                                              load.pickups![0].pickupdatetime!
                                                      .compareTo(
                                                          selectedStartDate!) >=
                                                  0) ||
                                          (selectedEndDate != null &&
                                              selectedStartDate == null &&
                                              load.pickups![0].pickupdatetime!
                                                      .compareTo(
                                                          selectedEndDate!) <=
                                                  0) ||
                                          (selectedEndDate != null &&
                                              selectedStartDate != null &&
                                              load.pickups![0].pickupdatetime!
                                                      .compareTo(
                                                          selectedStartDate!) >=
                                                  0 &&
                                              load.pickups![0].pickupdatetime!
                                                      .compareTo(
                                                          selectedEndDate!) <=
                                                  0)) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20.0, right: 20, top: 10),
                                          child: Column(
                                            children: [
                                              // InkWell(
                                              //   onTap: (() {
                                              //     setState(() {
                                              //       showdatatable[index] =
                                              //           showdatatable[index]
                                              //               ? false
                                              //               : true;
                                              //     });
                                              //   }),
                                              //   child: Container(
                                              //     height: 50,
                                              //     width: SizeConfig.screenWidth,
                                              //     decoration: BoxDecoration(
                                              //         borderRadius:
                                              //             BorderRadius.circular(
                                              //                 12),
                                              //         color: kPrimaryColor),
                                              //     child: Row(
                                              //       mainAxisAlignment:
                                              //           MainAxisAlignment
                                              //               .spaceBetween,
                                              //       children: [
                                              //         Padding(
                                              //           padding:
                                              //               const EdgeInsets.only(
                                              //                   left: 30.0),
                                              //           child: Text(
                                              //             'Load no ' +
                                              //                 load.loadnumber!,
                                              //             style: TextStyle(
                                              //                 color: Colors.white,
                                              //                 fontSize: 18),
                                              //           ),
                                              //         ),
                                              //       ],
                                              //     ),
                                              //   ),
                                              // ),
                                              Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 15.0),
                                                    child:
                                                        DispatcherLoadDataTable(
                                                      load: load,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 20.0),
                                                    child: ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          DispatcherTripDetailsScreen(
                                                                            load:
                                                                                load,
                                                                          )));
                                                        },
                                                        style: ButtonStyle(
                                                            shape: MaterialStateProperty.all<
                                                                    RoundedRectangleBorder>(
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          18.0),
                                                            )),
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all(Colors
                                                                        .green)),
                                                        child: Container(
                                                          height: 50,
                                                          width: SizeConfig
                                                                  .screenWidth *
                                                              0.3,
                                                          child: const Center(
                                                            child: const Text(
                                                              'Show Details',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 20,
                                                                  letterSpacing:
                                                                      1),
                                                            ),
                                                          ),
                                                        )),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    }
                                  }));
                            }));
                  }
                })
          ],
        ),
      ),
    );
  }
}
