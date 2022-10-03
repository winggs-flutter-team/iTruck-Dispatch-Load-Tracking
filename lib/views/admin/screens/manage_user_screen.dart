import 'package:flutter/material.dart';
import 'package:fluttericon/web_symbols_icons.dart';
import 'package:itruck_dispatch/auth/auth_functions.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/providers/all_users_provider.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'package:itruck_dispatch/views/admin/screens/login_screen.dart';
import 'package:itruck_dispatch/views/admin/screens/user_detail_screen.dart';
import 'package:itruck_dispatch/views/admin/widgets/bottomnavbar.dart';
import 'package:itruck_dispatch/views/widgets/header.dart';
import 'package:provider/provider.dart';

class ManageUserScreen extends StatefulWidget {
  const ManageUserScreen({Key? key}) : super(key: key);

  @override
  State<ManageUserScreen> createState() => _ManageUserScreenState();
}

class _ManageUserScreenState extends State<ManageUserScreen> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context); //initialize sizeconfig
    context
        .read<AllUserProvider>()
        .fetchAllUsers(query); // provides all users list

    return Scaffold(
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
                      'Manage User',
                      style: TextStyle(fontSize: 30, letterSpacing: 1),
                    ),
                    centerTitle: true,
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: IconButton(
                            onPressed: () async {
                              await AuthMethods()
                                  .adminLogout(); //logout function

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
            //searchbar
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20, top: 20),
              child: TextFormField(
                style: TextStyle(fontSize: 16),
                cursorColor: Colors.black,
                onChanged: (value) {
                  setState(() {
                    query = value; // assignes value to search query
                  });
                },
                decoration: InputDecoration(
                    filled: true,
                    suffixIcon: IconButton(
                      icon: Icon(WebSymbols.search),
                      color: Colors.black,
                      onPressed: () {},
                    ),
                    hintText: 'Search',
                    fillColor: Colors.grey.shade300,
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            //building a consumer for users list provider
            Consumer<AllUserProvider>(builder: (context, value, child) {
              //returns a list of users if there are users to show
              // if the list of users is empty or thrownig some error it will return a no users are there...
              return value.Users.isNotEmpty && !value.error
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: value.Users.length,
                      itemBuilder: ((context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0, right: 20, top: 20),
                          child: InkWell(
                            onTap: (() {
                              //push to user detail screen
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UserDetailScreen(
                                            dispatcher: value.Users[index],
                                          )));
                            }),
                            child: Container(
                              height: 50,
                              width: SizeConfig.screenWidth,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: kPrimaryColor),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30.0),
                                    child: Text(
                                      value.Users[index].name!,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }))
                  : Container(
                      height: SizeConfig.screenHeight,
                      child: Center(child: Text('No user found.')),
                    );
            })
          ],
        ),
      ),
      bottomNavigationBar: AdminBottomNavBar(),
    );
  }
}
