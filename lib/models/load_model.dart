import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itruck_dispatch/models/delivery_model.dart';
import 'package:itruck_dispatch/models/dispatcher_model.dart';
import 'package:itruck_dispatch/models/driver_model.dart';
import 'package:itruck_dispatch/models/pickup_model.dart';
import 'package:itruck_dispatch/views/widgets/header.dart';

class LoadModel {
  List<PickupModel>? pickups;
  List<DeliveryModel>? deliveries;
  List<DriverModel>? drivers;
  DispatcherModel? dispatcher;
  double? truckposition;
  GeoPoint? previousdestination;
  GeoPoint? nextdestination;
  GeoPoint? currentlocation;
  GeoPoint? startinglocation;
  String? loadnumber;
  bool? accepted;
  DateTime? acceptabletill;
  String? notes;
  bool? completed;
  DocumentReference? docref;
  LoadModel(
      {this.pickups,
      this.accepted,
      this.docref,
      this.completed,
      this.deliveries,
      this.currentlocation,
      this.drivers,
      this.notes,
      this.acceptabletill,
      this.dispatcher,
      this.loadnumber,
      this.startinglocation,
      this.nextdestination,
      this.previousdestination,
      this.truckposition});

  loadModelfromJson(
      Map<dynamic, dynamic> json, DocumentReference docref) async {
    List<PickupModel> pickups = [];
    // print(json);
    for (var pickupdoc in json['pickups']) {
      // print(pickupdoc);
      await pickupdoc.get().then((value) {
        if (value.data() == null) {
          print(docref);
          print(value.reference);
        }
        pickups.add(PickupModel.fromJson(value.data(), value.reference));
      });
    }
    List<DeliveryModel> deliveries = [];
    for (var deliverydoc in json['deliveries']) {
      await deliverydoc.get().then((value) {
        deliveries.add(DeliveryModel.fromJson(value.data(), value.reference));
      });
    }
    List<DriverModel> drivers = [];
    for (var driverdoc in json['drivers']) {
      await driverdoc.get().then((value) {
        drivers.add(DriverModel.fromJson(value.data(), value.reference));
      });
    }
    DispatcherModel dispatcher = DispatcherModel();
    if (json['dispatcher'] != null) {
      await json['dispatcher'].get().then((value) async {
        var companyid = '';
        if (value.data() != null) {
          await value.data()['company'].get().then((documentSnapshot) {
            companyid = documentSnapshot.id;
            // _UsersData.add(DispatcherModel.fromJson(
            //     value.docs[i].data(), companyid));
            dispatcher = (DispatcherModel.fromJson(value.data(), companyid));
          });
        }
      });
    }
    return LoadModel(
        pickups: pickups,
        drivers: drivers,
        acceptabletill: json['acceptabletill'] != null
            ? json['acceptabletill'].toDate()
            : null,
        completed: json['completed'],
        docref: docref,
        dispatcher: dispatcher,
        loadnumber: json['loadnumber'].toString(),
        deliveries: deliveries,
        accepted: json['accepted'],
        currentlocation: json['currentlocation'],
        startinglocation: json['startinglocation'],
        previousdestination: json['previousdestination'],
        nextdestination: json['nextdestination'],
        notes: json['notes']);
  }
}
