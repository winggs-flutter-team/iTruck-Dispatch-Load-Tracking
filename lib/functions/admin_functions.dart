import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:itruck_dispatch/models/dispatcher_model.dart';
import 'package:flutter/material.dart';
import 'package:itruck_dispatch/globals.dart';
import 'package:itruck_dispatch/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminFunctions {
  // createUser(DispatcherModel dispatcher) async {
  //   var res = await http.post(
  //       Uri.parse(host +
  //           '/api/create/user?apikey=' +
  //           apikey +
  //           '&email=' +
  //           dispatcher.email! +
  //           '&phone=+1' +
  //           dispatcher.phonenumber! +
  //           '&password=' +
  //           dispatcher.password! +
  //           '&username=' +
  //           dispatcher.name! +
  //           '&companyId=' +
  //           dispatcher.companyId!.toString()),
  //       headers: requestHeaders);
  //   var jsonResponse = await json.decode(res.body);
  //   if (res.statusCode == 200) {
  //     // on status code 200
  //     if (jsonResponse['statusCode'] == 1) {
  //       //on success
  //       return true; // returns true
  //     } else // on error
  //       return jsonResponse['response']; //returns error message
  //   } else {
  //     // on status code is not 200
  //     return jsonResponse['message']; //returns error message
  //   }
  // }
  createUser(DispatcherModel dispatcher) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: dispatcher.email!, password: dispatcher.password!);
      var currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        var company = await FirebaseFirestore.instance
            .collection('/Companies')
            .doc(dispatcher.companyId);

        FirebaseFirestore.instance.collection('/Users').add({
          'email': dispatcher.email,
          'name': dispatcher.name,
          'uid': currentUser.uid,
          'password': dispatcher.password,
          'phonenumber': dispatcher.phonenumber,
          'company': company,
          'notifications': [],
          'role': 'Dispatcher'
        }).catchError((e) => print(e));
      }
      sendmailtodispatcher(dispatcher);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The dispatcher already exists for that email.';
      }
    } catch (e) {
      return e.toString();
    }
  }

  // updateUser(DispatcherModel dispatcher) async {
  //   var res = await http.post(
  //       Uri.parse(host +
  //           '/api/update/user?apikey=' +
  //           apikey +
  //           '&userid=' +
  //           dispatcher.id!.toString() +
  //           '&email=' +
  //           dispatcher.email! +
  //           '&phone=+1' +
  //           dispatcher.phonenumber! +
  //           '&password=' +
  //           dispatcher.password! +
  //           '&username=' +
  //           dispatcher.name! +
  //           '&companyId=' +
  //           dispatcher.companyId!.toString()),
  //       headers: requestHeaders);
  //   var jsonResponse = await json.decode(res.body);
  //   print(jsonResponse);
  //   if (res.statusCode == 200) {
  //     // on status code 200
  //     if (jsonResponse['statusCode'] == 1) {
  //       // on success
  //       return true; // returns true
  //     } else //on error
  //       return jsonResponse['response']; // returns error message
  //   } else {
  //     // on status code is not 200
  //     return jsonResponse['message']; //returns error message
  //   }
  // }

  updateUser(DispatcherModel dispatcher) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: dispatcher.email!, password: dispatcher.password!);

      var currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        if (dispatcher.newemail != null) {
          currentUser.updateEmail(dispatcher.newemail!);
        }
        if (dispatcher.newpassword!.isNotEmpty) {
          currentUser.updatePassword(dispatcher.newpassword!);
        }
        var docid = '';

        await FirebaseFirestore.instance
            .collection('/Users')
            .where('uid', isEqualTo: currentUser.uid)
            .limit(1)
            .get()
            .then((value) {
          docid = value.docs[0].id;
          print(docid);
        });
        var company = await FirebaseFirestore.instance
            .collection('/Companies')
            .doc(dispatcher.companyId);
        await FirebaseFirestore.instance
            .collection('/Users')
            .doc(docid)
            .update({
          'name': dispatcher.name,
          'email': dispatcher.newemail != null
              ? dispatcher.newemail
              : dispatcher.email,
          'phonenumber': dispatcher.phonenumber,
          'company': company,
          'password': dispatcher.newpassword!.isNotEmpty
              ? dispatcher.newpassword
              : dispatcher.password
        }).catchError((e) {
          print(e);
        });
        return true;
      }
    } catch (e) {
      return e.toString();
    }
  }

  // deleteUser(DispatcherModel dispatcher) async {
  //   var res = await http.post(
  //       Uri.parse(host +
  //           '/api/delete/user?apikey=' +
  //           apikey +
  //           '&userid=' +
  //           dispatcher.id!.toString()),
  //       headers: requestHeaders);
  //   var jsonResponse = await json.decode(res.body);
  //   print(jsonResponse);
  //   if (res.statusCode == 200) {
  //     if (jsonResponse['statusCode'] == 1) {
  //       // on status code 200
  //       return true; // returns true
  //     } else //on error
  //       return jsonResponse['response']; // returns error message
  //   } else {
  //     // on status code is not 200
  //     return jsonResponse['message']; //returns error message
  //   }
  // }
  deleteUser(DispatcherModel dispatcher) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: dispatcher.email!, password: dispatcher.password!);

      var currentUser = FirebaseAuth.instance.currentUser;

      var doc;
      if (currentUser != null) {
        currentUser.delete();
        await FirebaseFirestore.instance
            .collection('/Users')
            .where('uid', isEqualTo: currentUser.uid)
            .limit(1)
            .get()
            .then((value) {
          doc = value.docs[0].reference;
        });
        await FirebaseFirestore.instance
            .runTransaction((transaction) async => transaction.delete(doc));
        return true;
      }
    } catch (e) {
      return e.toString();
    }
  }
}
