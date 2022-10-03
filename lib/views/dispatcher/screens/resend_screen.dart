import 'package:flutter/material.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/functions/dispatcher_functions.dart';
import 'package:itruck_dispatch/models/driver_model.dart';
import 'package:itruck_dispatch/models/load_model.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/bottomnavbar.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/dispatcher_drawer.dart';
import 'package:itruck_dispatch/views/widgets/header.dart';
import 'package:itruck_dispatch/views/widgets/loading.dart';
import 'package:loading_overlay/loading_overlay.dart';

class ResendScreen extends StatefulWidget {
  final LoadModel load;

  const ResendScreen({Key? key, required this.load}) : super(key: key);

  @override
  State<ResendScreen> createState() => _ResendScreenState();
}

class _ResendScreenState extends State<ResendScreen> {
  bool isloading = false;
  final _formkey = GlobalKey<FormState>();
  DriverModel driver = DriverModel();

  setdriver() {
    driver = DriverModel(
        phonenumber: widget.load.drivers!.first.phonenumber,
        name: widget.load.drivers!.first.name,
        docref: widget.load.drivers!.first.docref);
    setState(() {});
  }

  _onresend(BuildContext context) async {
    // print(driver.phonenumber);
    // print(widget.load.drivers!.first.phonenumber!);
    if (driver.phonenumber == widget.load.drivers!.first.phonenumber!) {
      await DispatcherMethods().resendload(widget.load, context);
    } else {
      driver.docref = null;
      widget.load.drivers!.insert(0, driver);
      setState(() {});
      // print(widget.load.drivers!.length);
      await DispatcherMethods().resendload(widget.load, context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setdriver();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return LoadingOverlay(
      isLoading: isloading,
      progressIndicator: loader,
      child: Scaffold(
        drawer: DispatcherDrawer(),
        bottomNavigationBar: DispatcherBottomNavBar(),
        body: SingleChildScrollView(
          child: Form(
              key: _formkey,
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
                          backgroundColor: kPrimaryColor,
                          title: Text(
                            'Resend',
                            style: TextStyle(fontSize: 30),
                          ),
                          iconTheme: IconThemeData(color: Colors.black),
                          centerTitle: true,
                          actions: [
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: IconButton(
                                  onPressed: null,
                                  icon: Icon(
                                    Icons.notifications,
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
                        const EdgeInsets.only(left: 20.0, right: 20, top: 30),
                    child: Container(
                      height: 50,
                      width: SizeConfig.screenWidth,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: kPrimaryColor),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 30.0),
                            child: Text(
                              'Driver Details',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: TextFormField(
                      cursorColor: kPrimaryColor,
                      onChanged: (value) {
                        setState(() {
                          driver.name = value;
                        });
                      },
                      initialValue: driver.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 30),
                          border: UnderlineInputBorder(),
                          focusColor: kPrimaryColor,
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor)),
                          label: Padding(
                            padding: const EdgeInsets.only(
                              left: 0.0,
                            ),
                            child: Text(
                              'Driver Name',
                              style: TextStyle(fontSize: 15),
                            ),
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: TextFormField(
                      cursorColor: kPrimaryColor,
                      onChanged: (value) {
                        setState(() {
                          driver.phonenumber = value;
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
                      initialValue: driver.phonenumber,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 30),
                          border: UnderlineInputBorder(),
                          focusColor: kPrimaryColor,
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor)),
                          label: Padding(
                            padding: const EdgeInsets.only(
                              left: 0.0,
                            ),
                            child: Text(
                              'Driver Contact',
                              style: TextStyle(fontSize: 15),
                            ),
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0, bottom: 50),
                    child: ElevatedButton(
                        onPressed: () async {
                          if (_formkey.currentState!.validate()) {
                            setState(() {
                              isloading = true;
                            });
                            await _onresend(context);
                            setState(() {
                              isloading = false;
                            });
                          }
                        },
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            )),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.green)),
                        child: Container(
                          height: 50,
                          width: SizeConfig.screenWidth * 0.25,
                          child: const Center(
                            child: const Text(
                              'Resend',
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
      ),
    );
  }
}
