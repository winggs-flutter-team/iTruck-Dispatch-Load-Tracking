import 'dart:math';

import 'package:flutter/material.dart';
import 'package:itruck_dispatch/constants.dart';
import 'package:itruck_dispatch/size_config.dart';

//widget for screen header

class Header extends StatelessWidget {
  final height;
  final Widget? child;
  const Header({Key? key, required this.height, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      height: this.height,
      child: Stack(children: [
        CustomPaint(
            painter: HeaderShape(),
            child: Container(
              height: this.height.toDouble(),
              color: Colors.transparent,
            )),
        if (child != null) this.child!
      ]),
    );
  }
}

//custom curve at the top of the screen

class HeaderShape extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..color = kPrimaryColor;

    Offset circleCenter = Offset(size.width / 2, size.height);

    Offset topLeft = Offset(0, 0);
    Offset bottomLeft = Offset(0, size.height * 0.85);
    Offset topRight = Offset(size.width, 0);
    Offset bottomRight = Offset(size.width, size.height * 0.85);

    Offset leftCurveControlPoint = Offset(circleCenter.dx * 0.5, size.height);
    Offset rightCurveControlPoint = Offset(circleCenter.dx * 1.6, size.height);

    final arcStartAngle = 200 / 180 * pi;
    final avatarLeftPointX = circleCenter.dx;
    final avatarLeftPointY = circleCenter.dy;
    Offset avatarLeftPoint =
        Offset(avatarLeftPointX, avatarLeftPointY); // the left point of the arc

    final arcEndAngle = -5 / 180 * pi;
    final avatarRightPointX = circleCenter.dx;
    final avatarRightPointY = circleCenter.dy;
    Offset avatarRightPoint = Offset(
        avatarRightPointX, avatarRightPointY); // the right point of the arc

    Path path = Path()
      ..moveTo(topLeft.dx,
          topLeft.dy) // this move isn't required since the start point is (0,0)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..quadraticBezierTo(leftCurveControlPoint.dx, leftCurveControlPoint.dy,
          avatarLeftPoint.dx, avatarLeftPoint.dy)
      ..quadraticBezierTo(rightCurveControlPoint.dx, rightCurveControlPoint.dy,
          bottomRight.dx, bottomRight.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
