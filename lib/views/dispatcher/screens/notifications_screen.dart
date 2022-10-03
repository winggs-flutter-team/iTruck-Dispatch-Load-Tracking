import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/functions/dispatcher_functions.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/bottomnavbar.dart';
import 'package:itruck_dispatch/views/dispatcher/widgets/dispatcher_drawer.dart';
import 'package:itruck_dispatch/views/widgets/header.dart';
import 'package:intl/intl.dart';

class DispatcherNotificationsScreen extends StatefulWidget {
  final DocumentReference docref;

  const DispatcherNotificationsScreen({Key? key, required this.docref})
      : super(key: key);

  @override
  State<DispatcherNotificationsScreen> createState() =>
      _DispatcherNotificationsScreenState();
}

class _DispatcherNotificationsScreenState
    extends State<DispatcherNotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      drawer: DispatcherDrawer(),
      bottomNavigationBar: DispatcherBottomNavBar(),
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
                    'Notifications',
                    style: TextStyle(fontSize: 30, letterSpacing: 1.3),
                  ),
                  iconTheme: IconThemeData(color: Colors.black),
                  centerTitle: true,
                ),
              ),
            ),
          ),
          StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('/Users')
                  .doc(widget.docref.id)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  if ((snapshot.data!.data()! as Map)['notifications'] !=
                      null) {
                    List notifications =
                        (snapshot.data!.data()! as Map)['notifications'];
                    DispatcherMethods()
                        .seennotification(widget.docref, notifications);
                    return Container(
                        child: ListView.builder(
                            itemCount: notifications.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              String text =
                                  notifications[index].toString().split('@')[0];
                              DateTime datetime = DateTime.parse(
                                  notifications[index]
                                      .toString()
                                      .split('@')[1]);
                              String date =
                                  DateFormat("MM/dd/yyyy").format(datetime);
                              String time =
                                  DateFormat("HH:mm a").format(datetime);

                              // return Center(child: Text(text + date + time));

                              return Column(
                                children: [
                                  ListTile(
                                    leading: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          date,
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          time,
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 13),
                                        )
                                      ],
                                    ),
                                    title: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 25.0),
                                      child: Text(
                                        text,
                                        style: TextStyle(
                                          fontSize: 17,
                                        ),
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.cancel_outlined,
                                        color: Colors.black,
                                      ),
                                      onPressed: null,
                                    ),
                                    onTap: () async {
                                      await DispatcherMethods()
                                          .deletenotification(widget.docref,
                                              notifications, index);
                                    },
                                  ),
                                  Divider(
                                    color: Colors.black,
                                  )
                                ],
                              );
                            }));
                  } else {
                    return Container(
                      child: Text('NO Notications'),
                    );
                  }
                }
              })
        ],
      )),
    );
  }
}
