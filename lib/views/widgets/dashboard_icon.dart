import 'package:flutter/material.dart';
import 'package:itruck_dispatch/size_config.dart';
import 'dart:ui' as ui;

//widget for dashboard icons

class DashboardIcon extends StatelessWidget {
  final icon;
  //passing icon on construction
  DashboardIcon({Key? key, required this.icon}) : super(key: key);
  // final size = SizeConfig.screenHeight * 0.1;
  @override
  Widget build(BuildContext context) {
    return Container(child: Image(image: AssetImage(icon)));
  }
}
