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
import 'package:itruck_dispatch/views/admin/screens/login_screen.dart';
import 'package:itruck_dispatch/views/admin/screens/manage_user_screen.dart';
import 'package:itruck_dispatch/views/admin/widgets/bottomnavbar.dart';
import 'package:itruck_dispatch/views/widgets/header.dart';

import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/web_symbols_icons.dart';
import 'package:itruck_dispatch/views/widgets/loading.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

class UserDetailScreen extends StatefulWidget {
  final DispatcherModel dispatcher;

  const UserDetailScreen({Key? key, required this.dispatcher})
      : super(key: key);

  @override
  State<UserDetailScreen> createState() =>
      _UserDetailScreenState(this.dispatcher);
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  bool _showpass = false;
  bool _editmode = false;
  bool _isloading = false;
  _UserDetailScreenState(DispatcherModel this.dispatcher);

  final DispatcherModel dispatcher;

//show popup on delete user pressed
  Widget _buildPopupDialog(BuildContext context) {
    return new AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      backgroundColor: popupcolor,
      title: null,
      content: Container(
        decoration: BoxDecoration(color: popupcolor),
        child: Text(
          'Do you really want to delete?',
          style: popupdialogtextstyle,
          textAlign: TextAlign.center,
        ),
      ),
      actions: [
        ElevatedButton(
            onPressed: () {
              //on no pressed push to manage user screen
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
                  'No',
                  style: TextStyle(
                      color: Colors.white, fontSize: 18, letterSpacing: 1),
                ),
              ),
            )),
        ElevatedButton(
            onPressed: () {
              //on yes pressed
              setState(() {
                _isloading = true;
              });
              //executes delete user function
              AdminFunctions().deleteUser(dispatcher).then((value) {
                if (value == true) {
                  //on successfully deleting user
                  setState(() {
                    _isloading = false;
                  });
                  //push to manage user screen
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ManageUserScreen()));
                } else {
                  // on having error while deleting user
                  setState(() {
                    _isloading = false;
                  });
                  //shows error bar at bottom
                  return errorSnackBar(context, value);
                }
              });
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
                  'Yes',
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
                          'User Detail',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: IconButton(
                          onPressed: (() {
                            //starts edit mode
                            setState(() {
                              _editmode = true;
                            });
                          }),
                          icon: Icon(
                            FontAwesome.edit,
                            color: Colors.grey.shade700,
                            size: 35,
                          )),
                    )
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, top: 30, right: 20),
                  child: TextFormField(
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    initialValue: widget.dispatcher.name!,
                    onChanged: (value) {
                      setState(() {
                        dispatcher.name = value; // changes name
                      });
                    },
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    readOnly: !_editmode,
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
                    readOnly: !_editmode,
                    onChanged: (value) {
                      setState(() {
                        dispatcher.newemail = value; //changes email
                      });
                    },
                    initialValue: widget.dispatcher.email,
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
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
                    initialValue: widget.dispatcher.phonenumber,
                    readOnly: !_editmode,
                    onChanged: (value) {
                      setState(() {
                        dispatcher.phonenumber = value; //changes phonenumber
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
                    onChanged: (value) {
                      setState(() {
                        dispatcher.newpassword = value; //changes pass
                      });
                    },
                    readOnly: !_editmode,
                    obscureText: !_showpass,
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
                                      hintStyle: TextStyle(color: Colors.white),
                                      filled: true,
                                      fillColor: kPrimaryColor,
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a company name';
                                    }
                                    return null;
                                  },
                                  isDense: true,
                                  dropdownColor: kPrimaryColor,
                                  value: dispatcher.companyId != null
                                      ? dispatcher.companyId
                                      : null,
                                  onChanged: _editmode
                                      ? (String? newValue) {
                                          setState(() {
                                            dispatcher.companyId = newValue;
                                          });
                                        }
                                      : null,
                                  items: value.Companies.map<
                                          DropdownMenuItem<String>>(
                                      (CompanyModel company) {
                                    print(company.companyId);
                                    return DropdownMenuItem<String>(
                                      value: company.companyId,
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
                      : Container(child: Text('loading...'));
                }),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isloading = true;
                            });
                            if (_formKey.currentState!
                                .validate()) // validates form
                              //executes update user function
                              AdminFunctions()
                                  .updateUser(dispatcher)
                                  .then((value) {
                                if (value == true) {
                                  //on successfully updating user
                                  setState(() {
                                    _isloading = false;
                                  });

                                  //push to manage user screen
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ManageUserScreen()));
                                } else {
                                  // on having error while updating user
                                  setState(() {
                                    _isloading = false;
                                  });
                                  return errorSnackBar(context, value);
                                }
                              });
                            else
                              setState(() {
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
                                'Update',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    letterSpacing: 1),
                              ),
                            ),
                          )),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ManageUserScreen()));
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
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            //shows popup for confirmation to delete user
                            showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  _buildPopupDialog(context),
                            );
                          },
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              )),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.red)),
                          child: Container(
                            height: 50,
                            width: SizeConfig.screenWidth * 0.25,
                            child: const Center(
                              child: const Text(
                                'Delete',
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
        bottomNavigationBar: AdminBottomNavBar(),
      ),
    );
  }
}
