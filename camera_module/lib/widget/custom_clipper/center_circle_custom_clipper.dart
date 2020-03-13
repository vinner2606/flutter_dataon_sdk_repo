import 'package:flutter/material.dart';

class CenterCircleCustomClipper extends CustomClipper<Path> {

	@override
	Path getClip(Size size) {
		return Path()
			..addOval(Rect.fromCircle())
			..addOval(Rect.fromCircle(
				center: Offset(size.width / 2, size.height / 2),
				radius: size.width / 2.5
			))
			..addRect(new Rect.fromLTWH(0.0, 0.0, size.width, size.height))
			..fillType = PathFillType.evenOdd;
	}

	@override
	bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}