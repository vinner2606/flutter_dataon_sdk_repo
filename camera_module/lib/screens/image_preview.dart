import 'dart:io' show File;
import 'dart:typed_data';

import 'package:camera_module/model/pic_detail.dart';
import 'package:camera_module/util/enumeration.dart';
import 'package:camera_module/widget/camera_crop_widget.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImagePreview extends StatefulWidget {
  final List<PicDetail> imagePathArray;
  CameraType cameraType;

  ImagePreview(this.imagePathArray, this.cameraType);

  @override
  _ImagePreviewState createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  int myImageCount;
  List<PicDetail> mList = List();
  PageController controller;

  @override
  void initState() {
    List<PicDetail> picIsNotDelete;
    try {
      picIsNotDelete =
          widget.imagePathArray.where((pic) => !pic.isDeleted).toList();
    } catch (e) {
      picIsNotDelete = List();
    }
    myImageCount = picIsNotDelete.length;
    mList = picIsNotDelete;
    controller = PageController();
  }

  List<Widget> imagePager() {
    List<Widget> myImgs = List();
    widget.imagePathArray.forEach((image) {
      if (!image.isDeleted) {
        myImgs.add(Container(
          child: Stack(
            children: <Widget>[
              Center(
                child: PhotoView(
                  imageProvider: FileImage(File(image.path)),
                  minScale: 0.5,
                ),
              ),
              CameraCropWidget(type: widget.cameraType),
            ],
          ),
          color: Colors.black,
        ));
      }
    });

    return myImgs;
  }

  Future<bool> _onWillPop() {
    Navigator.of(context).pop(widget.imagePathArray);
    return Future<bool>.value(false);
  }

  @override
  void dispose() {
    super.dispose();
    try {
      controller.dispose();
    } catch (e) {
      print("error in disposing controller");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Expanded(
                      flex: 6,
                      child: Container(
                        child: PageView(
                          children: imagePager(),
                          controller: controller,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              child: IconButton(
                                onPressed: () {
                                  // Delete click
                                  setState(() {
                                    widget
                                        .imagePathArray[widget.imagePathArray
                                            .indexOf(mList[
                                                (controller.page).toInt()])]
                                        .isDeleted = true;
                                    mList.removeAt((controller.page).toInt());
                                    myImageCount -= 1;
                                    if (myImageCount == 0) {
                                      Navigator.of(context)
                                          .pop(widget.imagePathArray);
                                    }
                                  });
                                },
                                icon: Icon(Icons.delete_outline,
                                    color: Colors.white),
                              ),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.redAccent),
                              padding: EdgeInsets.all(10.0),
                            ),
                            Container(
                              child: IconButton(
                                onPressed: () {
                                  navigateToDataOn(true);
                                },
                                icon: Icon(Icons.check, color: Colors.white),
                              ),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.blue),
                              padding: EdgeInsets.all(10.0),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Align(
                  child: GestureDetector(
                    onTap: () {
                      _onWillPop();
                    },
                    child: Container(
                      padding: EdgeInsets.all(20.0),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  alignment: Alignment.topLeft,
                ),
              ],
            ),
          )),
    );
  }

  void navigateToDataOn(bool isNavigateToData) {
    Navigator.of(context).pop([isNavigateToData, widget.imagePathArray]);
  }
}
