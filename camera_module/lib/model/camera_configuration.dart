import 'package:camera_module/util/enumeration.dart';
import 'package:flutter/material.dart';

class CameraConfiguration {

	/**
	 * [cameraType] is just for creating template over camera to click picture and then
	 * to crop it as well.
	 */
	CameraType cameraType = CameraType.NONE;

	/**
	 * [maxImage] allowed in one session.
	 */
	int maxImage = 1;

	/**
	 * [direction] specify which camera need to be open in starting.
	 * value should be in front or back.
	 */
	CameraDirection direction = CameraDirection.BACK;

	/**
	 * specify the resolution of image capture
	 */
	CameraResolution resolution = CameraResolution.LOW;

	/**
	 * prefix of image name when saved in file
	 */
	String imagePrefixName = "";

	/**
	 * this variable is for defining brightness on low quality image.
	 */
	bool contrastBrightnessRequired = true;

	/**
	 * define base path in external storage to save picture
	 * for ex- if "/temp" then all pic will be saved in
	 * /storage/emulated/0/Android/data/packageName/temp
	 */
	String baseFilePath;

	/**
	 * define list of tag for picture. user will select one from them and will apply it in
	 * picture.
	 */
	List<String> listTag;

	CameraConfiguration({@required this.cameraType, @required this.maxImage,
		@required this.direction, @required this.resolution,
		@required this.imagePrefixName, @required this.contrastBrightnessRequired,
		@required this.baseFilePath, this.listTag});
}