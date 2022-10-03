import 'package:flutter/material.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/models/delivery_model.dart';
import 'package:itruck_dispatch/models/load_model.dart';
import 'package:itruck_dispatch/models/pickup_model.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/bottomnavbar.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/delivery_detail_view.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/dispatcher_drawer.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/pickup_detail_view.dart';
import 'package:itruck_dispatch/views/driver/screens/driver_drawer.dart';
import 'package:itruck_dispatch/views/driver/widgets/bottomnavbar.dart';
import 'package:itruck_dispatch/views/driver/widgets/delivery_detail_view.dart';
import 'package:itruck_dispatch/views/driver/widgets/pickup_detail_view.dart';
import 'package:itruck_dispatch/views/widgets/header.dart';

class DriverTripDetailsScreen extends StatefulWidget {
  final LoadModel load;

  const DriverTripDetailsScreen({Key? key, required this.load})
      : super(key: key);

  @override
  State<DriverTripDetailsScreen> createState() =>
      _DriverTripDetailsScreenState();
}

class _DriverTripDetailsScreenState extends State<DriverTripDetailsScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setcompleted();
  }

  var lastcompleted;
  var nexttobecompleted;
  int? index1;
  int? index2;

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
      drawer: const DriverDrawer(),
      bottomNavigationBar: const DriverBottomNavBar(),
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
                  DriverPickupDetailView(
                    load: widget.load,
                    initindex: nexttobecompleted is PickupModel ? index1 : null,
                  ),
                  DriverDeliveryDetailView(
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
