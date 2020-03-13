import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:ui';

import 'package:audioplayers/audio_cache.dart';
import 'package:camera/camera.dart';
import 'package:camera_module/model/pic_detail.dart';
import 'package:camera_module/model/camera_configuration.dart';
import 'package:camera_module/widget/camera_guide_widget.dart';
import 'package:camera_module/interface/callback.dart';
import 'package:camera_module/util/enumeration.dart';
import 'package:camera_module/screens/image_preview.dart';
import 'package:camera_module/permission/permission.dart';
import 'package:camera_module/util/util.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission/permission.dart';

//import 'package:permission_handler/permission_handler.dart';

class OpenCamera extends StatefulWidget {
  /// [cameraConfiguration] reference is for the camera configuration for capturing
  CameraConfiguration cameraConfiguration;

  /// [picDetailList] reference is for the list of images to open
  List<PicDetail> picDetailList;

  OpenCamera(this.cameraConfiguration, this.picDetailList);

  @override
  _OpenCameraState createState() => _OpenCameraState();
}

class _OpenCameraState extends State<OpenCamera> implements PermissionCallback {
  /// it shows the list of cameras present inside device from [getAvailableCameras]
  List<CameraDescription> camerasList;

  /// [controller] is required for the camera to start. It get initialized inside [onNewCameraSelect]
  CameraController controller;

  /// This [camMap] is created for getting the cameras with their respective position.
  HashMap camMap = HashMap<CameraLensDirection, CameraDescription>();

  /// [myCamDes] is created because of the toggle between cameras front and back
  CameraDescription myCamDes;

  /// [imagePath] holds the current image Path to show as Thumbnail.
  String imagePath;

  /// [myPicDetailList] takes up the images array and store them for further use.
  List<PicDetail> myPicDetailList;

  /// [count] is the initial value of image capture,
  /// this is needed for showing the [count]/[limit] as a text.
  int count;

  /// for shutter sound when capture image
  AudioCache audioCache = AudioCache();

  /// [getAvailableCameras] check the available cameras present inside the device.
  /// if Cameras are present, it start the camera persent at 0 index using [onNewCameraSelect].
  /// else it just go to the back screen
  getAvailableCameras() async {
    try {
      camerasList = await availableCameras();
    } on CameraException catch (e) {
      Util.logErrorWithErrorCode(e.code, e.description);
    }
    if (null == camerasList) {
      Navigator.pop(context);
    } else {
      camerasList.forEach((cameraDescription) {
        camMap[cameraDescription.lensDirection] = cameraDescription;
      });

      if (widget.cameraConfiguration.direction == CameraDirection.FRONT) {
        myCamDes = camMap[CameraLensDirection.front];
        onNewCameraSelect(camMap[CameraLensDirection.front]);
      } else {
        myCamDes = camMap[CameraLensDirection.back];
        onNewCameraSelect(camMap[CameraLensDirection.back]);
      }
    }
  }

  /// [onNewCameraSelect] uses [CameraDescription] as a param and initialize [controller].
  /// also it check if the widget is [mounted] then it refresh the layout using [setState]
  onNewCameraSelect(CameraDescription description) async {
    if (controller != null) {
      await controller.dispose();
    }

    ResolutionPreset preset;

    if (widget.cameraConfiguration.resolution == CameraResolution.LOW) {
      preset = ResolutionPreset.low;
    } else if (widget.cameraConfiguration.resolution ==
        CameraResolution.MEDIUM) {
      preset = ResolutionPreset.medium;
    } else if (widget.cameraConfiguration.resolution == CameraResolution.HIGH) {
      preset = ResolutionPreset.high;
    } else if (widget.cameraConfiguration.resolution ==
        CameraResolution.VERY_HEIGH) {
      preset = ResolutionPreset.veryHigh;
    } else if (widget.cameraConfiguration.resolution ==
        CameraResolution.ULTA_HEIGH) {
      preset = ResolutionPreset.ultraHigh;
    }

    controller = CameraController(description, preset);

    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        Util.logError('${controller.value.errorDescription}');
      }
    });

    try {
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } on CameraException catch (e) {
      Util.logErrorWithErrorCode(e.code, e.description);
    }
  }

  /// [getCameraLensIcon] determine the icon according to the toggle of camera direction
  IconData getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_rear;
      case CameraLensDirection.front:
        return Icons.camera_front;
      case CameraLensDirection.external:
        return Icons.camera;
    }
    throw ArgumentError('Unknown lens direction');
  }

  /// this is the onBackPressed method, here [controller.dispose] is called to finish the camera,
  /// and get back to the previous screen after returning [Future.value] to [true]
  Future<bool> _onWillPopScope() {
    controller.dispose();
    Navigator.of(context).pop(myPicDetailList.reversed.toList());
    return Future.value(false);
  }

  /// Go to [ImagePreview] activity
  _navigateToPreview() async {
    final result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ImagePreview(myPicDetailList.reversed.toList(),
            widget.cameraConfiguration.cameraType)));
    if (result is List) {
      setState(() {
        try {
          if (result.length > 0 && result[0] == true) {
            Navigator.of(context).pop(myPicDetailList);
            controller.dispose();
          } else {
            myPicDetailList = result;
            List<PicDetail> picIsNotDelete;
            try {
              picIsNotDelete =
                  myPicDetailList.where((pic) => !pic.isDeleted).toList();
            } catch (e) {
              picIsNotDelete = List();
            }

            if (picIsNotDelete.length > 0) {
              imagePath = picIsNotDelete[picIsNotDelete.length - 1].path;
              count = picIsNotDelete.length;

              if (count == widget.cameraConfiguration.maxImage) {
                Navigator.of(context).pop(myPicDetailList);
                controller.dispose();
              }
            } else {
              imagePath = null;
              count = 0;
            }
          }
        } catch (e) {
          print("error on image processing on back $e");
        }
      });
    }
  }

  /// To show the image count out of limit of image
  String _captureText() => '$count/${widget.cameraConfiguration.maxImage}';

  static const platform = const MethodChannel('flutter.camera.dataon');

  Future<File> _cropImage(File file) async {
//    final cropped = await FlutterImageCrop.cropImage(
//      file.readAsBytesSync(),
//      x: 0,
//      y: 0,
//      width: 50,
//      height: 50,
//      quality: 80,
//    );
//    file.writeAsBytes(cropped, flush: true);
    return file;
//    final RenderBox box = _camKey.currentContext.findRenderObject();
//    final size = box.size;
//    var rect = getRect(size);
//    if (rect != null) {
//      final sampledFile = await ImageCrop.sampleImage(
//        file: file,
//        preferredWidth: (size.width).round(),
//        preferredHeight: (size.height).round(),
//      );

//      final croppedFile = await ImageCrop.cropImage(
//        file: file,
//        area: rect,
//      );
//      return croppedFile;
//    }
//    return file;
  }

  getRect(Size size) {
    Rect rect;
    var cameraType = widget.cameraConfiguration.cameraType;
    switch (cameraType) {
      case CameraType.CIRCLE:
        setState(() {
          rect = Rect.fromCircle(
            center: Offset(size.width / 2, size.height / 2),
            radius: size.width * 0.40,
          );
        });
        break;
      case CameraType.SIGNATURE:
        Offset offsetPoint1 = Offset((size.width - size.width * 0.80) / 2,
            (size.height - size.width * 0.20) / 2);
        Offset offsetPoint2 = Offset((size.width + size.width * 0.80) / 2,
            (size.height + size.width * 0.20) / 2);
        setState(() {
          rect = Rect.fromPoints(offsetPoint1, offsetPoint2);
        });
        break;
      case CameraType.RECTANGLE:
        Offset offsetPoint1 = Offset((size.width - size.width * 0.80) / 2,
            (size.height - size.height * 0.80) / 2);
        Offset offsetPoint2 = Offset((size.width + size.width * 0.80) / 2,
            (size.height + size.height * 0.80) / 2);
        setState(() {
          rect = Rect.fromPoints(offsetPoint1, offsetPoint2);
        });
        break;
      case CameraType.NONE:

        /// do nothing
        break;
    }
    return rect;
  }

  /// after capturing image, add image path to list also play shutter sound
  _onTakePictureButtonPressed() {
    if (count >= widget.cameraConfiguration.maxImage) return;
    _takePicture().then((filePath) {
      if (null != filePath) {
        count++;
        _compressImage(filePath).then((myFile) {
          _cropImage(myFile).then((cropedFile) {
            try {
              if (filePath != cropedFile.path) {
                File(filePath).delete();
              }
            } catch (e) {
              print("error on deleting this file");
            }
            if (mounted) {
              setState(() {
                if (null != cropedFile) {
                  myPicDetailList.add(PicDetail(
                      cropedFile.path
                          .substring(cropedFile.path.lastIndexOf("/") + 1),
                      cropedFile.path));
                  imagePath = cropedFile.path;
                  audioCache.play('camera_shutter_click.mp3');

                  print(
                      "*************************${(cropedFile.lengthSync()) / 1024} KB");
                  print(
                      "*************************${cropedFile.lengthSync()} BYTE");
                }
              });
            }
            if (count >= widget.cameraConfiguration.maxImage)
              _navigateToPreview();
          });
        });
        /*_cropImage(filePath).then((bitmap) {
							count++;
							imagePathArray.add(bitmap);
							imagePath = bitmap;

							audioCache.play('camera_shutter_click.mp3');
						});*/
      }
    });
  }

  Future<File> _compressImage(String filePath) async {
    int quality;
    if (widget.cameraConfiguration.resolution == CameraResolution.LOW) {
      quality = 80;
    } else if (widget.cameraConfiguration.resolution ==
        CameraResolution.MEDIUM) {
      quality = 80;
    } else {
      quality = 80;
    }

    ImageProperties properties =
        await FlutterNativeImage.getImageProperties(filePath);
    int targetHeight = 800;
    int targetWidth = 600;
    if (properties != null) {
      if (properties.width > properties.height) {
        targetWidth = 800;
        targetHeight = (properties.height * 800 / properties.width).round();
      } else {
        targetHeight = 800;
        targetWidth = (properties.width * 800 / properties.height).round();
      }
    }
    File compressedFile =
        await FlutterNativeImage.compressImage(filePath, quality: quality);
    return Future.value(compressedFile);
  }

  /// Capturing image into desired path
  Future<String> _takePicture() async {
    if (!controller.value.isInitialized) {
      Util.logError("controller is not initialized");
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath =
        '${extDir.path}${widget.cameraConfiguration.baseFilePath}';
    await Directory(dirPath).create(recursive: true);
    final String filePath =
        '$dirPath/${widget.cameraConfiguration.imagePrefixName ?? ""}${Util.timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      /// A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      Util.logErrorWithErrorCode(e.code, e.description);
      return null;
    }
    return filePath;
  }

  @override
  void initState() {
    super.initState();

    myPicDetailList = widget.picDetailList ?? List<PicDetail>();
    if (myPicDetailList.length > 0) imagePath = myPicDetailList.last.path ?? "";
    count = widget.picDetailList?.length ?? 0;

    /// Permission library uses 2 different ways for checking runtime permission for Android and iOS.
    /// Android needs [List<PermissionName>] and iOS need [PermissionName] only.
    if (Platform.isAndroid) {
      MyPermission.setPermission(
              [PermissionName.Camera, PermissionName.Microphone], this)
          .requestForPermission();
    } else if (Platform.isIOS) {
      MyPermission.setPermission([PermissionName.Camera], this)
          .requestForPermission();
      //		MyPermission.forIOS(PermissionName.Microphone, this)
      //	.requestForPermission();
    }
//

    WidgetsBinding.instance.addPostFrameCallback((_) => myFun(context));
  }

  myFun(context) {
    if (count == widget.cameraConfiguration.maxImage) _navigateToPreview();
  }

  /// Callback from [permission.dart] when user allow permission
  @override
  void permissionAllowed() {
    /// checking the available cameras inside device using [getAvailableCameras]
    getAvailableCameras();
  }

  /// Callback from [permission.dart] when user deny permission
  @override
  void permissionDenied() {
    /// it get back to the previous screen
    Navigator.pop(context);
  }

  @override
  void dispose() {
    super.dispose();
    try {
      controller?.dispose();
    } catch (e) {
      print("opencamera, error on dispossing camera");
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: _onWillPopScope,
      child: SafeArea(
        top: true,
        child: Scaffold(
          body: Container(
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Flexible(
                        child: Container(
                            child: (null == controller ||
                                    !controller.value.isInitialized ||
                                    controller?.value?.aspectRatio == null)
                                ? Container(
                                    color: Colors.black,
                                  )
                                : ClipRect(
                                    child: Container(
                                    child: Transform.scale(
                                      scale: 1.1,
                                      child: Center(
                                        child: AspectRatio(
                                          aspectRatio:
                                              controller.value.aspectRatio,
                                          child: CameraPreview(controller),
                                        ),
                                      ),
                                    ),
                                  )))),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                    ),
                    Row(
                      children: <Widget>[
                        IgnorePointer(
                          ignoring: (imagePath == null),
                          child: Opacity(
                            opacity: (imagePath == null) ? 0.0 : 1.0,
                            child: Container(
                                child: IconButton(
                                  onPressed: _navigateToPreview,
                                  icon: ClipRRect(
                                    child: Image.file(
                                      File(imagePath ?? ""),
                                      height: 50.0,
                                      width: 50.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(50.0),
                                  ),
                                  padding: EdgeInsets.all(0.0),
                                ),
                                decoration: BoxDecoration(
                                    color: Colors.white70,
                                    shape: BoxShape.circle)),
                          ),
                        ),
                        Container(
                          child: IconButton(
                            icon: Icon(
                              Icons.brightness_1,
                              color: Colors.black54,
                              size: 70.0,
                            ),
                            padding: EdgeInsets.all(0),
                            alignment: Alignment.center,
                            onPressed: null != controller &&
                                    controller.value.isInitialized
                                ? _onTakePictureButtonPressed
                                : null,
                          ),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white),
                          width: 70.0,
                          height: 70.0,
                        ),
                        Container(
                            child: IconButton(
                              onPressed: () {
                                if (myCamDes.lensDirection ==
                                    CameraLensDirection.back) {
                                  myCamDes = camMap[CameraLensDirection.front];
                                } else if (myCamDes.lensDirection ==
                                    CameraLensDirection.front) {
                                  myCamDes = camMap[CameraLensDirection.back];
                                }
                                onNewCameraSelect(myCamDes);
                              },
                              icon: Icon(
                                null != camerasList
                                    ? getCameraLensIcon(myCamDes.lensDirection)
                                    : Icons.clear,
                                color: Colors.black,
                              ),
                            ),
                            decoration: BoxDecoration(
                                color: Colors.white70, shape: BoxShape.circle)),
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        _captureText(),
                        style: TextStyle(color: Colors.white, fontSize: 17.0),
                      ),
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.end,
                ),
                Align(
                  child: GestureDetector(
                    onTap: _onWillPopScope,
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
              alignment: Alignment.topCenter,
            ),
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
