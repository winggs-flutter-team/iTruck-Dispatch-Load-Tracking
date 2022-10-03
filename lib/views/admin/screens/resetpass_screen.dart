import 'package:flutter/material.dart';
import 'package:itruck_dispatch/auth/auth_functions.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/functions/admin_functions.dart';
import 'package:itruck_dispatch/globals.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'package:itruck_dispatch/views/admin/screens/login_screen.dart';
import 'package:itruck_dispatch/views/driver/screens/login_screen.dart';
import 'package:itruck_dispatch/views/widgets/header.dart';
import 'package:itruck_dispatch/views/widgets/loading.dart';
import 'package:loading_overlay/loading_overlay.dart';

class ResetPassScreen extends StatefulWidget {
  final userdoc;

  const ResetPassScreen({Key? key, required this.userdoc}) : super(key: key);

  @override
  State<ResetPassScreen> createState() => _ResetPassScreenState();
}

class _ResetPassScreenState extends State<ResetPassScreen> {
  bool _showpass = false;
  bool _showconfirmpass = false;
  String pass = '';
  String cpass = '';
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
                    padding:
                        EdgeInsets.only(top: SizeConfig.screenHeight * 0.06),
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
                  padding: const EdgeInsets.only(left: 20.0, top: 40),
                  child: Row(
                    children: [
                      Text(
                        'Enter New Password',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, top: 10, right: 20),
                  child: TextFormField(
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    obscureText: !_showpass,
                    onChanged: (value) {
                      setState(() {
                        pass = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        //icon to hide/show pass
                        suffixIcon: IconButton(
                          icon: Icon(
                            !_showpass
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 20,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            //aternates visiblity of pass
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
                  padding: const EdgeInsets.only(left: 20.0, top: 40),
                  child: Row(
                    children: [
                      Text(
                        'Confirm Password',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, top: 10, right: 20),
                  child: TextFormField(
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    obscureText: !_showconfirmpass,
                    onChanged: (value) {
                      setState(() {
                        cpass = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            !_showconfirmpass
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 20,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (!_showconfirmpass) {
                              setState(() {
                                _showconfirmpass = true;
                              });
                            } else {
                              setState(() {
                                _showconfirmpass = false;
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
                      onPressed: () async {
                        setState(() {
                          _isloading = true;
                        });
                        if (_formKey.currentState!.validate()) {
                          await AuthMethods()
                              .resetPass(widget.userdoc, pass, context);
                          setState(() {
                            _isloading = false;
                          });
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
                        width: SizeConfig.screenWidth * 0.4,
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
          ),
        ),
      ),
    );
  }
}
