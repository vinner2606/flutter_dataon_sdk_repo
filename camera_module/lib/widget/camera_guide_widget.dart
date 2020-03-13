import 'package:camera/camera.dart';
import 'package:camera_module/widget/custom_clipper/center_circle_custom_clipper.dart';
import 'package:camera_module/widget/custom_clipper/center_rectangle_custom_clipper.dart';
import 'package:camera_module/widget/custom_clipper/center_signature_custom_clipper.dart';
import 'package:camera_module/widget/custom_clipper/center_square_custom_clipper.dart';
import 'package:camera_module/util/enumeration.dart';
import 'package:flutter/material.dart';

class CameraGuideWidget extends StatelessWidget {
  final CameraType type;
  final CameraController controller;

  CameraGuideWidget({Key key, this.type, this.controller}) : super(key: key);

  Widget _cameraGuideType(CameraType cameraType) {
    if (cameraType == CameraType.NONE || null == cameraType) {
      return Container();
    } else if (cameraType == CameraType.CIRCLE) {
      return ClipPath(
        clipper: CenterCircleCustomClipper(),
        child: Container(
          color: Color.fromRGBO(0, 0, 0, 0.7),
        ),
      );
    } else if (cameraType == CameraType.RECTANGLE) {
      return ClipPath(
        clipper: CenterRectangleCustomClipper(),
        child: Container(
          color: Color.fromRGBO(0, 0, 0, 0.7),
        ),
      );
    } else if (cameraType == CameraType.SIGNATURE) {
      return ClipPath(
        clipper: CenterSignatureCustomClipper(),
        child: Container(
          color: Color.fromRGBO(0, 0, 0, 0.7),
        ),
      );
    }
    /*else if (cameraType == CameraType.SQUARE) {
			return ClipPath(
				clipper: CenterSquareCustomClipper(),
				child: Container(
					color: Color.fromRGBO(0, 0, 0, 0.7),
				),
			);
		}*/
  }

  @override
  Widget build(BuildContext context) {
    if (null == controller ||
        !controller.value.isInitialized ||
        controller?.value?.aspectRatio == null) {
      return Container(
        color: Colors.black,
      );
    } else {
      return AspectRatio(
        aspectRatio: controller?.value?.aspectRatio,
        child: _cameraGuideType(type),
      );
    }
  }
}
