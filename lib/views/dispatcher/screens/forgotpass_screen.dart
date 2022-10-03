import 'dart:math';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:itruck_dispatch/auth/auth_functions.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/globals.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'package:itruck_dispatch/views/admin/screens/verify_email_screen.dart';
import 'package:itruck_dispatch/views/widgets/header.dart';
import 'package:itruck_dispatch/views/widgets/loading.dart';
import 'package:loading_overlay/loading_overlay.dart';

class DispatcherForgotPassScreen extends StatefulWidget {
  const DispatcherForgotPassScreen({Key? key}) : super(key: key);

  @override
  State<DispatcherForgotPassScreen> createState() =>
      _DispatcherForgotPassScreenState();
}

class _DispatcherForgotPassScreenState
    extends State<DispatcherForgotPassScreen> {
  String email = '';
  final _formKey = GlobalKey<FormState>();
  bool _isloading = false;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return LoadingOverlay(
      isLoading: _isloading,
      progressIndicator: loader,
      child: Scaffold(
        body: SingleChildScrollView(
            child: Form(
          key: _formKey,
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
                        'Forgot Password',
                        style: TextStyle(fontSize: 30),
                      ),
                      centerTitle: true,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 70),
                child: Row(
                  children: [
                    Text(
                      'Enter Your Email',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 10, right: 20),
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  onChanged: (value) {
                    setState(() {
                      email = value; //assigns value to email
                    });
                  },
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
                    onPressed: () async {
                      setState(() {
                        //starts loading
                        _isloading = true;
                      });
                      if (_formKey.currentState!.validate()) {
                        //validates the form

                        //executes send otp function
                        await AuthMethods()
                            .sendOtpToVerifyEmail(email, context, 'Dispatcher');
                        _isloading = false;
                        setState(() {});
                      } else
                        setState(() {
                          _isloading = false;
                        });
                    },
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
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
                          'Submit',
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
        )),
      ),
    );
  }
}
