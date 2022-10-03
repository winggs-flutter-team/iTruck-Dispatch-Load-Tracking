import 'package:flutter/material.dart';
import 'package:itruck_dispatch/auth/auth_functions.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'package:itruck_dispatch/views/admin/screens/login_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/login_screen.dart';
import 'package:itruck_dispatch/views/driver/screens/otp_screen.dart';
import 'package:itruck_dispatch/views/widgets/header.dart';

import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:itruck_dispatch/views/widgets/loading.dart';
import 'package:loading_overlay/loading_overlay.dart';

class DriverLoginScreen extends StatefulWidget {
  const DriverLoginScreen({Key? key}) : super(key: key);

  @override
  State<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  String? phonenumber;
  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return LoadingOverlay(
      isLoading: isloading,
      progressIndicator: loader,
      child: Scaffold(
          body: SingleChildScrollView(
        child: Column(
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
                        'Please enter your registered \nphone number to receive a \nverification code',
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
              padding: EdgeInsets.only(
                  top: 40.0, left: SizeConfig.screenWidth * 0.32),
              child: Row(
                children: [
                  const Text(
                    'Login as ',
                    style: TextStyle(fontSize: 18),
                  ),
                  const Text(
                    'Driver',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: Container(
                  width: SizeConfig.screenWidth * 0.6,
                  child: Row(
                    children: [
                      Container(
                          width: SizeConfig.screenWidth * 0.1,
                          child: TextFormField(
                            initialValue: '+1',
                          )),
                      Padding(
                        padding:
                            EdgeInsets.only(left: SizeConfig.screenWidth * 0.1),
                        child: Container(
                            width: SizeConfig.screenWidth * 0.4,
                            child: TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  phonenumber = value;
                                });
                              },
                              cursorColor: kPrimaryColor,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                } else if (!RegExp(r'(^[0-9]{10}$)')
                                    .hasMatch(value)) {
                                  return 'Please enter valid phonenumber';
                                  // ignore: unrelated_type_equality_checks
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: kPrimaryColor))),
                            )),
                      ),
                    ],
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isloading = true;
                    });
                    await AuthMethods().driverLogin(phonenumber!, context);
                    setState(() {
                      isloading = false;
                    });
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => const OtpScreen()));
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
                        'Continue',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            letterSpacing: 1),
                      ),
                    ),
                  )),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: 50.0, left: SizeConfig.screenWidth * 0.32),
              child: Row(
                children: [
                  const Text(
                    'Login as ',
                    style: TextStyle(fontSize: 18),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AdminLoginScreen()));
                    },
                    child: const Text(
                      'Admin',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: 20.0, left: SizeConfig.screenWidth * 0.32),
              child: Row(
                children: [
                  const Text(
                    'Login as ',
                    style: const TextStyle(fontSize: 18),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DispatcherLoginScreen()));
                    },
                    child: const Text(
                      'Dispatcher',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}
