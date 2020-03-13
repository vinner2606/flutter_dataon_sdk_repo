import 'package:camera_module/util/enumeration.dart';

class PicDetail {

	String picName;

	String path;

	PicDetail(this.picName, this.path, {this.isDeleted = false, this.isCapturedInCurrentSession = false});

	/**
	 * define status of deleted file. if file is deleted by gallery module it will be true.
	 */
	bool isDeleted;

	/**
	 * define capture time of clicked image
	 */
	DateTime picCapturedTime;

	/**
	 * define that captured image is clicked in current session or not.
	 */
	bool isCapturedInCurrentSession;

	/**
	 * define type of pic is it file or url
	 */
	String picType = PicType.FILE.toString();

	/**
	 * tag of pic clicked for what.
	 */
	String picTag;
}