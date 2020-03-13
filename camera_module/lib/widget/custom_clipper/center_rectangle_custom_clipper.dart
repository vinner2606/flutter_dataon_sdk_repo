import 'package:flutter/material.dart';

class CenterRectangleCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double x0 = size.width / 2;
    double y0 = size.height / 2;
    double dx = size.width * 2 / 5;
    double dy = size.height * 2 / 5;

    return Path()
      ..addRect(new Rect.fromLTRB((x0 - dx), (y0 - dy),
          x0.toDouble() + dx.toDouble(), y0.toDouble() + dy.toDouble()))
      ..addRect(new Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
