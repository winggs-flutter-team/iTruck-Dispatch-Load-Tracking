import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/globals.dart';
import 'package:itruck_dispatch/models/delivery_model.dart';
import 'package:itruck_dispatch/models/dispatcher_model.dart';
import 'package:itruck_dispatch/models/driver_model.dart';
import 'package:itruck_dispatch/models/load_model.dart';
import 'package:itruck_dispatch/models/pickup_model.dart';
import 'package:itruck_dispatch/utils.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/loads_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DispatcherMethods {
  postLoad(
      List<PickupModel> pickups,
      List<DeliveryModel> deliveries,
      List<DriverModel> drivers,
      pickuploadnumber,
      deliverylodnumber,
      notes,
      BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.getString('dispatcheremail');
    var dispatcherdoc;
    String? companyname;
    List<DocumentReference> pickuprefrences = [];
    List<DocumentReference> deliveryrefrences = [];
    List<DocumentReference> driverfrences = [];
    try {
//getting dispatcher document refrence
      await FirebaseFirestore.instance
          .collection('/Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get()
          .then((value) async {
        dispatcherdoc = value.docs[0].reference;
        await value.docs[0].data()['company'].get().then((documentSnapshot) {
          companyname = documentSnapshot.data()['name'];
        });
      });
//adding drivers
      for (var driver in drivers) {
        bool alreadyexits = false;
        //checking if driver is already stored in firestore
        await FirebaseFirestore.instance
            .collection('/Users')
            .where('role', isEqualTo: 'Driver')
            .where('phonenumber', isEqualTo: driver.phonenumber)
            .get()
            .then((value) {
          if (value.docs.isNotEmpty) {
            alreadyexits = true;
            for (var doc in value.docs) {
              driverfrences.add(doc.reference);
            }
          }
        });
        if (!alreadyexits) {
          //if not stored adding driver
          await FirebaseFirestore.instance.collection('/Users').add({
            'name': driver.name,
            'phonenumber': driver.phonenumber,
            'role': 'Driver'
          }).then((value) {
            driverfrences.add(value);
          }).catchError((e) => print(e));
        }
      }
      for (var pickup in pickups) {
        await FirebaseFirestore.instance.collection('/Pickups').add({
          'pickup': pickup.pickup,
          'pickupgeopoint': pickup.pickupgeopoint,
          'pickupdate': pickup.pickupdate,
          'pickuptime': pickup.pickuptime,
          'companyname': pickup.companyname,
          'loadnumber': pickuploadnumber,
          'pickupdatetime': pickup.pickupdatetime,
          'dispatcher': dispatcherdoc,
          'completed': false
        }).then((value) {
          pickuprefrences.add(value);
        }).catchError((e) => print(e));
      }

      for (var delivery in deliveries) {
        await FirebaseFirestore.instance.collection('/Deliveries').add({
          'delivery': delivery.delivery,
          'deliverygeopoint': delivery.deliverygeopoint,
          'deliverydate': delivery.deliverydate,
          'deliverytime': delivery.deliverytime,
          'companyname': delivery.companyname,
          'loadnumber': pickuploadnumber,
          'deliverydatetime': delivery.deliverydatetime,
          'dispatcher': dispatcherdoc,
          'completed': false
        }).then((value) {
          deliveryrefrences.add(value);
        }).catchError((e) => print(e));
      }
      await FirebaseFirestore.instance
          .collection('/Loads')
          .add({
            'pickups': pickuprefrences,
            'deliveries': deliveryrefrences,
            'loadnumber': pickuploadnumber,
            'dispatcher': dispatcherdoc,
            'drivers': driverfrences,
            'completed': false,
            'accepted': false,
            // 'archived': false,
            'acceptabletill': DateTime.now().add(const Duration(minutes: 30)),
            'notes': notes
          })
          .then((value) {})
          .catchError((e) => print(e));
      sendmsgtodriver(drivers[0], companyname!);
      showDialog(
        context: context,
        builder: (BuildContext context) => buildPopupDialog(context),
      );
    } catch (e) {
      return errorSnackBar(context, e.toString());
    }
  }

  updateload(
    LoadModel load,
    pickuploadnumber,
    notes,
    BuildContext context,
  ) async {
    var pickups = load.pickups;
    var deliveries = load.deliveries;
    var drivers = load.drivers;
    List<DocumentReference> pickuprefrences = [];
    List<DocumentReference> deliveryrefrences = [];
    List<DocumentReference> driverfrences = [];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.getString('dispatcheremail');
    var dispatcherdoc;

    try {
      //getting dispatcher document refrence
      await FirebaseFirestore.instance
          .collection('/Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get()
          .then((value) async {
        dispatcherdoc = value.docs[0].reference;
      });

//adding drivers
      for (var driver in drivers!) {
        if (driver.docref == null) {
          bool alreadyexits = false;
          //checking if driver is already stored in firestore
          await FirebaseFirestore.instance
              .collection('/Users')
              .where('role', isEqualTo: 'Driver')
              .where('phonenumber', isEqualTo: driver.phonenumber)
              .get()
              .then((value) {
            if (value.docs.isNotEmpty) {
              alreadyexits = true;
              for (var doc in value.docs) {
                driverfrences.add(doc.reference);
              }
            }
          });
          if (!alreadyexits) {
            //if not stored adding driver
            await FirebaseFirestore.instance.collection('/Users').add({
              'name': driver.name,
              'phonenumber': driver.phonenumber,
              'role': 'Driver'
            }).then((value) {
              driverfrences.add(value);
            }).catchError((e) => print(e));
          }
        } else {
          await FirebaseFirestore.instance
              .collection('/Users')
              .doc(driver.docref!.id)
              .update({'name': driver.name, 'phonenumber': driver.phonenumber});
          driverfrences.add(driver.docref!);
        }
      }
      print('ok driver');
      for (var pickup in pickups!) {
        if (pickup.docref == null) {
          await FirebaseFirestore.instance.collection('/Pickups').add({
            'pickup': pickup.pickup,
            'pickupgeopoint': pickup.pickupgeopoint,
            'pickupdate': pickup.pickupdate,
            'pickuptime': pickup.pickuptime,
            'companyname': pickup.companyname,
            'loadnumber': load.loadnumber,
            'pickupdatetime': pickup.pickupdatetime,
            'dispatcher': dispatcherdoc,
            'completed': false
          }).then((value) {
            pickuprefrences.add(value);
          }).catchError((e) => print(e));
        } else {
          await FirebaseFirestore.instance
              .collection('/Pickups')
              .doc(pickup.docref!.id)
              .update({
                'pickup': pickup.pickup,
                'pickupgeopoint': pickup.pickupgeopoint,
                'pickupdate': pickup.pickupdate,
                'pickuptime': pickup.pickuptime,
                'companyname': pickup.companyname,
                'loadnumber': pickuploadnumber,
                'pickupdatetime': pickup.pickupdatetime,
              })
              .then((value) {})
              .catchError((e) => print(e));
          pickuprefrences.add(pickup.docref!);
        }
      }
      print('ok pickup');

      for (var delivery in deliveries!) {
        if (delivery.docref == null) {
          await FirebaseFirestore.instance.collection('/Deliveries').add({
            'delivery': delivery.delivery,
            'deliverygeopoint': delivery.deliverygeopoint,
            'deliverydate': delivery.deliverydate,
            'deliverytime': delivery.deliverytime,
            'companyname': delivery.companyname,
            'loadnumber': pickuploadnumber,
            'deliverydatetime': delivery.deliverydatetime,
            'dispatcher': dispatcherdoc,
            'completed': false
          }).then((value) {
            deliveryrefrences.add(value);
          }).catchError((e) => print(e));
        } else {
          await FirebaseFirestore.instance
              .collection('/Deliveries')
              .doc(delivery.docref!.id)
              .update({
                'delivery': delivery.delivery,
                'deliverygeopoint': delivery.deliverygeopoint,
                'deliverydate': delivery.deliverydate,
                'deliverytime': delivery.deliverytime,
                'companyname': delivery.companyname,
                'loadnumber': pickuploadnumber,
                'deliverydatetime': delivery.deliverydatetime,
              })
              .then((value) {})
              .catchError((e) => print(e));
          deliveryrefrences.add(delivery.docref!);
        }
      }
      print('ok delivery');
      print(load.docref);
      await FirebaseFirestore.instance
          .collection('/Loads')
          .doc(load.docref!.id)
          .update({
            'pickups': pickuprefrences,
            'deliveries': deliveryrefrences,
            'loadnumber': pickuploadnumber,
            'dispatcher': dispatcherdoc,
            'drivers': driverfrences,
            'notes': notes
          })
          .then((value) {})
          .catchError((e) => print(e));
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => DispatcherLoadsScreen()));
    } catch (e) {
      return errorSnackBar(context, e.toString());
    }
  }

  resendload(LoadModel load, BuildContext context) async {
    List<DocumentReference> driverfrences = [];
    print(load.drivers!.length);
    try {
      for (var driver in load.drivers!) {
        if (driver.docref == null) {
          bool alreadyexits = false;
          //checking if driver is already stored in firestore
          await FirebaseFirestore.instance
              .collection('/Users')
              .where('role', isEqualTo: 'Driver')
              .where('phonenumber', isEqualTo: driver.phonenumber)
              .get()
              .then((value) {
            if (value.docs.isNotEmpty) {
              alreadyexits = true;
              for (var doc in value.docs) {
                driverfrences.add(doc.reference);
              }
            }
          });
          if (!alreadyexits) {
            //if not stored adding driver
            await FirebaseFirestore.instance.collection('/Users').add({
              'name': driver.name,
              'phonenumber': driver.phonenumber,
              'role': 'Driver'
            }).then((value) {
              driverfrences.add(value);
            }).catchError((e) => print(e));
          }
        } else {
          driverfrences.add(driver.docref!);
        }
      }
      await FirebaseFirestore.instance
          .collection('/Loads')
          .doc(load.docref!.id)
          .update({
            'drivers': driverfrences,
            'acceptabletill': DateTime.now().add(const Duration(minutes: 30)),
          })
          .then((value) {})
          .catchError((e) => print(e));
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => DispatcherLoadsScreen()));
    } catch (e) {
      print(e);
    }
  }

  deletenotification(
      DocumentReference docref, List notifications, int index) async {
    notifications.removeAt(index);
    try {
      await FirebaseFirestore.instance
          .collection('/Users')
          .doc(docref.id)
          .update({'notifications': notifications});
    } catch (e) {
      print(e);
    }
  }

  seennotification(DocumentReference docref, List notifications) async {
    for (var i = 0; i < notifications.length; i++) {
      if (!notifications[i].toString().contains('@seen')) {
        notifications[i] = '${notifications[i]}@seen';
      }
    }
    try {
      await FirebaseFirestore.instance
          .collection('/Users')
          .doc(docref.id)
          .update({'notifications': notifications});
    } catch (e) {
      print(e);
    }
  }
}
