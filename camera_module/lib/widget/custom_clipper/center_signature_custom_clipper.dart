import 'package:flutter/material.dart';

class CenterSignatureCustomClipper extends CustomClipper<Path> {

	@override
	Path getClip(Size size) {

		double x0 = size.width / 2;
		double y0 = size.height / 2;
		double dx = size.width / 3;
		double dy = size.height / 10;

		return Path()
			..addRect(Rect.fromLTRB(x0 - dx + 1.0, y0 - dy + 1.0, x0.toDouble() + dx.toDouble() + 1.0, y0.toDouble() + dy.toDouble() + 1.0))
			..addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
			..fillType = PathFillType.evenOdd;
	}

	@override
	bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}