import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:itruck_dispatch/frebase_dynamic_link.dart';
import 'package:itruck_dispatch/models/delivery_model.dart';
import 'package:itruck_dispatch/models/load_model.dart';
import 'package:itruck_dispatch/models/pickup_model.dart';
import 'package:itruck_dispatch/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeolocationMethods {
  ondriverlocationchange(Location location) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var phonenumber = prefs.getString('driverphonenumber');
      var doc;
      DocumentReference? loaddoc;

      await FirebaseFirestore.instance
          .collection('/Users')
          .where('role', isEqualTo: 'Driver')
          .where('phonenumber', isEqualTo: phonenumber)
          .limit(1)
          .get()
          .then((value) {
        doc = value.docs[0].reference;
        loaddoc = value.docs[0].data()['currentload'];
      });
      if (loaddoc == null) {
        await FirebaseFirestore.instance
            .collection('Loads')
            .where('drivers', arrayContains: doc)
            .where('completed', isEqualTo: false)
            .where('accepted', isEqualTo: true)
            .limit(1)
            .get()
            .then((value) {
          loaddoc = value.docs[0].reference;
        });
      }
      if (loaddoc != null) {
        print('okkay');
        await FirebaseFirestore.instance
            .collection('/Loads')
            .doc(loaddoc!.id)
            .update({
          'currentlocation':
              GeoPoint(location.coords.latitude, location.coords.longitude)
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  addgeofences() async {
    List<bg.Geofence> geofences = [];
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var phonenumber = prefs.getString('driverphonenumber');
      var doc;
      var loaddoc;
      LoadModel? load;

      await FirebaseFirestore.instance
          .collection('/Users')
          .where('role', isEqualTo: 'Driver')
          .where('phonenumber', isEqualTo: phonenumber)
          .limit(1)
          .get()
          .then((value) async {
        doc = value.docs[0].reference;
        loaddoc = value.docs[0].data()['currentload'];
        await loaddoc.get().then((value) async {
          load =
              await LoadModel().loadModelfromJson(value.data() as Map, loaddoc);
        });
      });
      if (load == null) {
        await FirebaseFirestore.instance
            .collection('Loads')
            .where('drivers', arrayContains: doc)
            .where('completed', isEqualTo: false)
            .where('accepted', isEqualTo: true)
            .limit(1)
            .get()
            .then((value) async {
          loaddoc = value.docs[0];
          load = await LoadModel()
              .loadModelfromJson(loaddoc!.data() as Map, loaddoc!.reference);
        });
      }
      if (load != null) {
        for (var pickup in load!.pickups!) {
          geofences.add(bg.Geofence(
              identifier: 'P_${pickup.docref!.id}',
              radius: 200,
              notifyOnEntry: true,
              notifyOnExit: true,
              latitude: pickup.pickupgeopoint!.latitude,
              longitude: pickup.pickupgeopoint!.longitude));
        }
        for (var delivery in load!.deliveries!) {
          if (load!.deliveries!.last == delivery) {
            geofences.add(bg.Geofence(
                identifier: 'D_${delivery.docref!.id}_L',
                radius: 200,
                notifyOnEntry: true,
                notifyOnExit: true,
                latitude: delivery.deliverygeopoint!.latitude,
                longitude: delivery.deliverygeopoint!.longitude));
          } else {
            geofences.add(bg.Geofence(
                identifier: 'D_${delivery.docref!.id}',
                radius: 200,
                notifyOnEntry: true,
                notifyOnExit: true,
                latitude: delivery.deliverygeopoint!.latitude,
                longitude: delivery.deliverygeopoint!.longitude));
          }
        }
      }
    } catch (e) {
      print(e.toString());
    }
    if (geofences.isNotEmpty) {
      await bg.BackgroundGeolocation.addGeofences(geofences);
      print('added');
      for (var geofence in geofences) {
        print(geofence.identifier);
      }
    }
  }

  ongeofence(bg.GeofenceEvent event) async {
    print('okay');
    if (event.action == 'EXIT') {
      print('ok2');
      if (event.identifier.startsWith('P_')) {
        PickupModel? pickup;
        String docid = event.identifier.replaceAll('P_', '');

        LoadModel? load;
        var pickupdoc =
            FirebaseFirestore.instance.collection('Pickups').doc(docid);
        await FirebaseFirestore.instance
            .collection('/Loads')
            .where('pickups', arrayContains: pickupdoc)
            .limit(1)
            .get()
            .then((value) async {
          load = await LoadModel()
              .loadModelfromJson(value.docs[0].data(), value.docs[0].reference);
        });

        await FirebaseFirestore.instance
            .collection('/Pickups')
            .doc(docid)
            .get()
            .then((value) {
          if (value.data() != null) {
            pickup = PickupModel.fromJson(value.data()!, value.reference);
          }
        }).catchError((e) => print(e));

        await FirebaseFirestore.instance
            .collection('/Pickups')
            .doc(docid)
            .update({'completed': true})
            .then((value) {})
            .catchError((e) => print(e));
        String notification;
        notification =
            'Pickup : ${pickup!.pickup!} is completed for load no ${pickup!.loadnumber!.toString()}.@${DateTime.now().toString()}';
        DocumentReference? dispatcherdoc;
        String? token;
        List? notifications;
        await FirebaseFirestore.instance
            .collection('/Users')
            .where('role', isEqualTo: 'Dispatcher')
            .where('email', isEqualTo: load!.dispatcher!.email!)
            .get()
            .then((value) {
          dispatcherdoc = value.docs[0].reference;
          notifications = (value.docs[0].data() as Map)['notifications'];
          token = (value.docs[0].data() as Map)['deviceToken'];
        });
        notifications!.add(notification);
        print(notifications);
        await FirebaseFirestore.instance
            .collection('/Users')
            .doc(dispatcherdoc!.id)
            .update({'notifications': notifications});
        // bg.BackgroundGeolocation.removeGeofence(event.identifier);
        if (token != null) {
          sendPushMessage(notification, 'Pickup Completed', token!);
        }
      }
      if (event.identifier.startsWith('D_')) {
        String docid = event.identifier.replaceAll('D_', '');
        docid = docid.replaceAll('_L', '');
        DeliveryModel? delivery;

        LoadModel? load;
        var deliverydoc =
            FirebaseFirestore.instance.collection('Deliveries').doc(docid);
        await FirebaseFirestore.instance
            .collection('/Loads')
            .where('deliveries', arrayContains: deliverydoc)
            .limit(1)
            .get()
            .then((value) async {
          load = await LoadModel()
              .loadModelfromJson(value.docs[0].data(), value.docs[0].reference);
        });

        await FirebaseFirestore.instance
            .collection('/Deliveries')
            .doc(docid)
            .get()
            .then((value) {
          if (value.data() != null) {
            delivery = DeliveryModel.fromJson(value.data()!, value.reference);
          }
        }).catchError((e) => print(e));
        await FirebaseFirestore.instance
            .collection('/Deliveries')
            .doc(docid)
            .update({'completed': true})
            .then((value) {})
            .catchError((e) => print(e));

        String notification;
        notification =
            'Delivery : ${delivery!.delivery!} is completed for load no ${delivery!.loadnumber!.toString()}.@${DateTime.now().toString()}';
        DocumentReference? dispatcherdoc;
        List? notifications;
        String? token;
        await FirebaseFirestore.instance
            .collection('/Users')
            .where('role', isEqualTo: 'Dispatcher')
            .where('email', isEqualTo: load!.dispatcher!.email!)
            .get()
            .then((value) {
          dispatcherdoc = value.docs[0].reference;
          notifications = (value.docs[0].data() as Map)['notifications'];
          token = (value.docs[0].data() as Map)['deviceToken'];
        });
        notifications!.add(notification);
        FirebaseFirestore.instance
            .collection('/Users')
            .doc(dispatcherdoc!.id)
            .update({'notifications': notifications});
        if (token != null) {
          sendPushMessage(notification, 'Delivery Completed', token!);
        }
        if (event.identifier.endsWith('_L')) {
          var loaddoc;
          var deliverydoc =
              FirebaseFirestore.instance.collection('Deliveries').doc(docid);
          await FirebaseFirestore.instance
              .collection('/Loads')
              .where('deliveries', arrayContains: deliverydoc)
              .limit(1)
              .get()
              .then((value) {
            loaddoc = value.docs[0];
          });
          await FirebaseFirestore.instance
              .collection('Loads')
              .doc(loaddoc.id)
              .update({'completed': true});

          String notification;
          notification =
              'Load no ${delivery!.loadnumber} is completed.@${DateTime.now()}';
          DocumentReference? dispatcherdoc;
          List? notifications;
          String? token;
          await FirebaseFirestore.instance
              .collection('/Users')
              .where('role', isEqualTo: 'Dispatcher')
              .where('email', isEqualTo: load!.dispatcher!.email!)
              .get()
              .then((value) {
            dispatcherdoc = value.docs[0].reference;
            notifications = (value.docs[0].data() as Map)['notifications'];
            token = (value.docs[0].data() as Map)['deviceToken'];
          });
          notifications!.add(notification);
          FirebaseFirestore.instance
              .collection('/Users')
              .doc(dispatcherdoc!.id)
              .update({'notifications': notifications});
          if (token != null) {
            sendPushMessage(notification, 'Load Completed', token!);
          }
          bg.BackgroundGeolocation.removeGeofences();
        }
        // bg.BackgroundGeolocation.removeGeofence(event.identifier);
      }
    }
  }
}
