import 'dart:async';

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
import 'package:maps_launcher/maps_launcher.dart';

class DriverDeliveryDetailView extends StatefulWidget {
  final LoadModel load;

  final int? initindex;

  const DriverDeliveryDetailView({Key? key, required this.load, this.initindex})
      : super(key: key);

  @override
  State<DriverDeliveryDetailView> createState() =>
      _DriverDeliveryDetailViewState();
}

class _DriverDeliveryDetailViewState extends State<DriverDeliveryDetailView> {
  settimeremain() {
    print(widget.load.pickups!.length);
    timeremain = List.filled(widget.load.deliveries!.length, '');

    timeremaintext = List.filled(widget.load.deliveries!.length, '');

    timeremaincolor = List.filled(widget.load.deliveries!.length, timecolor1);
    print(timeremain.length);
    if (mounted) setState(() {});

    for (var i = 0; i < widget.load.deliveries!.length; i++) {
      if (widget.initindex != null && i < widget.initindex!) {
        timeremaincolor[i] = timecolor1;
        timeremaintext[i] = 'Completed';
      } else {
        var deliverydatetime = widget.load.deliveries![i].deliverydatetime;
        print(deliverydatetime);
        var diffh = DateTime.now().difference(deliverydatetime!).inHours;
        var diffm =
            diffh * 60 - DateTime.now().difference(deliverydatetime).inMinutes;
        if (diffm.toString().replaceAll('-', '').length == 1) {
          timeremain[i] = diffh.toString().replaceAll('-', '') +
              ':0' +
              diffm.toString().replaceAll('-', '');
        } else {
          timeremain[i] = diffh.toString().replaceAll('-', '') +
              ':' +
              diffm.toString().replaceAll('-', '');
        }
        if (DateTime.now().compareTo(deliverydatetime) == 0) {
          timeremaincolor[i] = timecolor2;
          timeremaintext[i] = 'Running Late For Delivery';
        } else if (DateTime.now().compareTo(deliverydatetime) < 0) {
          timeremaincolor[i] = timecolor1;
          timeremaintext[i] = 'On Time For Delivery';
        } else {
          timeremaincolor[i] = timecolor3;
          timeremaintext[i] = 'Late For Delivery';
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
    print(widget.load.deliveries!.length);
    print(widget.initindex);
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
      length: widget.load.deliveries!.length,
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
                      for (int i = 0; i < widget.load.deliveries!.length; i++)
                        Container(
                          height: 60,
                          child: Tab(
                            icon: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    'Delivery ' + (i + 1).toString(),
                                    style: TextStyle(
                                        color: Colors.lightBlueAccent,
                                        fontSize: 16),
                                  ),
                                ),
                                Text(
                                  widget.load.deliveries![i].deliverytime!,
                                  style: TextStyle(color: Colors.black),
                                ),
                                Text(
                                  widget.load.deliveries![i].deliverydate!,
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
                  for (int i = 0; i < widget.load.deliveries!.length; i++)
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
                                                  .load
                                                  .deliveries![i]
                                                  .delivery!);
                                              // Navigator.push(
                                              //     context,
                                              //     MaterialPageRoute(
                                              //         builder: (context) =>
                                              //             DriverMapScreen(
                                              //               load: widget.load,
                                              //               source: i != 0
                                              //                   ? widget.load
                                              //                           .deliveries![
                                              //                       i - 1]
                                              //                   : widget
                                              //                       .load
                                              //                       .pickups!
                                              //                       .last,
                                              //               destination: widget
                                              //                   .load
                                              //                   .deliveries![i],
                                              //             )));
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
                                      widget.load.deliveries![i].delivery!,
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                                TimeRemain(
                                  height: 50.00,
                                  width: SizeConfig.screenWidth * 0.3,
                                  color: widget.load.completed!
                                      ? Colors.green
                                      : timeremaincolor[i],
                                  child: Center(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          (!widget.load.completed!)
                                              ? timeremaintext[i]
                                              : 'Completed',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        if (timeremain[i].isNotEmpty &&
                                            !widget.load.completed!)
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
