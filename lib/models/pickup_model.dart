import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:search_map_location/utils/google_search/latlng.dart';

class PickupModel {
  DocumentReference? docref;
  int? loadnumber;
  String? pickup;
  String? companyname;
  String? companyaddress;
  String? pickupdate;
  String? pickuptime;
  double? position;
  GeoPoint? pickupgeopoint;
  DateTime? pickupdatetime;
  bool? completed;
  PickupModel(
      {this.loadnumber,
      this.pickup,
      this.docref,
      this.completed,
      this.companyname,
      this.companyaddress,
      this.pickupdate,
      this.pickupgeopoint,
      this.position,
      this.pickuptime,
      this.pickupdatetime});

  factory PickupModel.fromJson(
      Map<dynamic, dynamic> json, DocumentReference docref) {
    return PickupModel(
        docref: docref,
        loadnumber: int.parse(json['loadnumber']),
        pickup: json['pickup'],
        pickupdate: json['pickupdate'],
        companyname: json['companyname'],
        pickuptime: json['pickuptime'],
        pickupgeopoint: json['pickupgeopoint'],
        pickupdatetime: json['pickupdatetime'].toDate(),
        completed: json['completed']);
  }
}
