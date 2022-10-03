import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/functions/driver_functions.dart';
import 'package:itruck_dispatch/models/delivery_model.dart';
import 'package:itruck_dispatch/models/load_model.dart';
import 'package:itruck_dispatch/models/pickup_model.dart';
import 'package:itruck_dispatch/providers/all_users_provider.dart';
import 'package:itruck_dispatch/providers/dispatcher_loads_provider.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/trip_details_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/update_load_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/bottomnavbar.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/dispatcher_drawer.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/load_data_table.dart';
import 'package:itruck_dispatch/views/driver/screens/driver_drawer.dart';
import 'package:itruck_dispatch/views/driver/screens/trip_details_screen.dart';
import 'package:itruck_dispatch/views/driver/widgets/bottomnavbar.dart';
import 'package:itruck_dispatch/views/widgets/header.dart';
import 'package:itruck_dispatch/views/widgets/loading.dart';
import 'package:itruck_dispatch/views/widgets/time_border.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverLoadsScreen extends StatefulWidget {
  const DriverLoadsScreen({Key? key}) : super(key: key);

  @override
  State<DriverLoadsScreen> createState() => _DriverLoadsScreenState();
}

class _DriverLoadsScreenState extends State<DriverLoadsScreen> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  List<bool> showdatatable = [];
  bool isloading = false;

  setnext(LoadModel load) {
    bool found = false;
    for (var pickup in load.pickups!) {
      if (pickup.completed != true) {
        return pickup;
      }
    }
    for (var delivery in load.deliveries!) {
      if (delivery.completed != true) {
        return delivery;
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  gettimeremain(next) {
    if (next is PickupModel) {
      var pickupdatetime = next.pickupdatetime;
      var diffh = DateTime.now().difference(pickupdatetime!).inHours;
      var diffm =
          diffh * 60 - DateTime.now().difference(pickupdatetime).inMinutes;
      if (diffm.toString().replaceAll('-', '').length == 1) {
        String timeremain =
            '${diffh.toString().replaceAll('-', '')}:0${diffm.toString().replaceAll('-', '')}';
        return timeremain;
      } else {
        String timeremain =
            '${diffh.toString().replaceAll('-', '')}:${diffm.toString().replaceAll('-', '')}';
        return timeremain;
      }

      // timeremain = '${diffh.toString().replaceAll('-', '')}:${diffm.toString().replaceAll('-', '')}';
    } else if (next is DeliveryModel) {
      var deliverydatetime = next.deliverydatetime;
      var diffh = DateTime.now().difference(deliverydatetime!).inHours;
      var diffm =
          diffh * 60 - DateTime.now().difference(deliverydatetime).inMinutes;
      if (diffm.toString().replaceAll('-', '').length == 1) {
        String timeremain =
            '${diffh.toString().replaceAll('-', '')}:0${diffm.toString().replaceAll('-', '')}';
        return timeremain;
      } else {
        String timeremain =
            '${diffh.toString().replaceAll('-', '')}:${diffm.toString().replaceAll('-', '')}';
        return timeremain;
      }
    }
  }

  gettimeremaintext(next) {
    if (next is PickupModel) {
      var pickupdatetime = next.pickupdatetime;
      if (DateTime.now().compareTo(pickupdatetime!) == 0) {
        String timeremaintext = 'Running Late For Pickup';
        return timeremaintext;
      } else if (DateTime.now().compareTo(pickupdatetime) < 0) {
        String timeremaintext = 'On Time For Pickup';
        return timeremaintext;
      } else {
        String timeremaintext = 'Late For Pickup';
        return timeremaintext;
      }
    } else if (next is DeliveryModel) {
      var deliverydatetime = next.deliverydatetime;
      if (DateTime.now().compareTo(deliverydatetime!) == 0) {
        String timeremaintext = 'Running Late For Delivery';
        return timeremaintext;
      } else if (DateTime.now().compareTo(deliverydatetime) < 0) {
        String timeremaintext = 'On Time For Delivery';
        return timeremaintext;
      } else {
        String timeremaintext = 'Late For Delivery';
        return timeremaintext;
      }
    }
  }

  gettimeremaincolor(next) {
    if (next is PickupModel) {
      var pickupdatetime = next.pickupdatetime;
      if (DateTime.now().compareTo(pickupdatetime!) == 0) {
        return timecolor2;
      } else if (DateTime.now().compareTo(pickupdatetime) < 0) {
        return timecolor1;
      } else {
        return timecolor3;
      }
    } else if (next is DeliveryModel) {
      var deliverydatetime = next.deliverydatetime;
      if (DateTime.now().compareTo(deliverydatetime!) == 0) {
        return timecolor2;
      } else if (DateTime.now().compareTo(deliverydatetime) < 0) {
        return timecolor1;
      } else {
        return timecolor3;
      }
    }
  }

  _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
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
              colorScheme: const ColorScheme.light(
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

  getdoc() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var phonenumber = prefs.getString('driverphonenumber');

    await FirebaseFirestore.instance
        .collection('/Users')
        .where('role', isEqualTo: 'Driver')
        .where('phonenumber', isEqualTo: phonenumber)
        .limit(1)
        .get()
        .then((value) {
      setState(() {});
      doc = value.docs[0].reference;
    });
  }

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
        if (pickupdocs.length < 10) {
          for (var pickupdoc in value.docs) {
            pickupdocs.add(pickupdoc.reference);
          }
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
    return LoadingOverlay(
      isLoading: isloading,
      progressIndicator: loader,
      child: Scaffold(
        drawer: const DriverDrawer(),
        bottomNavigationBar: const DriverBottomNavBar(),
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
                      title: const Text(
                        'Loads',
                        style:
                            const TextStyle(fontSize: 30, letterSpacing: 1.3),
                      ),
                      iconTheme: const IconThemeData(color: Colors.black),
                      centerTitle: true,
                      actions: [
                        const Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: const IconButton(
                              onPressed: null,
                              icon: const Icon(
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
                          child: const Text(
                            'Search and Filter',
                            style: const TextStyle(fontWeight: FontWeight.w500),
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
                                const Text(
                                  'Start Date',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                        onPressed: () =>
                                            _selectStartDate(context),
                                        icon: const Icon(
                                            Icons.calendar_today_outlined)),
                                    if (selectedStartDate != null)
                                      Text(DateFormat("yyyy-MM-dd")
                                          .format(selectedStartDate!))
                                  ],
                                )
                              ],
                            ),
                            Container(
                              height: 50,
                              child: const VerticalDivider(
                                color: Colors.black,
                              ),
                            ),
                            Column(
                              children: [
                                const Text(
                                  'End Date',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                        onPressed: () =>
                                            _selectEndDate(context),
                                        icon: const Icon(
                                            Icons.calendar_today_outlined)),
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
                          .where('drivers', arrayContains: doc)
                          .where('completed', isEqualTo: false)
                          .snapshots()
                      : FirebaseFirestore.instance
                          .collection('Loads')
                          .where('drivers', arrayContains: doc)
                          .where('completed', isEqualTo: false)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      return Container(
                          child: ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                return FutureBuilder(
                                    future: LoadModel().loadModelfromJson(
                                        snapshot.data!.docs[index].data()
                                            as Map,
                                        snapshot.data!.docs[index].reference),
                                    builder: ((context, snapshot) {
                                      if (showdatatable.length <= index) {
                                        showdatatable.insert(index, false);
                                      }
                                      if (!snapshot.hasData) {
                                        return Container();
                                      } else {
                                        LoadModel load =
                                            snapshot.data as LoadModel;
                                        var next = setnext(load);
                                        String timeremain = gettimeremain(next);
                                        String timeremaintext =
                                            gettimeremaintext(next);
                                        Color timeremaincolor =
                                            gettimeremaincolor(next);
                                        bool accept =
                                            load.acceptabletill != null &&
                                                load.accepted != true &&
                                                DateTime.now().compareTo(
                                                        load.acceptabletill!) <
                                                    0;
                                        if ((load.acceptabletill != null &&
                                                !load.accepted! &&
                                                DateTime.now().compareTo(
                                                        load.acceptabletill!) <
                                                    0) ||
                                            load.accepted!) {
                                          if ((selectedEndDate == null &&
                                                  selectedStartDate == null) ||
                                              (selectedStartDate != null &&
                                                  selectedEndDate == null &&
                                                  load.pickups![0]
                                                          .pickupdatetime!
                                                          .compareTo(
                                                              selectedStartDate!) >=
                                                      0) ||
                                              (selectedEndDate != null &&
                                                  selectedStartDate == null &&
                                                  load.pickups![0]
                                                          .pickupdatetime!
                                                          .compareTo(
                                                              selectedEndDate!) <=
                                                      0) ||
                                              (selectedEndDate != null &&
                                                  selectedStartDate != null &&
                                                  load.pickups![0]
                                                          .pickupdatetime!
                                                          .compareTo(
                                                              selectedStartDate!) >=
                                                      0 &&
                                                  load.pickups![0]
                                                          .pickupdatetime!
                                                          .compareTo(
                                                              selectedEndDate!) <=
                                                      0)) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20.0,
                                                  right: 20,
                                                  top: 10),
                                              child: Column(
                                                children: [
                                                  InkWell(
                                                    onTap: (() {
                                                      setState(() {
                                                        showdatatable[index] =
                                                            showdatatable[index]
                                                                ? false
                                                                : true;
                                                      });
                                                    }),
                                                    child: Container(
                                                      height: 50,
                                                      width: SizeConfig
                                                          .screenWidth,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          color: kPrimaryColor),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 30.0),
                                                            child: Text(
                                                              'Load no ' +
                                                                  load.loadnumber!,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 18),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  if (showdatatable[index])
                                                    Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 15.0),
                                                          child:
                                                              DispatcherLoadDataTable(
                                                            load: load,
                                                          ),
                                                        ),
                                                        if (load.notes != null)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 15,
                                                                    left: 8),
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .black)),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        5.0),
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      const Text(
                                                                        'Notes : ',
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w700),
                                                                      ),
                                                                      Text(
                                                                        load.notes!,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                16),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        // if (load.acceptabletill !=
                                                        //         null &&
                                                        //     load.accepted !=
                                                        //         true &&
                                                        //     DateTime.now()
                                                        //             .compareTo(load
                                                        //                 .acceptabletill!) <
                                                        //         0)
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top:
                                                                          10.0),
                                                              child: ElevatedButton(
                                                                  onPressed: () async {
                                                                    if (accept) {
                                                                      setState(
                                                                          () {
                                                                        isloading =
                                                                            true;
                                                                      });
                                                                      await DriverMethods().acceptload(
                                                                          load.docref!,
                                                                          context,
                                                                          load);
                                                                      setState(
                                                                          () {
                                                                        isloading =
                                                                            false;
                                                                      });
                                                                    } else {
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => DriverTripDetailsScreen(
                                                                                    load: load,
                                                                                  )));
                                                                    }
                                                                  },
                                                                  style: ButtonStyle(
                                                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(18.0),
                                                                      )),
                                                                      backgroundColor: MaterialStateProperty.all(Colors.green)),
                                                                  child: Container(
                                                                    height: 50,
                                                                    width: SizeConfig
                                                                            .screenWidth *
                                                                        0.33,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        accept
                                                                            ? 'Accept'
                                                                            : 'Show Details',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              18,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  )),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top:
                                                                          10.0),
                                                              child: TimeRemain(
                                                                height: 50.00,
                                                                width: SizeConfig
                                                                        .screenWidth *
                                                                    0.3,
                                                                color:
                                                                    timeremaincolor,
                                                                child: Center(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        timeremaintext,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                10),
                                                                      ),
                                                                      Text(
                                                                        '$timeremain Hrs',
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                20),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            );
                                          } else {
                                            return Container();
                                          }
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
      ),
    );
  }

  fetchloads() async {}
}
