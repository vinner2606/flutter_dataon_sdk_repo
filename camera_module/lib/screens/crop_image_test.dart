import 'dart:io';

import 'package:camera_module/util/enumeration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
//import 'package:image_crop/image_crop.dart';

class CropImage extends StatefulWidget {
  String filePath;
  CameraType cameraType;
  Size size;

  CropImage(this.filePath, this.cameraType, this.size);

  @override
  _CropImageState createState() => _CropImageState();
}

class _CropImageState extends State<CropImage> {
//	final cropKey = GlobalKey<CropState>();
  final imageKey = GlobalKey();
  File _file;
  File _sample;
  File _lastCropped;

  Rect rect;

  getRect() {
    switch (widget.cameraType) {
      case CameraType.CIRCLE:
        setState(() {
          rect = Rect.fromCircle(
            center: Offset(widget.size.width / 2, widget.size.height / 2),
            radius: widget.size.width * 0.40,
          );
        });
        break;
      /*case CameraType.SQUARE:

				Offset offsetPoint1 = Offset((widget.size.width - widget.size.width * 0.80)/2, (widget.size.height - widget.size.width * 0.80)/2);
				Offset offsetPoint2 = Offset((widget.size.width + widget.size.width * 0.80)/2, (widget.size.height + widget.size.width * 0.80)/2);
				setState(() {
					rect = Rect.fromPoints(offsetPoint1, offsetPoint2);
				});
				break;*/
      case CameraType.SIGNATURE:
        Offset offsetPoint1 = Offset(
            (widget.size.width - widget.size.width * 0.80) / 2,
            (widget.size.height - widget.size.width * 0.20) / 2);
        Offset offsetPoint2 = Offset(
            (widget.size.width + widget.size.width * 0.80) / 2,
            (widget.size.height + widget.size.width * 0.20) / 2);
        setState(() {
          rect = Rect.fromPoints(offsetPoint1, offsetPoint2);
        });
        break;
      case CameraType.RECTANGLE:
        Offset offsetPoint1 = Offset(
            (widget.size.width - widget.size.width * 0.80) / 2,
            (widget.size.height - widget.size.height * 0.80) / 2);
        Offset offsetPoint2 = Offset(
            (widget.size.width + widget.size.width * 0.80) / 2,
            (widget.size.height + widget.size.height * 0.80) / 2);
        setState(() {
          rect = Rect.fromPoints(offsetPoint1, offsetPoint2);
        });
        break;
      case CameraType.NONE:

        /// do nothing
        break;
    }
  }

  @override
  void initState() {
    super.initState();

    _sample = File(widget.filePath);
    _file = File(widget.filePath);

    getRect();

    Future.delayed((Duration(seconds: 2)), () {
      _cropImage();
    });

//		SchedulerBinding.instance.addPostFrameCallback((_) => _cropImage());
  }

  @override
  Widget build(BuildContext context) {
//		return Scaffold(
//			body: Column(
//				children: <Widget>[
//					Expanded(
//						child: Crop.file(
//							_sample,
//							key: cropKey,
//							aspectRatio: null == rect ? 1/1 : rect.width / rect.height,
//						),
//					),
//				],
//			),
//		);
  }

  Future<void> _cropImage() async {
//		final scale = cropKey.currentState.scale;
//		final area = cropKey.currentState.area;
//		if (area == null) {
    // cannot crop, widget is not setup
    return;
  }

// scale up to use maximum possible number of pixels
// this will sample image in higher resolution to make cropped image larger
//		final sample = await ImageCrop.sampleImage(
//			file: _file,
//			preferredHeight: rect.width.toInt(),
//			preferredWidth: rect.height.toInt(),
//		);

//		final file = await ImageCrop.cropImage(
//			file: sample,
//			area: area,
//		);
//
//		sample.delete();
//
//		_lastCropped?.delete();
//		_lastCropped = file;
//
//		Navigator.pop(context, _lastCropped.path);
//	}

}
