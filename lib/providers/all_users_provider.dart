import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:itruck_dispatch/globals.dart';
import 'package:itruck_dispatch/models/company_model.dart';
import 'dart:convert';

import 'package:itruck_dispatch/models/dispatcher_model.dart';

// for the All Services page

class AllUserProvider extends ChangeNotifier {
  List<DispatcherModel> _UsersData = [];

  bool _error = false;
  String _errorMessage = '';
  bool _hasData = false;

  List<DispatcherModel> get Users => _UsersData;

  bool get error => _error;

  String get errorMessage => _errorMessage;

  bool get hasData => _hasData;

  // fetchAllUsers(String query) async {
  //   List<DispatcherModel> _TempUsersData = [];
  //   String Url = '';
  //   if (query.isEmpty)
  //     Url = host + '/api/get/user?apikey=' + apikey;
  //   else
  //     Url = host + '/api/search/user?apikey=' + apikey + '&keyword=' + query;

  //   var response = await http.get(Uri.parse(Url), headers: requestHeaders);
  //   if (response.statusCode == 200) {
  //     try {
  //       var jsonResponse = json.decode(response.body)['response'] as List;
  //       _UsersData =
  //           await jsonResponse.map((e) => DispatcherModel.fromJson(e)).toList();
  //       _error = false;
  //       _errorMessage = '';
  //       _hasData = true;
  //     } catch (e) {
  //       _error = true;
  //       _errorMessage = e.toString();
  //       _UsersData = [];
  //       _hasData = false;
  //     }
  //   } else {
  //     _error = true;
  //     _errorMessage = '';
  //     _UsersData = [];
  //     _hasData = false;
  //   }

  //   notifyListeners(); // fetching all categories
  // }

  fetchAllUsers(String query) async {
    _UsersData = [];

    List<DispatcherModel> _TempUsersData = [];
    if (query.isEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('/Users')
            .where('role', isEqualTo: 'Dispatcher')
            .get()
            .then(
          (value) async {
            _UsersData = List.filled(value.docs.length, DispatcherModel());

            for (var i = 0; i < value.docs.length; i++) {
              var companyid = '';

              print(value.docs[i].data());
              if (value.docs[i].data()['company'] != null) {
                await value.docs[i]
                    .data()['company']
                    .get()
                    .then((documentSnapshot) {
                  companyid = documentSnapshot.id;
                  print(companyid);
                  // _UsersData.add(DispatcherModel.fromJson(
                  //     value.docs[i].data(), companyid));
                  _UsersData[i] = (DispatcherModel.fromJson(
                      value.docs[i].data(), companyid));
                });
              }
            }
          },
        );
        _error = false;
        _errorMessage = '';
        _hasData = true;
      } catch (e) {
        print(e);
        _error = true;
        _errorMessage = e.toString();
        _UsersData = [];
        _hasData = false;
      }
    } else {
      try {
        await FirebaseFirestore.instance
            .collection('/Users')
            .where('role', isEqualTo: 'Dispatcher')
            .get()
            .then(
          (value) async {
            _UsersData = List.filled(value.docs.length, DispatcherModel());

            for (var i = 0; i < value.docs.length; i++) {
              var companyid = '';
              if (value.docs[i].data()['company'] != null) {
                await value.docs[i]
                    .data()['company']
                    .get()
                    .then((documentSnapshot) {
                  companyid = documentSnapshot.id;
                  // _UsersData.add(DispatcherModel.fromJson(
                  //     value.docs[i].data(), companyid));
                  _UsersData[i] = (DispatcherModel.fromJson(
                      value.docs[i].data(), companyid));
                });
              }
            }
          },
        );
        _UsersData = _UsersData.where((element) =>
            element.name!.toLowerCase().contains(query.toLowerCase())).toList();
        _error = false;
        _errorMessage = '';
        _hasData = true;
      } catch (e) {
        print(e);
        _error = true;
        _errorMessage = e.toString();
        _UsersData = [];
        _hasData = false;
      }
    }
    notifyListeners(); // fetching all categories
  }
}
