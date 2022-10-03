import 'dart:async';

import 'package:maps_launcher/maps_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/models/load_model.dart';
import 'package:itruck_dispatch/models/pickup_model.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/map_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/animated_truck.dart';
import 'package:itruck_dispatch/views/driver/screens/map_screen.dart';
import 'package:itruck_dispatch/views/widgets/time_border.dart';

class DriverPickupDetailView extends StatefulWidget {
  final LoadModel load;

  final int? initindex;

  const DriverPickupDetailView({Key? key, required this.load, this.initindex})
      : super(key: key);

  @override
  State<DriverPickupDetailView> createState() => _DriverPickupDetailViewState();
}

class _DriverPickupDetailViewState extends State<DriverPickupDetailView> {
  settimeremain() {
    print(widget.load.pickups!.length);
    timeremain = List.filled(widget.load.pickups!.length, '');

    timeremaintext = List.filled(widget.load.pickups!.length, '');

    timeremaincolor = List.filled(widget.load.pickups!.length, timecolor1);
    print(timeremain.length);
    if (mounted) setState(() {});

    for (var i = 0; i < widget.load.pickups!.length; i++) {
      if (widget.initindex == null || i < widget.initindex!) {
        timeremaincolor[i] = timecolor1;
        timeremaintext[i] = 'Completed';
      } else {
        var pickupdatetime = widget.load.pickups![i].pickupdatetime;
        print(pickupdatetime);
        print(DateTime.now().difference(pickupdatetime!).inMinutes);
        var diffh = DateTime.now().difference(pickupdatetime).inHours;
        print(diffh);
        var diffm =
            diffh * 60 - DateTime.now().difference(pickupdatetime).inMinutes;
        if (diffm.toString().replaceAll('-', '').length == 1) {
          timeremain[i] = diffh.toString().replaceAll('-', '') +
              ':0' +
              diffm.toString().replaceAll('-', '');
        } else {
          timeremain[i] = diffh.toString().replaceAll('-', '') +
              ':' +
              diffm.toString().replaceAll('-', '');
        }
        if (DateTime.now().compareTo(pickupdatetime) == 0) {
          timeremaincolor[i] = timecolor2;
          timeremaintext[i] = 'Running Late For Pickup';
        } else if (DateTime.now().compareTo(pickupdatetime) < 0) {
          timeremaincolor[i] = timecolor1;
          timeremaintext[i] = 'On Time For Pickup';
        } else {
          timeremaincolor[i] = timecolor3;
          timeremaintext[i] = 'Late For Pickup';
        }
      }
    }
    if (mounted) setState(() {});
  }

  List<String> timeremain = [];
  List<String> timeremaintext = [];
  List<Color> timeremaincolor = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    settimeremain();
    timer = Timer.periodic(Duration(seconds: 60), (Timer t) => settimeremain());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Timer? timer;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return DefaultTabController(
      length: widget.load.pickups!.length,
      initialIndex: widget.initindex != null ? widget.initindex! : 0,
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Container(
          width: SizeConfig.screenWidth,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TabBar(
                    indicatorColor: Colors.red,
                    dragStartBehavior: DragStartBehavior.start,
                    isScrollable: true,
                    tabs: [
                      for (int i = 0; i < widget.load.pickups!.length; i++)
                        Container(
                          height: 60,
                          child: Tab(
                            icon: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    'Pickup ' + (i + 1).toString(),
                                    style: TextStyle(
                                        color: Colors.lightBlueAccent,
                                        fontSize: 16),
                                  ),
                                ),
                                Text(
                                  widget.load.pickups![i].pickuptime!,
                                  style: TextStyle(color: Colors.black),
                                ),
                                Text(
                                  widget.load.pickups![i].pickupdate!,
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ]),
              ),
              Expanded(
                child: TabBarView(children: [
                  for (int i = 0; i < widget.load.pickups!.length; i++)
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20.0, right: 20),
                              child: Container(
                                height: 50,
                                width: SizeConfig.screenWidth,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: popupcolor),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 30.0),
                                      child: Text(
                                        'Load no ' + widget.load.loadnumber!,
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 18),
                                      ),
                                    ),
                                    if (!widget.load.completed!)
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: ElevatedButton(
                                            onPressed: () {
                                              MapsLauncher.launchQuery(widget
                                                  .load.pickups![i].pickup!);
                                              // Navigator.push(
                                              //     context,
                                              //     MaterialPageRoute(
                                              //         builder:
                                              //             (context) =>
                                              //                 DriverMapScreen(
                                              //                   load: widget.load,
                                              //                   source: i != 0
                                              //                       ? widget.load
                                              //                               .pickups![
                                              //                           i - 1]
                                              //                       : (widget.load.pickups![0].completed! ||
                                              //                               widget.load.currentlocation ==
                                              //                                   null
                                              //                           ? widget
                                              //                               .load
                                              //                               .pickups!
                                              //                               .first
                                              //                           : widget
                                              //                               .load
                                              //                               .currentlocation),
                                              //                   destination: widget
                                              //                       .load
                                              //                       .pickups![i],
                                              //                 )));
                                            },
                                            style: ButtonStyle(
                                                shape: MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                )),
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.green)),
                                            child: Container(
                                              height: 40,
                                              width:
                                                  SizeConfig.screenWidth * 0.17,
                                              child: const Center(
                                                child: const Text(
                                                  'Map',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      letterSpacing: 1),
                                                ),
                                              ),
                                            )),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            if (!widget.load.completed!)
                              AnimatedTruck(
                                load: widget.load,
                              ),
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              children: [
                                Container(
                                  width: SizeConfig.screenWidth * 0.6,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20.0, left: 10),
                                    child: Text(
                                      widget.load.pickups![i].pickup!,
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                                if (timeremaincolor.isNotEmpty)
                                  TimeRemain(
                                    height: 50.00,
                                    width: SizeConfig.screenWidth * 0.3,
                                    color: timeremaincolor[i],
                                    child: Center(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            timeremaintext[i],
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          if (timeremain[i].isNotEmpty)
                                            Text(
                                              timeremain[i] + ' Hrs',
                                              style: TextStyle(fontSize: 20),
                                            ),
                                        ],
                                      ),
                                    ),
                                  )
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            if (widget.load.notes != null)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 15, left: 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Notes : ',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                          widget.load.notes!,
                                          style: TextStyle(fontSize: 16),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
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
