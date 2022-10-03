import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/models/driver_model.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'package:itruck_dispatch/textstyles.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/bottomnavbar.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/dispatcher_drawer.dart';
import 'package:itruck_dispatch/views/driver/screens/driver_drawer.dart';
import 'package:itruck_dispatch/views/driver/widgets/bottomnavbar.dart';
import 'package:itruck_dispatch/views/widgets/header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({Key? key}) : super(key: key);

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  DriverModel driver = DriverModel();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setDispatcher();
  }

  _setDispatcher() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var phonenumber = prefs.getString('driverphonenumber');

    await FirebaseFirestore.instance
        .collection('/Users')
        .where('role', isEqualTo: 'Driver')
        .where('phonenumber', isEqualTo: phonenumber)
        .limit(1)
        .get()
        .then((value) async {
      driver =
          DriverModel.fromJson(value.docs[0].data(), value.docs[0].reference);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      drawer: DriverDrawer(),
      bottomNavigationBar: DriverBottomNavBar(),
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
                  backgroundColor: kPrimaryColor,
                  title: Text(
                    'Profile',
                    style: TextStyle(fontSize: 30, letterSpacing: 1.3),
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
            padding: const EdgeInsets.only(top: 80.0),
            child: Container(
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20.0, bottom: 15, top: 15),
                    child: Row(
                      children: [
                        Container(
                          width: SizeConfig.screenWidth * 0.4,
                          child: Text(
                            'Name',
                            style: profiletextstyle,
                          ),
                        ),
                        Container(
                          child: Text(
                            driver.name ?? '',
                            style: profiletextstyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 0.7,
                    color: Colors.black,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20.0, bottom: 15, top: 15),
                    child: Row(
                      children: [
                        Container(
                          width: SizeConfig.screenWidth * 0.4,
                          child: Text(
                            'Phone Number',
                            style: profiletextstyle,
                          ),
                        ),
                        Container(
                          child: Text(
                            driver.phonenumber != null
                                ? '(' +
                                    driver.phonenumber!.substring(0, 3) +
                                    ')' +
                                    '-' +
                                    driver.phonenumber!.substring(3, 6) +
                                    '-' +
                                    driver.phonenumber!.substring(6, 10)
                                : '',
                            style: profiletextstyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 0.7,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          )
        ],
      )),
    );
  }
}
