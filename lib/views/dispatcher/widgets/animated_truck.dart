import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/models/delivery_model.dart';
import 'package:itruck_dispatch/models/load_model.dart';
import 'package:itruck_dispatch/models/pickup_model.dart';
import 'package:itruck_dispatch/size_config.dart';

class AnimatedTruck extends StatefulWidget {
  final LoadModel? load;

  const AnimatedTruck({Key? key, this.load}) : super(key: key);

  @override
  State<AnimatedTruck> createState() => _AnimatedTruckState();
}

class _AnimatedTruckState extends State<AnimatedTruck> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setload();
    if (widget.load != null) {
      settotaldistance().then((_) {
        timer = Timer.periodic(Duration(seconds: 2), (Timer t) async {
          // await settruckposition();

          await setmilestone();
        });
      });
    }
  }

  LoadModel? load;

  PickupModel pickup1 = PickupModel(
      pickupdate: '22 June 2022',
      pickuptime: '10:30 AM',
      position: 20,
      pickup: 'Frenso,CA,USA,93722');

  PickupModel pickup2 = PickupModel(
      pickupdate: '22 June 2022',
      pickuptime: '10:30 AM',
      position: 40,
      pickup: 'Frenso,CA,USA,93722');
  DeliveryModel delivery1 = DeliveryModel(
      deliverydate: '27 June 2022',
      deliverytime: '4:30 PM',
      position: 60,
      delivery: 'Houston,TX,USA,77038');
  DeliveryModel delivery2 = DeliveryModel(
      deliverydate: '29 June 2022',
      deliverytime: '11:00 AM',
      position: 80,
      delivery: 'Houston,TX,USA,77038');

  setload() {
    if (widget.load != null)
      setState(() {
        load = widget.load;
      });
    else
      load = LoadModel(
          pickups: [pickup1, pickup2], deliveries: [delivery1, delivery2]);
    load!.truckposition = 40;
    if (mounted) {
      setState(() {});
    }
  }

  // runtruck() {
  //   setState(() {
  //     load!.truckposition = (load!.truckposition!) + 5;
  //     for (var i = 0; i < milestonepositions.length; i++) {
  //       if (load!.truckposition! >= milestonepositions[i]!) {
  //         if (i == milestonepositions.length - 1)
  //           milestoneposition = milestonepositions[0];
  //         else
  //           milestoneposition = milestonepositions[i + 1];
  //       }
  //     }
  //     if (load!.truckposition! > 100) load!.truckposition = 0;
  //   });
  // }

  double? initdistance;
  settruckposition(LoadModel load) async {
    if (!(load.pickups![0].completed!)) {
      // truckposition = 0;
      if (load.currentlocation == null) {
        initdistance = 0;
        truckposition = 0;
        print(initdistance);
        if (mounted) setState(() {});
        return;
      }
      var deslat = load.pickups![0].pickupgeopoint!.latitude;
      var deslng = load.pickups![0].pickupgeopoint!.longitude;
      var originlat = load.currentlocation!.latitude;
      var originlng = load.currentlocation!.longitude;
      Dio dio = new Dio();
      Response response = await dio.get(
          "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=$originlat,$originlng&destinations=$deslat,$deslng&key=$googleMapsApiKey");

      initdistance = double.parse((response.data['rows'][0]['elements'][0]
                  ['distance']['value'] /
              1609.344)
          .toStringAsFixed(2));

      if (load.startinglocation != null) {
        double startingdistance;
        var deslat = load.pickups![0].pickupgeopoint!.latitude;
        var deslng = load.pickups![0].pickupgeopoint!.longitude;
        var originlat = load.startinglocation!.latitude;
        var originlng = load.startinglocation!.longitude;
        Dio dio = new Dio();
        Response response = await dio.get(
            "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=$originlat,$originlng&destinations=$deslat,$deslng&key=$googleMapsApiKey");

        startingdistance = double.parse((response.data['rows'][0]['elements'][0]
                    ['distance']['value'] /
                1609.344)
            .toStringAsFixed(2));
        truckposition =
            (((startingdistance - initdistance!) / startingdistance) * 50) - 15;
        // truckposition = -15;
      }
      if (mounted) setState(() {});
    } else {
      var originlat = load.pickups![0].pickupgeopoint!.latitude;
      var originlng = load.pickups![0].pickupgeopoint!.longitude;
      var deslat = load.currentlocation!.latitude;
      var deslng = load.currentlocation!.longitude;
      Dio dio = new Dio();
      Response response = await dio.get(
          "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=$originlat,$originlng&destinations=$deslat,$deslng&key=$googleMapsApiKey");
      truckposition = double.parse((response.data['rows'][0]['elements'][0]
                      ['distance']['value'] /
                  1609.344)
              .toStringAsFixed(2)) +
          0;
      print(truckposition);
      // truckposition = load!.pickups![1].position;
    }
    if (mounted) setState(() {});
  }

  settotaldistance() async {
    totaldistance = 0;
    // load!.pickups![0].position = 50;
    for (var i = 0; i < load!.pickups!.length; i++) {
      if (i != load!.pickups!.length - 1) {
        var originlat = load!.pickups![i].pickupgeopoint!.latitude;
        var originlng = load!.pickups![i].pickupgeopoint!.longitude;
        var deslat = load!.pickups![i + 1].pickupgeopoint!.latitude;
        var deslng = load!.pickups![i + 1].pickupgeopoint!.longitude;

        Dio dio = new Dio();
        Response response = await dio.get(
            "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=$originlat,$originlng&destinations=$deslat,$deslng&key=$googleMapsApiKey");
        // print(response.data);
        totaldistance = totaldistance +
            double.parse((response.data['rows'][0]['elements'][0]['distance']
                        ['value'] /
                    1609.344)
                .toStringAsFixed(2));
        load!.pickups![i + 1].position = totaldistance;
        print(totaldistance);
      } else {
        var originlat = load!.pickups![i].pickupgeopoint!.latitude;
        var originlng = load!.pickups![i].pickupgeopoint!.longitude;
        var deslat = load!.deliveries![0].deliverygeopoint!.latitude;
        var deslng = load!.deliveries![0].deliverygeopoint!.longitude;

        Dio dio = new Dio();
        Response response = await dio.get(
            "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=$originlat,$originlng&destinations=$deslat,$deslng&key=$googleMapsApiKey");
        // print(response.data);
        totaldistance = totaldistance +
            double.parse((response.data['rows'][0]['elements'][0]['distance']
                        ['value'] /
                    1609.344)
                .toStringAsFixed(2));
        load!.deliveries![0].position = totaldistance;
        // print(totaldistance);
      }
    }
    for (var i = 0; i < load!.deliveries!.length - 1; i++) {
      var originlat = load!.deliveries![i].deliverygeopoint!.latitude;
      var originlng = load!.deliveries![i].deliverygeopoint!.longitude;
      var deslat = load!.deliveries![i + 1].deliverygeopoint!.latitude;
      var deslng = load!.deliveries![i + 1].deliverygeopoint!.longitude;

      Dio dio = new Dio();
      Response response = await dio.get(
          "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=$originlat,$originlng&destinations=$deslat,$deslng&key=$googleMapsApiKey");
      // print(response.data);
      totaldistance = totaldistance +
          double.parse((response.data['rows'][0]['elements'][0]['distance']
                      ['value'] /
                  1609.344)
              .toStringAsFixed(0));
      load!.deliveries![i + 1].position = totaldistance;
      // print(totaldistance);
    }
    // await settruckposition();
    if (mounted) setState(() {});
  }

  setmilestone() async {
    bool found = false;
    LoadModel? newload;
    await FirebaseFirestore.instance
        .collection('Loads')
        .doc(widget.load!.docref!.id)
        .get()
        .then((value) async {
      newload =
          await LoadModel().loadModelfromJson(value.data()!, value.reference);
    });
    if (mounted) {
      setState(() {});
    }
    await settruckposition(newload!);
    // for (var pickup in newload!.pickups!) {
    //   if (pickup.completed != true) {
    //     milestoneposition = pickup.position;
    //     found = true;
    //     break;
    //   }
    // }
    for (var i = 0; i < newload!.pickups!.length; i++) {
      if (newload!.pickups![i].completed != true) {
        if (i == 0) {
          milestoneposition = 0;
        } else {
          milestoneposition = load!.pickups![i].position;
        }
        found = true;
        break;
      }
    }
    if (!found) {
      // for (var delivery in newload!.deliveries!) {
      //   if (delivery.completed != true) {
      //     milestoneposition = delivery.position;
      //     break;
      //   }
      // }
      for (var i = 0; i < newload!.deliveries!.length; i++) {
        if (newload!.deliveries![i].completed != true) {
          milestoneposition = load!.deliveries![i].position;
          break;
        }
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  double totaldistance = 0;
  List milestonepositions = [];
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  double? truckposition;
  double? milestoneposition;
  Timer? timer;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      height: 200,
      width: SizeConfig.screenWidth,
      child: Stack(children: [
        Positioned(
          top: 90,
          left: 0,
          child: Container(
            height: 3,
            width: SizeConfig.screenWidth,
            color: Colors.green,
          ),
        ),
        if (load != null && truckposition != null)
          AnimatedPositioned(
              top: 40,
              left: !load!.pickups![0].completed!
                  ? truckposition
                  : (((SizeConfig.screenWidth - 120)) *
                          truckposition! /
                          (totaldistance)) +
                      45,
              child: Container(
                  child: Image(image: AssetImage('assets/truck.png'))),
              duration: Duration(seconds: 1)),
        if (milestoneposition != null)
          AnimatedPositioned(
              top: 50,
              left: milestoneposition == 0
                  ? 50
                  : (((SizeConfig.screenWidth - 120)) *
                          milestoneposition! /
                          (totaldistance)) +
                      50,
              child: Stack(children: [
                Container(
                    child: Image(image: AssetImage('assets/milestone.png'))),
                Positioned(
                  top: 15,
                  left: 10,
                  child: Column(
                    children: [
                      Text(
                        initdistance == null
                            ? (milestoneposition! - truckposition!)
                                    .toString()
                                    .split('.')[0] +
                                '.' +
                                (milestoneposition! - truckposition!)
                                    .toString()
                                    .split('.')[1]
                                    .characters
                                    .take(2)
                                    .string
                            : initdistance.toString(),
                        style: TextStyle(fontSize: 10),
                      ),
                      Text(
                        'miles',
                        style: TextStyle(fontSize: 10),
                      )
                    ],
                  ),
                )
              ]),
              duration: Duration(seconds: 1)),
        Positioned(
          top: 87.5,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
              ),
              // Container(
              //   width: 40,
              //   child: Padding(
              //     padding: const EdgeInsets.only(top: 5.0),
              //     child: Text(
              //       'Current Location',
              //       maxLines: 2,
              //       style: TextStyle(fontSize: 11),
              //     ),
              //   ),
              // )
            ],
          ),
        ),
        if (load != null)
          for (int i = 0; i < load!.pickups!.length; i++)
            if (load!.pickups![i].position != null || i == 0)
              Positioned(
                top: 87.5,
                left: i == 0
                    ? 65
                    : (((SizeConfig.screenWidth - 120)) *
                            (load!.pickups![i].position!) /
                            (totaldistance)) +
                        65,
                // left: 65,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                    ),
                    Padding(
                      padding: i % 2 == 0
                          ? const EdgeInsets.only(top: 5.0)
                          : const EdgeInsets.only(top: 15.0),
                      child: Text(
                        'Pickup ' + (i + 1).toString(),
                        style: TextStyle(fontSize: 11),
                      ),
                    )
                  ],
                ),
              ),
        if (load != null)
          for (int i = 0; i < load!.deliveries!.length; i++)
            if (load!.deliveries![i].position != null)
              Positioned(
                top: 87.5,
                left: (((SizeConfig.screenWidth - 120) / (totaldistance)) *
                        load!.deliveries![i].position!) +
                    65,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                    ),
                    Padding(
                      padding: i % 2 == 0
                          ? const EdgeInsets.only(top: 5.0)
                          : const EdgeInsets.only(top: 15.0),
                      child: Text(
                        'Delivery ' + (i + 1).toString(),
                        style: TextStyle(fontSize: 11),
                      ),
                    )
                  ],
                ),
              ),
      ]),
    );
  }
}
