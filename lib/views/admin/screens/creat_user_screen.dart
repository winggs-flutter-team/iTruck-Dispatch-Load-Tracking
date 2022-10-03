import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:itruck_dispatch/auth/auth_functions.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/functions/admin_functions.dart';
import 'package:itruck_dispatch/globals.dart';
import 'package:itruck_dispatch/models/company_model.dart';
import 'package:itruck_dispatch/models/dispatcher_model.dart';
import 'package:itruck_dispatch/providers/all_companies_provider.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'package:itruck_dispatch/textstyles.dart';
import 'package:itruck_dispatch/views/admin/screens/admin_dashboard.dart';
import 'package:itruck_dispatch/views/admin/screens/login_screen.dart';
import 'package:itruck_dispatch/views/admin/screens/manage_user_screen.dart';
import 'package:itruck_dispatch/views/admin/widgets/bottomnavbar.dart';
import 'package:itruck_dispatch/views/widgets/header.dart';

import 'package:fluttericon/web_symbols_icons.dart';
import 'package:itruck_dispatch/views/widgets/loading.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

class CreatUserScreen extends StatefulWidget {
  const CreatUserScreen({Key? key}) : super(key: key);

  @override
  State<CreatUserScreen> createState() => _CreatUserScreenState();
}

class _CreatUserScreenState extends State<CreatUserScreen> {
  bool _showpass = false;
  DispatcherModel dispatcher = DispatcherModel();
  bool _isloading = false;

//popup a dialog box after created a user
  Widget _buildPopupDialog(BuildContext context) {
    context
        .read<AllCompaniesProvider>()
        .fetchAllCompanies(); // companies list provider
    return new AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      backgroundColor: popupcolor,
      title: null,
      content: Container(
        decoration: BoxDecoration(color: popupcolor),
        child: Text(
          "Dispatcher created successfully and details sent to dispatcher's phone number and email.",
          style: popupdialogtextstyle,
          textAlign: TextAlign.center,
        ),
      ),
      actions: [
        ElevatedButton(
            onPressed: () {
              //push to manage users screen after pressing ok
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ManageUserScreen()));
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

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    context
        .read<AllCompaniesProvider>()
        .fetchAllCompanies(); // companies list provider

    return LoadingOverlay(
      // loading overlay after creating user
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
                          'Create User',
                          style: TextStyle(fontSize: 30),
                        ),
                        centerTitle: true,
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: IconButton(
                                onPressed: () async {
                                  await AuthMethods()
                                      .adminLogout(); // logout function

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AdminLoginScreen()));
                                },
                                icon: Icon(
                                  WebSymbols.logout,
                                  color: Colors.black,
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, top: 50, right: 20),
                  child: TextFormField(
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    onChanged: (value) {
                      setState(() {
                        dispatcher.name = value; //assign value to name
                      });
                    },
                    textCapitalization: TextCapitalization.sentences,
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
                            'Enter Dispatcher Name',
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
                      const EdgeInsets.only(left: 20.0, top: 20, right: 20),
                  child: TextFormField(
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    onChanged: (value) {
                      setState(() {
                        dispatcher.email = value; //assign value to email
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
                        alignLabelWithHint: true,
                        label: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            'Enter Dispatcher Email',
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
                      const EdgeInsets.only(left: 20.0, top: 20, right: 20),
                  child: TextFormField(
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    onChanged: (value) {
                      setState(() {
                        dispatcher.phonenumber =
                            value; // assign value to phonenumber
                      });
                    },
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      } else if (!RegExp(r'(^[0-9]{10}$)').hasMatch(value)) {
                        return 'Please enter valid phonenumber';
                        // ignore: unrelated_type_equality_checks
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        alignLabelWithHint: true,
                        label: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            'Enter Dispatcher Phone Number',
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
                      const EdgeInsets.only(left: 20.0, top: 20, right: 20),
                  child: TextFormField(
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    obscureText: !_showpass,
                    onChanged: (value) {
                      setState(() {
                        dispatcher.password = value;
                      });
                    },
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
                        // icon to hide/show password
                        suffixIcon: IconButton(
                          icon: Icon(
                            !_showpass
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 20,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            //alternate the visibility of password
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
                //building a consumer for compnies list provider
                Consumer<AllCompaniesProvider>(
                    builder: (context, value, child) {
                  //returns a dropdownbutton if there are compnies to show
                  // if the list of compnies is empty or thrownig some error it will return a loding...
                  return value.Companies.isNotEmpty && !value.error
                      ? Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0, top: 20, right: 20),
                          child: FormField<String>(
                            builder: (FormFieldState<String> state) {
                              return DropdownButtonHideUnderline(
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                      alignLabelWithHint: true,
                                      label: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 16.0),
                                        child: Text(
                                          'Company Name',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                      hintText: 'Select Company Name',
                                      hintStyle: TextStyle(color: Colors.black),
                                      filled: true,
                                      fillColor: kPrimaryColor,
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please enter a company name';
                                    }
                                    return null;
                                  },
                                  isDense: true,
                                  value: null,
                                  dropdownColor: kPrimaryColor,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      dispatcher.companyId = newValue;
                                    });
                                  },
                                  //mapping the compnies list to dorpdownmenuitems
                                  items: value.Companies.map<
                                          DropdownMenuItem<String>>(
                                      (CompanyModel company) {
                                    return DropdownMenuItem<String>(
                                      value: company.companyId.toString(),
                                      child: Text(
                                        company.companyname!,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ))
                      : Container(
                          child: Text('loading...'),
                        );
                }),
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              //start loading
                              _isloading = true;
                            });

                            if (_formKey.currentState!.validate()) {
                              //validates the form

                              //execute create user function
                              AdminFunctions()
                                  .createUser(dispatcher)
                                  .then((value) {
                                if (value == true) {
                                  //on successfully creating user
                                  setState(() {
                                    //stops loading
                                    _isloading = false;
                                  });
                                  //popup dialog
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        _buildPopupDialog(context),
                                  );
                                } else {
                                  //having error on creating user
                                  setState(() {
                                    //stops loading
                                    _isloading = false;
                                  });
                                  //shows errorbar at bottom
                                  return errorSnackBar(context, value);
                                }
                              });
                            } else // on invalid textfield input
                              setState(() {
                                //stops loading
                                _isloading = false;
                              });
                          },
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              )),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.green)),
                          child: Container(
                            height: 50,
                            width: SizeConfig.screenWidth * 0.25,
                            child: const Center(
                              child: const Text(
                                'Create',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    letterSpacing: 1),
                              ),
                            ),
                          )),
                      ElevatedButton(
                          onPressed: () {
                            //push to admin dashboard
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AdminDashboard()));
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
                            width: SizeConfig.screenWidth * 0.25,
                            child: const Center(
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    letterSpacing: 1),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        //adding bottomnav bar
        bottomNavigationBar: AdminBottomNavBar(),
      ),
    );
  }
}
