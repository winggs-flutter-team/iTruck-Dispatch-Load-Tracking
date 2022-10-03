import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/web_symbols_icons.dart';
import 'package:itruck_dispatch/auth/auth_functions.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/frebase_dynamic_link.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'package:itruck_dispatch/textstyles.dart';
import 'package:itruck_dispatch/views/admin/screens/creat_user_screen.dart';
import 'package:itruck_dispatch/views/admin/screens/login_screen.dart';
import 'package:itruck_dispatch/views/admin/screens/manage_user_screen.dart';
import 'package:itruck_dispatch/views/widgets/dashboard_icon.dart';
import 'package:itruck_dispatch/views/widgets/header.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseDynamicLinkService.initDynamicLink(context);
  }

  @override
  Widget build(BuildContext context) {
    //to initialize sizeconfig
    SizeConfig().init(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            //Header with app bar
            Header(
              height: SizeConfig.screenHeight * 0.2,
              child: Padding(
                padding: EdgeInsets.only(top: SizeConfig.screenHeight * 0.06),
                child: Container(
                  height: 80,
                  child: AppBar(
                    automaticallyImplyLeading: false,
                    elevation: 0,
                    backgroundColor: kPrimaryColor,
                    title: Text(
                      'Dashboard',
                      style: TextStyle(fontSize: 30, letterSpacing: 1.3),
                    ),
                    iconTheme: IconThemeData(color: Colors.black),
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
              padding: const EdgeInsets.only(top: 90.0, left: 30, right: 30),
              child: Container(
                child: StaggeredGrid.count(
                  crossAxisCount: 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    Material(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      color: Colors.transparent,
                      elevation: 10,
                      child: InkWell(
                        onTap: () {
                          //push to create user screen
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CreatUserScreen()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: dashBoardCardColor1,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Create User',
                                style: dashboardbuttonsstyle,
                              ),
                              DashboardIcon(
                                  icon:
                                      'assets/dashboardicons/create_user.png'),
                            ],
                          ),
                          height: SizeConfig.screenHeight * 0.25,
                        ),
                      ),
                    ),
                    Material(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      color: Colors.transparent,
                      elevation: 10,
                      child: InkWell(
                        onTap: () {
                          //push to manage user screen

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ManageUserScreen()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: dashBoardCardColor2,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Manage User',
                                style: dashboardbuttonsstyle,
                              ),
                              DashboardIcon(
                                  icon:
                                      'assets/dashboardicons/manage_user.png'),
                            ],
                          )),
                          height: SizeConfig.screenHeight * 0.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
