import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:itruck_dispatch/auth/auth_functions.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/globals.dart';
import 'package:itruck_dispatch/models/admin_model.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'package:itruck_dispatch/views/admin/screens/admin_dashboard.dart';
import 'package:itruck_dispatch/views/admin/screens/forgotpass_screen.dart';
import 'package:itruck_dispatch/views/dispatcher/screens/login_screen.dart';
import 'package:itruck_dispatch/views/driver/screens/login_screen.dart';
import 'package:itruck_dispatch/views/driver/widgets/load_data_table.dart';
import 'package:itruck_dispatch/views/widgets/header.dart';
import 'package:itruck_dispatch/views/widgets/loading.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  bool _showpass = false;
  AdminModel admin = AdminModel();
  final _formKey = GlobalKey<FormState>();
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
                height: SizeConfig.screenHeight * 0.32,
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
                          'Welcome To iTruck Dispatch',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w700),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: 20.0, left: SizeConfig.screenWidth * 0.32),
                child: Row(
                  children: [
                    const Text(
                      'Login as ',
                      style: TextStyle(fontSize: 18),
                    ),
                    const Text(
                      'Admin',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  ],
                ),
              ),
              Form(
                  key: _formKey,
                  child: Column(children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20.0, top: 30, right: 20),
                      child: TextFormField(
                        style: TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        onChanged: ((value) {
                          setState(() {
                            admin.email = value; //assigns value to email
                          });
                        }),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          } else if (!EmailValidator.validate(value)) {
                            return 'Please enter valid email';
                            // ignore: unrelated_type_equality_checks
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            alignLabelWithHint: true,
                            label: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                'Enter Email',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            filled: true,
                            fillColor: kPrimaryColor,
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(10))),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20.0, top: 30, right: 20),
                      child: TextFormField(
                        style: TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        obscureText: !_showpass,
                        onChanged: ((value) {
                          setState(() {
                            admin.password = value; //assigns value to password
                          });
                        }),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            alignLabelWithHint: true,
                            label: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                'Enter Password',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            //icon to hide/show password
                            suffixIcon: IconButton(
                              icon: Icon(
                                !_showpass
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 20,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                //alternates visiblity of password
                                if (!_showpass) {
                                  setState(() {
                                    _showpass = true;
                                  });
                                } else {
                                  setState(() {
                                    _showpass = false;
                                  });
                                }
                              },
                            ),
                            filled: true,
                            fillColor: kPrimaryColor,
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(10))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isloading = true;
                            });
                            if (_formKey.currentState!.validate()) {
                              //validates form

                              //executes admin login function
                              AuthMethods()
                                  .adminLogin(admin.email!, admin.password!)
                                  .then((value) {
                                if (value == true) {
                                  // on successfully logged in
                                  setState(() {
                                    isloading = false;
                                  });
                                  //push to admin dashboard
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AdminDashboard()));
                                } else {
                                  // on having error while login
                                  setState(() {
                                    isloading = false;
                                  });
                                  //shows errorbar at bottom
                                  return errorSnackBar(context, value);
                                }
                              });
                            } else
                              setState(() {
                                isloading = false;
                              });
                          },
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
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
                                'Login',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    letterSpacing: 1),
                              ),
                            ),
                          )),
                    ),
                  ])),
              Padding(
                padding: EdgeInsets.only(
                    top: 30.0, left: SizeConfig.screenWidth * 0.23),
                child: Row(
                  children: [
                    const Text(
                      'Forgot Password? ',
                      style: TextStyle(fontSize: 18),
                    ),
                    InkWell(
                      onTap: () {
                        //push to forgot password screen
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPassScreen()));
                      },
                      child: const Text(
                        'Click Here',
                        style: TextStyle(fontSize: 18, color: Colors.red),
                      ),
                    ),
                  ],
                ),
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
                                builder: (context) => DriverLoginScreen()));
                      },
                      child: const Text(
                        'Driver',
                        style: TextStyle(fontSize: 18, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: 20.0, left: SizeConfig.screenWidth * 0.32, bottom: 50),
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
        ),
      ),
    );
  }
}
