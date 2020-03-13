import 'package:camera_module/widget/custom_clipper/center_circle_custom_clipper.dart';
import 'package:camera_module/widget/custom_clipper/center_rectangle_custom_clipper.dart';
import 'package:camera_module/widget/custom_clipper/center_signature_custom_clipper.dart';
import 'package:camera_module/widget/custom_clipper/center_square_custom_clipper.dart';
import 'package:camera_module/util/enumeration.dart';
import 'package:flutter/material.dart';

class CameraCropWidget extends StatelessWidget {

	final CameraType type;

	CameraCropWidget({Key key, this.type}) : super(key: key);

	Widget _cameraCropType(CameraType cameraType) {
		if (cameraType == CameraType.NONE || null == cameraType) {
			return Container();
		}
		else if (cameraType == CameraType.CIRCLE) {
			return ClipPath(
				clipper: CenterCircleCustomClipper(),
				child: Container(
					color: Color.fromRGBO(0, 0, 0, 1),
				),
			);
		}
		else if (cameraType == CameraType.RECTANGLE) {
			return ClipPath(
				clipper: CenterRectangleCustomClipper(),
				child: Container(
					color: Color.fromRGBO(0, 0, 0, 1),
				),
			);
		}
		else if (cameraType == CameraType.SIGNATURE) {
			return ClipPath(
				clipper: CenterSignatureCustomClipper(),
				child: Container(
					color: Color.fromRGBO(0, 0, 0, 1),
				),
			);
		}
		/*else if (cameraType == CameraType.SQUARE) {
			return ClipPath(
				clipper: CenterSquareCustomClipper(),
				child: Container(
					color: Color.fromRGBO(0, 0, 0, 1),
				),
			);
		}*/
	}

	@override
	Widget build(BuildContext context) {
		return _cameraCropType(type);
	}
}