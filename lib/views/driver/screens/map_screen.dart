import 'dart:async';
import 'dart:typed_data';
// import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:image/image.dart' as img;
import 'package:itruck_dispatch/views/driver/screens/driver_drawer.dart';
import 'package:itruck_dispatch/views/driver/widgets/bottomnavbar.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/models/load_model.dart';
import 'package:itruck_dispatch/models/pickup_model.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'package:itruck_dispatch/textstyles.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/bottomnavbar.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/dispatcher_drawer.dart';
import 'package:itruck_dispatch/views/widgets/header.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:itruck_dispatch/views/widgets/loading.dart';
import 'package:search_map_location/utils/google_search/latlng.dart' as s;
// import 'package:search_map_location/utils/google_search/latlng.dart';

class DriverMapScreen extends StatefulWidget {
  final LoadModel? load;

  final destination;
  final source;
  const DriverMapScreen({Key? key, this.load, this.source, this.destination})
      : super(key: key);

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);

  LatLng? sourcelocation;
  LatLng? destination;

  void _onMapCreated(GoogleMapController controller) {
    // mapController = controller;
    _controller.complete(controller);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setmarkersandaddress();
    getMarker();
    getpolylinepoints();
    getdistanceandduration();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) async {
      // await settruckposition();

      // await getcurrentlocation();
    });
  }

  Uint8List? imageData;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer?.cancel();
  }

  Timer? timer;
  String sourceadd = '';
  String desadd = '';
  setmarkersandaddress() {
    if (widget.source is PickupModel) {
      sourcelocation = LatLng(widget.source!.pickupgeopoint!.latitude,
          widget.source!.pickupgeopoint!.longitude);
      sourceadd = widget.source!.pickup;
    } else if (widget.source is GeoPoint) {
      sourcelocation =
          LatLng(widget.source!.latitude, widget.source!.longitude);
      sourceadd = 'Your location';
    } else {
      sourceadd = widget.source!.delivery;

      sourcelocation = LatLng(widget.source!.deliverygeopoint!.latitude,
          widget.source!.deliverygeopoint!.longitude);
    }
    if (widget.destination is PickupModel) {
      desadd = widget.destination.pickup;
      destination = LatLng(widget.destination!.pickupgeopoint!.latitude,
          widget.source!.pickupgeopoint!.longitude);
    } else {
      desadd = widget.destination.delivery;
      destination = LatLng(widget.destination!.deliverygeopoint!.latitude,
          widget.destination!.deliverygeopoint!.longitude);
    }

    setState(() {});
  }

  // getoriginanddestination() {
  //   originadd = widget.load!.pickups!.firstWhere((element) => element.pickupgiopoint==  GeoPoint(sourcelocation!.latitude, sourcelocation!.longitude)).pickup!;
  // }

  getdistanceandduration() async {
    var originlat = sourcelocation!.latitude;
    var originlng = sourcelocation!.longitude;
    var deslat = destination!.latitude;
    var deslng = destination!.longitude;

    Dio dio = new Dio();
    Response response = await dio.get(
        "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=$originlat,$originlng&destinations=$deslat,$deslng&key=$googleMapsApiKey");
    print(response.data);
    distance = response.data['rows'][0]['elements'][0]['distance']['text']
        .toString()
        .replaceAll(' mi', '');
    // if (response.data['rows'][0]['elements'][0]['duration']['text']
    //     .toString()
    //     .contains('hours')) {
    //   duration = response.data['rows'][0]['elements'][0]['duration']['text']
    //       .toString()
    //       .replaceAll(' hours ', ':')
    //       .replaceAll(' mins', '');
    //   if (duration.split(':').last.length == 1) {
    //     duration = response.data['rows'][0]['elements'][0]['duration']['text']
    //             .toString()
    //             .replaceAll(' hours ', ':0')
    //             .replaceAll(' mins', '') +
    //         'Hrs';
    //   } else {
    //     duration = response.data['rows'][0]['elements'][0]['duration']['text']
    //             .toString()
    //             .replaceAll(' hours ', ':')
    //             .replaceAll(' mins', '') +
    //         ' Hrs';
    //   }
    // } else {
    //   duration = response.data['rows'][0]['elements'][0]['duration']['text']
    //           .toString()
    //           .replaceAll(' hours ', ':')
    //           .replaceAll(' mins', '') +
    //       ' Mins';
    // }
    duration =
        response.data['rows'][0]['elements'][0]['duration']['text'].toString();

    print(distance);
    print(duration);
    setState(() {});
  }

  getcurrentlocation() async {
    // LoadModel? newload;
    // await FirebaseFirestore.instance
    //     .collection('Loads')
    //     .doc(widget.load!.docref!.id)
    //     .get()
    //     .then((value) async {
    //   if (value.data()!['currentlocation'] != null) {
    //     currentlocation = LatLng(value.data()!['currentlocation'].latitude,
    //         value.data()!['currentlocation'].longitude);
    //   }
    // });
    Location loc = Location();
    loc.getLocation().then((location) {
      currentlocation = location;
    });
    loc.onLocationChanged.listen((event) {
      currentlocation = event;
      setState(() {});
    });
    if (widget.source == widget.destination && currentlocation != null) {
      sourcelocation =
          LatLng(currentlocation!.latitude!, currentlocation!.longitude!);
      getdistanceandduration();
      getpolylinepoints();
    }
    GoogleMapController googleMapController = await _controller.future;
    if (currentlocation != null) {
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(
                  currentlocation!.latitude!, currentlocation!.longitude!),
              zoom: 12)));
    }
    if (mounted) {
      setState(() {});
    }
  }

  getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/truck.png");
    imageData = byteData.buffer.asUint8List();

    img.Image thumbnail =
        img.copyResize(img.decodePng(imageData!)!, width: 120, height: 120);
    imageData = img.encodePng(thumbnail) as Uint8List;
    setState(() {});
  }

  final Completer<GoogleMapController> _controller = Completer();
  String distance = '';
  String duration = '';
  List<LatLng> polylinecoordinates = [];
  LocationData? currentlocation;
  getpolylinepoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleMapsApiKey,
        PointLatLng(sourcelocation!.latitude, sourcelocation!.longitude),
        PointLatLng(destination!.latitude, destination!.longitude));
    if (result.points.isNotEmpty) {
      result.points.forEach((point) =>
          polylinecoordinates.add(LatLng(point.latitude, point.longitude)));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      drawer: DriverDrawer(),
      bottomNavigationBar: DriverBottomNavBar(),
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(top: SizeConfig.screenHeight * 0.1),
            height: SizeConfig.screenHeight * 0.62,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: sourcelocation!,
                zoom: 8.0,
              ),
              polylines: {
                Polyline(
                    polylineId: PolylineId('route'),
                    points: polylinecoordinates,
                    color: kPrimaryColor,
                    width: 6)
              },
              markers: {
                if (currentlocation != null && imageData != null)
                  Marker(
                      markerId: MarkerId('currentlocation'),
                      position: LatLng(currentlocation!.latitude!,
                          currentlocation!.longitude!),
                      anchor: Offset(0.5, 0.5),
                      icon: BitmapDescriptor.fromBytes(imageData!)),
                Marker(
                  markerId: MarkerId('source'),
                  position: sourcelocation!,
                ),
                Marker(
                  markerId: MarkerId('destination'),
                  position: destination!,
                ),
              },
            ),
          ),
          Header(
            height: SizeConfig.screenHeight * 0.18,
            child: Padding(
              padding: EdgeInsets.only(top: SizeConfig.screenHeight * 0.04),
              child: Container(
                height: 80,
                child: AppBar(
                  elevation: 0,
                  backgroundColor: kPrimaryColor,
                  title: Text(
                    'Map',
                    style: TextStyle(fontSize: 30),
                  ),
                  iconTheme: IconThemeData(color: Colors.black),
                  centerTitle: true,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: IconButton(
                          onPressed: null,
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
          Container(
            margin: EdgeInsets.only(top: SizeConfig.screenHeight * 0.72),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 3, right: 8),
                    child: Container(
                      width: SizeConfig.screenWidth,
                      decoration: BoxDecoration(
                          color: dashBoardCardColor2,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Origin',
                                style: mapdatatextstyle,
                              ),
                              Container(
                                width: SizeConfig.screenWidth * 0.4,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                    sourceadd,
                                    style: mapdatatextstyle,
                                  ),
                                ),
                              )
                            ],
                          ),
                          VerticalDivider(
                            color: Colors.black,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Destination',
                                style: mapdatatextstyle,
                              ),
                              Container(
                                width: SizeConfig.screenWidth * 0.4,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                    desadd,
                                    style: mapdatatextstyle,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 3, right: 8),
                    child: Container(
                      width: SizeConfig.screenWidth,
                      decoration: BoxDecoration(
                          color: dashBoardCardColor2,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Drive Time',
                                style: mapdatatextstyle,
                              ),
                              Text(
                                duration,
                                style: mapdatatextstyle,
                              )
                            ],
                          ),
                          VerticalDivider(
                            color: Color.fromRGBO(0, 0, 0, 1),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Distance',
                                style: mapdatatextstyle,
                              ),
                              Text(
                                distance + ' Miles',
                                style: mapdatatextstyle,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
