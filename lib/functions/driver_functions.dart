import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:location/location.dart';

import 'package:itruck_dispatch/functions/geolocation_functions.dart';
import 'package:itruck_dispatch/globals.dart';
import 'package:itruck_dispatch/models/load_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverMethods {
  acceptload(
      DocumentReference docref, BuildContext context, LoadModel load) async {
    try {
      LocationData? currentlocation;
      Location loc = Location();
      await loc.getLocation().then((location) {
        currentlocation = location;
      });
      await FirebaseFirestore.instance
          .collection('/Loads')
          .doc(docref.id)
          .update({
            'accepted': true,
            'startinglocation': GeoPoint(
                currentlocation!.latitude!, currentlocation!.longitude!),
            'currentlocation': GeoPoint(
                currentlocation!.latitude!, currentlocation!.longitude!)
          })
          .then((value) {})
          .catchError((e) => print(e));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var phonenumber = prefs.getString('driverphonenumber');
      var doc;
      String name = '';
      print(phonenumber);
      await FirebaseFirestore.instance
          .collection('/Users')
          .where('role', isEqualTo: 'Driver')
          .where('phonenumber', isEqualTo: phonenumber)
          .limit(1)
          .get()
          .then((value) {
        doc = value.docs[0].reference;
        name = value.docs[0].data()['name'];
        print(name);
      });
      await FirebaseFirestore.instance
          .collection('/Users')
          .doc(doc.id)
          .update({'currentload': docref});
      String notification;
      notification =
          '$name accepted the Load no ${load.loadnumber}.@${DateTime.now()}';
      DocumentReference? dispatcherdoc;
      List? notifications;
      await FirebaseFirestore.instance
          .collection('/Users')
          .where('role', isEqualTo: 'Dispatcher')
          .where('email', isEqualTo: load.dispatcher!.email!)
          .get()
          .then((value) {
        dispatcherdoc = value.docs[0].reference;
        notifications = (value.docs[0].data() as Map)['notifications'];
      });
      if (notifications == null) {
        notifications = [];
      }
      notifications!.add(notification);
      print(notifications);
      print(dispatcherdoc!.id);
      FirebaseFirestore.instance
          .collection('/Users')
          .doc(dispatcherdoc!.id)
          .update({'notifications': notifications});
      await GeolocationMethods().addgeofences();
    } catch (e) {
      print(e);
      errorSnackBar(context, 'Someting went wrong.');
    }
  }
}
