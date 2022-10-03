import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/views/admin/screens/forgotpass_screen.dart';
import 'package:itruck_dispatch/views/admin/screens/login_screen.dart';
import 'package:itruck_dispatch/views/admin/screens/verify_email_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/login_screen.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import 'package:otp/otp.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itruck_dispatch/globals.dart';
import 'package:itruck_dispatch/views/driver/screens/driver_dashboard.dart';
import 'package:itruck_dispatch/views/driver/screens/otp_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import 'package:twilio_flutter/twilio_flutter.dart';

class AuthMethods {
//   adminLogin(String email, String password) async {
//     var res = await http.post(
//         Uri.parse(host +
//             '/api/auth/signin?apikey=' +
//             apikey +
//             '&username=' +
//             email +
//             '&password=' +
//             password),
//         headers: requestHeaders);
//     var jsonResponse = await json.decode(res.body);
//     if (res.statusCode == 200) {
//       //on statuscode 200
//       if (jsonResponse['statusCode'] == 1) {
//         //on success
//         //get session
//         SharedPreferences prefs = await SharedPreferences.getInstance();
// //set admin loggedin session to true
//         prefs.setBool('adminloggedin', true);
//         prefs.setString('email', email);
//         return true; // returns true for success
//       } else // on error
//         return jsonResponse['response']; //returns error message
//     } else {
//       // on statuscode is not 200
//       return jsonResponse['response']; // returns error message
//     }
//   }

  adminLogin(String email, String password) async {
    try {
      bool isadmin = false;
      await FirebaseFirestore.instance
          .collection('/Users')
          .where('email', isEqualTo: email)
          .where('role', isEqualTo: 'Admin')
          .limit(1)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          isadmin = true;
        }
      });
      if (!isadmin) {
        return 'You are not an admin';
      }
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      var currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
//set dispatcher loggedin session to true
        prefs.setBool('adminloggedin', true);
        prefs.setString('adminemail', email);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return 'The email provided is not valid.';
      } else if (e.code == 'wrong-password') {
        return 'Password doesn\'t match.';
      } else if (e.code == 'user-not-found') {
        return 'No user corresponding to the given email.';
      }
    } catch (e) {
      return e.toString();
    }
  }

  dispatcherLogin(String email, String password) async {
    try {
      bool isdispatcher = false;
      String? docid;
      await FirebaseFirestore.instance
          .collection('/Users')
          .where('email', isEqualTo: email)
          .where('role', isEqualTo: 'Dispatcher')
          .limit(1)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          isdispatcher = true;
          docid = value.docs[0].id;
        }
      });
      if (!isdispatcher) {
        return 'You are not a dispatcher';
      }
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      var currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
//set dispatcher loggedin session to true
        prefs.setBool('dispatcherloggedin', true);
        prefs.setString('dispatcheremail', email);

        FirebaseMessaging.instance.getToken().then((token) {
          FirebaseFirestore.instance
              .collection('/Users')
              .doc(docid)
              .update({'deviceToken': token});
        });
        return true;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return 'The email provided is not valid.';
      } else if (e.code == 'wrong-password') {
        return 'Password doesn\'t match.';
      } else if (e.code == 'user-not-found') {
        return 'No user corresponding to the given email.';
      }
    } catch (e) {
      return e.toString();
    }
  }

  driverLogin(String phonenumber, BuildContext context) async {
//     String verificationid;

//     bool codesent = false;

//     bool isdriver = false;
//     await FirebaseFirestore.instance
//         .collection('/Users')
//         .where('phonenumber', isEqualTo: phonenumber)
//         .where('role', isEqualTo: 'Driver')
//         .limit(1)
//         .get()
//         .then((value) {
//       if (value.docs.isNotEmpty) {
//         isdriver = true;
//       }
//     });
//     if (!isdriver) {
//       return errorSnackBar(context, 'You are not a driver');
//     }
//     verified(AuthCredential authResult) async {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
// //set dispatcher loggedin session to true
//       prefs.setBool('driverloggedin', true);
//       prefs.setString('driverphonenumber', phonenumber);
//       FirebaseAuth.instance.signInWithCredential(authResult).whenComplete(() {
//         Navigator.push(context,
//             MaterialPageRoute(builder: (context) => DriverDashboardScreen()));
//       });
//     }

//     verificationfailed(FirebaseAuthException authException) {
//       print('${authException.message}');
//       return errorSnackBar(context, authException.message.toString());
//     }

//     smsSent(String verId, int? forceResend) {
//       verificationid = verId;
//       codesent = true;
//     }

//     autoTimeout(String verId) {
//       verificationid = verId;
//       Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (context) => OtpScreen(verificationid: verificationid)));
//     }

//     await FirebaseAuth.instance
//         .verifyPhoneNumber(
//             phoneNumber: '+91' + phonenumber,
//             timeout: const Duration(seconds: 5),
//             verificationCompleted: verified,
//             verificationFailed: verificationfailed,
//             codeSent: smsSent,
//             codeAutoRetrievalTimeout: autoTimeout)
//         .onError((error, stackTrace) {
//       return errorSnackBar(context, error.toString());
//     });
    bool isdriver = false;
    await FirebaseFirestore.instance
        .collection('/Users')
        .where('phonenumber', isEqualTo: phonenumber)
        .where('role', isEqualTo: 'Driver')
        .limit(1)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        isdriver = true;
      }
    });
    if (!isdriver) {
      return errorSnackBar(context, 'You are not a driver');
    }
    var code = OTP.generateTOTPCodeString(
        'JBSWY3DPEHPK3PXP', DateTime.now().millisecondsSinceEpoch);
    var twilioFlutter = TwilioFlutter(
        accountSid: ACCOUNT_SID, // replace *** with Account SID
        authToken: AUTH_TOKEN, // replace xxx with Auth Token
        twilioNumber: '+1' + TextFrom // replace .... with Twilio Number
        );
    try {
      print(code);
      print(phonenumber);
      // await twilioFlutter.sendSMS(
      //     toNumber: '+1' + phonenumber,
      //     messageBody: 'OTP for login at iTruck Dispatch is:\n $code');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OtpScreen(
                    otp: code,
                    phonenumber: phonenumber,
                  )));
    } catch (e) {
      errorSnackBar(context, 'Invalid number');
    }
  }

  adminLogout() async {
    //get session
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //set admin loggedin session to false
    prefs.setBool('adminloggedin', false);
    prefs.setString('adminemail', '');
  }

  dispatcherLogout() async {
    //get session
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //set admin loggedin session to false
    prefs.setBool('dispatcherloggedin', false);
    prefs.setString('dispatcheremail', '');
  }

  driverlogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //set admin loggedin session to false
    prefs.setBool('driverloggedin', false);
    prefs.setString('driverphonenumber', '');
  }

  sendOtpToVerifyEmail(String email, BuildContext context, String role) async {
    // try {
    //   await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    //   return true;
    // } catch (e) {
    //   return e.toString();
    // }
    // var res = await http.post(
    //     Uri.parse(host + '/api/send/otp?apikey=' + apikey + '&email=' + email),
    //     headers: requestHeaders);
    // var jsonResponse = await json.decode(res.body);
    // print(jsonResponse['response']['otp']);
    // if (res.statusCode == 200) {
    //   //on statuscode 200
    //   if (jsonResponse['statusCode'] == 1) {
    //     // on success
    //     return true; // returns true for success
    //   } else // on error
    //     return jsonResponse['response']; // returns error message
    // } else {
    //   // on statuscode is not 200
    //   return jsonResponse['response']; // returns error message
    // }
    bool rightrole = false;
    var userdoc;
    await FirebaseFirestore.instance
        .collection('/Users')
        .where('email', isEqualTo: email)
        .where('role', isEqualTo: role)
        .limit(1)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        rightrole = true;
        userdoc = value.docs[0];
      }
    });
    if (!rightrole) {
      return errorSnackBar(context, 'You are not an $role');
    }

    var code = OTP.generateTOTPCodeString(
        'JBSWY3DPEHPK3PXP', DateTime.now().millisecondsSinceEpoch);

    final smtpServer = gmail(mailId, pass);
    final message = Message()
      ..from = Address(mailId, 'iTruck Dispatch')
      ..recipients.add(email)
      ..subject = 'Forgot password'
      ..html = "<h1>$code</h1>\n<p>OTP</p>";

    try {
      final sendReport = await send(message, smtpServer);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VerifyEmailScreen(
                    sentotp: code,
                    userdoc: userdoc,
                  )));
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      // print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  verifyOtp(String otp) async {
    var res = await http.post(
        Uri.parse(host + '/api/verify/otp?apikey=' + apikey + '&otp=' + otp),
        headers: requestHeaders);
    var jsonResponse = await json.decode(res.body);
    if (res.statusCode == 200) {
      //on status code 200
      if (jsonResponse['statusCode'] == 1) {
        // on success
        return Tuple2(
            true,
            jsonResponse['response']['userid']
                ['userid']); // returns true with userid for success
      } else // on error
        return jsonResponse['response']; // returns error message
    } else {
      // on statuscode is not 200
      return jsonResponse['response']; // returns error message
    }
  }

  resetPass(userdoc, String pass, BuildContext context) async {
    // var res = await http.post(
    //     Uri.parse(host +
    //         '/api/forgotpassword?apikey=' +
    //         apikey +
    //         '&userid=' +
    //         userid +
    //         '&confirmpassword=' +
    //         cpass +
    //         '&password=' +
    //         pass),
    //     headers: requestHeaders);
    // var jsonResponse = await json.decode(res.body);
    // if (res.statusCode == 200) {
    //   //on status code 200
    //   if (jsonResponse['statusCode'] == 1) {
    //     // on success
    //     return true; // returns true for success
    //   } else // on error
    //     return jsonResponse['response']; //returns error message
    // } else {
    //   // on status code is not 200
    //   return jsonResponse['response']; //returns error message
    // }
    try {
      var email = userdoc.data()['email'];
      var password = userdoc.data()['password'];
      var role = userdoc.data()['role'];
      print(userdoc.data());
      print(email);
      print(password);
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email!, password: password);

      var currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        currentUser.updatePassword(pass);

        await FirebaseFirestore.instance
            .collection('/Users')
            .doc(userdoc.id)
            .update({'password': pass}).catchError((e) {
          print(e);
        });
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          if (role == 'Admin')
            return AdminLoginScreen();
          else
            return DispatcherLoginScreen();
        }));
      }
    } catch (e) {
      return errorSnackBar(context, e.toString());
    }
  }
}
