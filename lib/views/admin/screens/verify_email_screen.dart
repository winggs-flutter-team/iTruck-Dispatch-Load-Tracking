import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:itruck_dispatch/auth/auth_functions.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/globals.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'package:itruck_dispatch/views/admin/screens/resetpass_screen.dart';
import 'package:itruck_dispatch/views/widgets/header.dart';
import 'package:itruck_dispatch/views/widgets/loading.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String sentotp;

  final userdoc;

  const VerifyEmailScreen(
      {Key? key, required this.sentotp, required this.userdoc})
      : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  String otp = '';
  bool _isloading = false;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return LoadingOverlay(
      isLoading: _isloading,
      progressIndicator: loader,
      child: Scaffold(
        body: SingleChildScrollView(
            child: Column(
          children: [
            Header(
              height: SizeConfig.screenHeight * 0.2,
              child: Padding(
                padding: EdgeInsets.only(top: SizeConfig.screenHeight * 0.06),
                child: Container(
                  height: 80,
                  child: AppBar(
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    backgroundColor: kPrimaryColor,
                    title: Text(
                      'Verify',
                      style: TextStyle(fontSize: 30),
                    ),
                    centerTitle: true,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40.0, left: 50, right: 50),
              child: Container(
                child: Text(
                  'Please enter the verification code sent to your email',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
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
                onCompleted: (pin) {},
                onChanged: (pin) {
                  setState(() {
                    otp = pin; // entering otp
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: ElevatedButton(
                  onPressed: () {
                    if (widget.sentotp == otp) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ResetPassScreen(
                                    userdoc: widget.userdoc,
                                  )));
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
                    width: SizeConfig.screenWidth * 0.25,
                    child: const Center(
                      child: const Text(
                        'Proceed',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            letterSpacing: 1),
                      ),
                    ),
                  )),
            ),
          ],
        )),
      ),
    );
  }
}
