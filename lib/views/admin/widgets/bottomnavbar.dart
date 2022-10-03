import 'package:flutter/material.dart';
import 'package:itruck_dispatch/views/admin/screens/creat_user_screen.dart';
import 'package:itruck_dispatch/views/admin/screens/manage_user_screen.dart';

class AdminBottomNavBar extends StatefulWidget {
  const AdminBottomNavBar({Key? key}) : super(key: key);

  @override
  State<AdminBottomNavBar> createState() => _AdminBottomNavBarState();
}

class _AdminBottomNavBarState extends State<AdminBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      showUnselectedLabels: false, //hiding labels
      showSelectedLabels: false, //hiding labels
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: InkWell(
              onTap: () {
                //push to create user screen
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CreatUserScreen()));
              },
              child: Container(
                  child: Image(
                      image: AssetImage('assets/navbaricons/create_user.png'))),
            ),
            label: 'create user'),
        BottomNavigationBarItem(
          icon: InkWell(
            onTap: (() {
              //push to manage user screen
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ManageUserScreen()));
            }),
            child: Container(
                child: Image(
                    image: AssetImage('assets/navbaricons/manage_user.png'))),
          ),
          label: 'Business',
        ),
      ],
    );
  }
}
