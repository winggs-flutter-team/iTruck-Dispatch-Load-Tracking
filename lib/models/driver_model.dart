import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itruck_dispatch/models/load_model.dart';

class DriverModel {
  String? name;
  String? phonenumber;
  List<LoadModel>? loads;
  DocumentReference? docref;

  DriverModel({this.name, this.docref, this.phonenumber, this.loads});

  factory DriverModel.fromJson(
      Map<dynamic, dynamic> json, DocumentReference docref) {
    return DriverModel(
      name: json['name'],
      docref: docref,
      phonenumber: json['phonenumber'],
    );
  }
}
