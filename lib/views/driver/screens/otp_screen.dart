import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/globals.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'package:itruck_dispatch/views/driver/screens/driver_dashboard.dart';
import 'package:itruck_dispatch/views/widgets/header.dart';
import 'package:itruck_dispatch/views/widgets/loading.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpScreen extends StatefulWidget {
  final String otp;

  final String phonenumber;

  OtpScreen({Key? key, required this.otp, required this.phonenumber})
      : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String code = '';
  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return LoadingOverlay(
      isLoading: isloading,
      progressIndicator: loader,
      child: Scaffold(
        body: Column(
          children: [
            Header(
              height: SizeConfig.screenHeight * 0.35,
              child: Container(
                width: SizeConfig.screenWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Container(
                          height: SizeConfig.screenHeight * 0.12,
                          child: Image(
                              image:
                                  AssetImage('assets/logo/itruck_logo.png'))),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Text(
                        'Please enter your verification code',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          letterSpacing: 1,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 130.0, left: 50, right: 50),
              child: OTPTextField(
                length: 6,
                width: SizeConfig.screenWidth,
                fieldWidth: (SizeConfig.screenWidth - 180) / 6,
                style: TextStyle(fontSize: 17),
                textFieldAlignment: MainAxisAlignment.spaceAround,
                fieldStyle: FieldStyle.underline,
                onCompleted: (pin) {
                  code = pin;
                },
                onChanged: (value) {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: ElevatedButton(
                  onPressed: () async {
                    // setState(() {
                    //   isloading = true;
                    // });
                    // AuthCredential authCreds = PhoneAuthProvider.credential(
                    //     smsCode: code, verificationId: widget.verificationid);
                    // try {
                    //   await FirebaseAuth.instance
                    //       .signInWithCredential(authCreds);
                    //   Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) => DriverDashboardScreen()));
                    // } on FirebaseAuthException catch (e) {
                    //   return errorSnackBar(context, e.message.toString());
                    // }
                    // setState(() {
                    //   isloading = false;
                    // });

                    if (widget.otp == code) {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool('driverloggedin', true);
                      prefs.setString('driverphonenumber', widget.phonenumber);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DriverDashboardScreen()));
                    } else {
                      errorSnackBar(context, 'Invalid OTP');
                    }
                  },
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      )),
                      backgroundColor:
                          MaterialStateProperty.all(kPrimaryColor)),
                  child: Container(
                    height: 50,
                    width: SizeConfig.screenWidth * 0.4,
                    child: const Center(
                      child: const Text(
                        'Verify Now',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            letterSpacing: 1),
                      ),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
