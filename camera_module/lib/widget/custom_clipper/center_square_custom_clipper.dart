import 'package:flutter/material.dart';

class CenterSquareCustomClipper extends CustomClipper<Path> {

	@override
	Path getClip(Size size) {

		Offset offsetPoint1;
		Offset offsetPoint2;

		if (size.width > size.height) {
			offsetPoint1 = Offset((size.width - size.height * 0.80)/2, (size.height - size.height * 0.80)/2);
			offsetPoint2 = Offset((size.width + size.height * 0.80)/2, (size.height + size.height * 0.80)/2);
		}
		else {
			offsetPoint1 = Offset((size.width - size.width * 0.80)/2, (size.height - size.width * 0.80)/2);
			offsetPoint2 = Offset((size.width + size.width * 0.80)/2, (size.height + size.width * 0.80)/2);
		}

		return Path()
			..addRect(new Rect.fromPoints(offsetPoint1, offsetPoint2))
			..addRect(new Rect.fromLTWH(0.0, 0.0, size.width, size.height))
			..fillType = PathFillType.evenOdd;
	}

	@override
	bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}