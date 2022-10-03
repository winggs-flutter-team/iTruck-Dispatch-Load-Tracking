import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:itruck_dispatch/globals.dart';
import 'package:itruck_dispatch/models/company_model.dart';
import 'dart:convert';

import 'package:itruck_dispatch/models/dispatcher_model.dart';
import 'package:itruck_dispatch/models/load_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// for the All Services page

class DispatcherLoadsProvider extends ChangeNotifier {
  List<LoadModel> _LoadsData = [];

  bool _error = false;
  String _errorMessage = '';
  bool _hasData = false;

  List<LoadModel> get LoadsData => _LoadsData;

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

  fetchAllLoads(DateTime startdate, DateTime enddate) async {
    _LoadsData.clear();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.getString('dispatcheremail');
    DocumentReference? doc;
    await FirebaseFirestore.instance
        .collection('/Users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get()
        .then((value) {
      doc = value.docs[0].reference;
    });
    if (startdate == DateTime.now() && enddate == DateTime.now()) {
      try {
        print(doc);
        await FirebaseFirestore.instance
            .collection('Loads')
            .where('dispatcher', isEqualTo: doc)
            .get()
            .then(
          (value) async {
            for (var i = 0; i < value.docs.length; i++) {
              _LoadsData.add(await LoadModel().loadModelfromJson(
                  value.docs[i].data(), value.docs[i].reference));
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
        _LoadsData = [];
        _hasData = false;
      }
    } else {
      try {
        List pickupsdocs = [];
        print(doc);
        await FirebaseFirestore.instance
            .collection('/Pickups')
            .where('pickupdatetime', isGreaterThanOrEqualTo: startdate)
            .where('pickupdatetime', isLessThan: enddate)
            .get();
        await FirebaseFirestore.instance
            .collection('Loads')
            .where('dispatcher', isEqualTo: doc!)
            .get()
            .then(
          (value) async {
            for (var i = 0; i < value.docs.length; i++) {
              _LoadsData.add(await LoadModel().loadModelfromJson(
                  value.docs[i].data(), value.docs[i].reference));
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
        _LoadsData = [];
        _hasData = false;
      }
    }
    notifyListeners(); // fetching all categories
  }
}
