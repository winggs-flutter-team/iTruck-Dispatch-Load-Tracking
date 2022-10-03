import 'package:itruck_dispatch/models/company_model.dart';
import 'package:itruck_dispatch/models/load_model.dart';

class DispatcherModel {
  int? id;

  String? name;
  String? email;
  String? newemail;
  String? phonenumber;
  String? password;
  String? newpassword;
  List<LoadModel>? loads;
  String? companyId;
  DispatcherModel(
      {this.id,
      this.name,
      this.email,
      this.phonenumber,
      this.password = '',
      this.loads,
      this.companyId,
      this.newpassword = '',
      this.newemail});

  factory DispatcherModel.fromJson(Map<dynamic, dynamic> json, companyid) {
    print(companyid);
    return DispatcherModel(
        id: json['userid'],
        name: json['name'],
        email: json['email'],
        phonenumber: json['phonenumber'],
        password: json['password'],
        companyId: companyid);
  }
}
