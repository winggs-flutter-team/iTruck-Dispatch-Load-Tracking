import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/models/dispatcher_model.dart';
import 'package:itruck_dispatch/models/driver_model.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:http/http.dart' as http;

sendmailtodispatcher(DispatcherModel dispatcher) async {
  var name = dispatcher.name;
  var email = dispatcher.email;
  var password = dispatcher.password;
  final smtpServer = gmail(mailId, pass);
  final message = Message()
    ..from = Address(mailId, 'iTruck Dispatch')
    ..recipients.add(dispatcher.email)
    ..subject = 'Welcome to iTruck Dispatch'
    ..html =
        '<h1>Welcome! Login into your account</h1>\n<h2>Dear $name</h2>\n<p>Please click the link below to login in to your account using...</p>\n<p>User Login : $email</p>\n<p>Password: $password</p>\n<a href="https://loadtracking.page.link/dispatcherlogin">Click here to login</a>';
  try {
    final sendReport = await send(message, smtpServer);
    print('Message sent: ' + sendReport.toString());
  } on MailerException catch (e) {
    // print('Message not sent.');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
  var twilioFlutter = TwilioFlutter(
      accountSid: ACCOUNT_SID, // replace *** with Account SID
      authToken: AUTH_TOKEN, // replace xxx with Auth Token
      twilioNumber: '+1' + TextFrom // replace .... with Twilio Number
      );
  try {
    await twilioFlutter.sendSMS(
        toNumber: '+1' + dispatcher.phonenumber!,
        messageBody:
            'Dear $name,your iTruckDispatch login details are:\nUser Login : $email\nPassword: $password\nClick on https://loadtracking.page.link/dispatcherlogin to login');
  } catch (e) {}
}

sendmsgtodriver(DriverModel driver, String company) async {
  var twilioFlutter = TwilioFlutter(
      accountSid: ACCOUNT_SID, // replace *** with Account SID
      authToken: AUTH_TOKEN, // replace xxx with Auth Token
      twilioNumber: '+1' + TextFrom // replace .... with Twilio Number
      );
  try {
    await twilioFlutter.sendSMS(
        toNumber: '+1' + driver.phonenumber!,
        messageBody:
            'Dear ${driver.name},You have received the load from $company \nClick on https://loadtracking.page.link/driverlogin to login');
  } catch (e) {}
}

void sendPushMessage(String body, String title, String token) async {
  try {
    body = body.split('@')[0];
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$fcmkey',
      },
      body: jsonEncode(
        {
          "notification": {
            "body": body,
            "title": title,
          },
          "priority": "high",
          "to": token,
        },
      ),
    );
    print('done');
  } catch (e) {
    print("error push notification");
  }
}
