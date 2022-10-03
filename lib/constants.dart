import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'package:itruck_dispatch/textstyles.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/loads_screen.dart';

const kPrimaryColor = const Color(0xFF6699CC);

const dashBoardCardColor1 = const Color(0xFF5F9EA0);
const dashBoardCardColor2 = const Color(0xFFDEB887);
const dashBoardCardColor3 = kPrimaryColor;
const dashBoardCardColor4 = const Color(0xFFF08080);
const dashBoardCardColor5 = const Color(0xFFFE99950);

const popupcolor = const Color(0xFFDEB887);

const timecolor2 = const Color(0xFFDECF47);
const timecolor1 = Colors.green;
const timecolor3 = Colors.red;

const googleMapsApiKey = 'AIzaSyAWddNZHuv8WiCNzNwZbxY1O-I3u2tMAaQ';

const String mailId = 'dm.itruckdispatch@gmail.com';
const String pass = 'dfnonxgrldamanmq';
String ACCOUNT_SID = "AC274289ade389eaff0b90f8069ed0059f";
String AUTH_TOKEN = "f9043f8016672db8dc8dcc97460cf2b0";
String TextFrom = "9809902020";

String fcmkey =
    "AAAAgrUBPYY:APA91bHeoUjEffdYWzxEa1BLsvqmiHIFMlAy8xCUeyrpEkbfjcGAXQy5vJbT1vpLUF0Amuf64jkxGpNEPaQEoweGHPfv_YiZNM-Z6X9lU7a1DhgBb9cK8xUUVWDfUpZOtpe3ndfXxcnZ";
//popup a dialog box after created a user
Widget buildPopupDialog(BuildContext context) {
  // companies list provider
  return new AlertDialog(
    actionsAlignment: MainAxisAlignment.center,
    backgroundColor: popupcolor,
    title: null,
    content: Container(
      decoration: BoxDecoration(color: popupcolor),
      child: Text(
        "Load created successfully and details sent on driver's phone number.",
        style: popupdialogtextstyle,
        textAlign: TextAlign.center,
      ),
    ),
    actions: [
      ElevatedButton(
          onPressed: () {
            //push to manage users screen after pressing ok
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DispatcherLoadsScreen()));
          },
          style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              )),
              backgroundColor: MaterialStateProperty.all(Colors.green)),
          child: Container(
            height: 35,
            width: SizeConfig.screenWidth * 0.12,
            child: const Center(
              child: const Text(
                'OK',
                style: TextStyle(
                    color: Colors.white, fontSize: 18, letterSpacing: 1),
              ),
            ),
          )),
    ],
  );
}
