import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryModel {
  String? loadnumber;
  String? delivery;

  String? companyname;
  String? companyaddress;
  String? deliverydate;
  String? deliverytime;
  double? position;
  DateTime? deliverydatetime;
  GeoPoint? deliverygeopoint;
  bool? completed;
  DocumentReference? docref;

  DeliveryModel(
      {this.loadnumber,
      this.delivery,
      this.docref,
      this.completed,
      this.deliverygeopoint,
      this.companyname,
      this.deliverydatetime,
      this.companyaddress,
      this.deliverydate,
      this.position,
      this.deliverytime});
  factory DeliveryModel.fromJson(
      Map<dynamic, dynamic> json, DocumentReference docref) {
    return DeliveryModel(
        delivery: json['delivery'],
        docref: docref,
        loadnumber: json['loadnumber'],
        deliverygeopoint: json['deliverygeopoint'],
        deliverydate: json['deliverydate'],
        companyname: json['companyname'],
        deliverydatetime: json['deliverydatetime'].toDate(),
        deliverytime: json['deliverytime'],
        completed: json['completed']);
  }
}
