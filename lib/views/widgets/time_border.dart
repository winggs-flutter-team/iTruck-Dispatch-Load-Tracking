import 'package:flutter/material.dart';
import 'package:itruck_dispatch/constants.dart';

import 'package:itruck_dispatch/size_config.dart';

class TimeRemain extends StatelessWidget {
  final height;
  final width;
  final Color? color;
  final Widget? child;
  const TimeRemain(
      {Key? key, required this.height, this.child, this.width, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      height: this.height,
      width: this.width,
      child: Stack(children: [
        CustomPaint(
            painter: LinePainter(color: color!),
            child: Container(
              height: this.height.toDouble(),
              color: Colors.transparent,
            )),
        if (child != null) this.child!
      ]),
    );
  }
}

class LinePainter extends CustomPainter {
  final Color color;
  LinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint _paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.3, 0);
    path.moveTo(size.width * 0.7, 0);
    path.lineTo(size.width, 0);
    path.moveTo(0, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);

    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return false;
  }
}
