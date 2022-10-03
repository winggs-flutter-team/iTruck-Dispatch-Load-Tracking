import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:itruck_dispatch/globals.dart';
import 'package:itruck_dispatch/models/company_model.dart';
import 'dart:convert';

import 'package:itruck_dispatch/models/dispatcher_model.dart';

// for the All Services page

class AllCompaniesProvider extends ChangeNotifier {
  List<CompanyModel> _CompaniesData = [];

  bool _error = false;
  String _errorMessage = '';
  bool _hasData = false;

  get Companies => _CompaniesData;

  bool get error => _error;

  String get errorMessage => _errorMessage;

  bool get hasData => _hasData;

  // fetchAllCompanies() async {
  //   String Url = host + '/api/get/company?apikey=' + apikey;
  //   var response = await http.get(Uri.parse(Url), headers: requestHeaders);
  //   if (response.statusCode == 200) {
  //     try {
  //       var jsonResponse = json.decode(response.body)['response'] as List;

  //       _CompaniesData =
  //           await jsonResponse.map((e) => CompanyModel.fromJson(e)).toList();

  //       _error = false;
  //       _errorMessage = '';
  //       _hasData = true;
  //     } catch (e) {
  //       _error = true;
  //       _errorMessage = e.toString();
  //       _CompaniesData = [];
  //       _hasData = false;
  //     }
  //   } else {
  //     _error = true;
  //     _errorMessage = '';
  //     _CompaniesData = [];
  //     _hasData = false;
  //   }

  //   notifyListeners(); // fetching all categories
  // }
  fetchAllCompanies() async {
    try {
      await FirebaseFirestore.instance.collection('Companies').get().then(
        (value) {
          _CompaniesData.clear();
          for (var i = 0; i < value.docs.length; i++) {
            _CompaniesData.add(
                CompanyModel.fromJson(value.docs[i].data(), value.docs[i].id));
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
      _CompaniesData = [];
      _hasData = false;
    }
    notifyListeners(); // fetching all categories
  }
}
