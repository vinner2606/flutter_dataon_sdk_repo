import 'dart:io';

import 'dart:convert';

import 'package:pwc/internal/PWCUtils.dart';
import 'package:pwc/internal/callserver/CallServerImpl.dart';
import 'package:pwc/listeners/PWCCallback.dart';
import 'package:pwc/model/PlatwarePropertyModel.dart';
import 'package:pwc/model/enums.dart';
import 'package:pwc/request/Request.dart';
import 'package:pwc/request/RequestHashImp.dart';
import 'package:pwc/response/Response.dart';
import 'package:pwc/utility/Constants.dart';
import 'package:pwc/utility/Utility.dart';

class CallServerInit extends CallServerImpl {
  InitParams initParams;
  PWCCallback<List<Response>> mCallback;
  PWCUtils mPWCUtil = PWCUtils();

  CallServerInit(this.initParams, this.mCallback) : super(mCallback) {}
  void init() async {
    platwareProperties = await initialzePlatwareProperties(initParams);
  }

  PlatwareProperties platwareProperties;

  Future<PlatwareProperties> initialzePlatwareProperties(
      InitParams initParams) async {
    try {
      platwareProperties =
          await mPWCUtil.mFilePersistor.getPlatwarePropertiesFromFile();
      if ((platwareProperties == null) &
          (platwareProperties?.deviceDetails == null)) {
        platwareProperties = PlatwareProperties();
        platwareProperties.platwareConfigVersion = "1.0";
        platwareProperties.installationTimeStamp =
            Utility.currentFormattedTimestamp();
        platwareProperties.pwClientVersion = Constants.PLATWARE_CLIENT_VERSION;
        platwareProperties.initParams = initParams;
        platwareProperties.deviceDetails = mPWCUtil.deviceDetails;
        mPWCUtil.mPlatwareProperties = platwareProperties;
      }

      try {
        var pwdata = await mPWCUtil?.mFilePersistor?.getPwcDataFromFile();
        if (pwdata == null && (initParams.appSecret != null)) {
          await mPWCUtil.mFilePersistor.writeFile(
              Constants.PLATWARE_DATA_FILENAME, initParams.appSecret);
        }
      } catch (e, stacktrace) {
        print(stacktrace);
      }

      //making this item empty and saving it at another place
      platwareProperties.initParams = initParams;
      platwareProperties.deviceDetails = mPWCUtil.deviceDetails;
      await mPWCUtil.mFilePersistor.writeFile(
          Constants.PLATWARE_PROPERTIES_JSON_FILENAME,
          json.encode(platwareProperties.toJson()));
      mPWCUtil.mPlatwareProperties = platwareProperties;
      return platwareProperties;
    } catch (e, stacktrace) {
      print(stacktrace);
      mCallback?.onFailure("Something went wrong on initialization");
      mCallback = null;
    }
    return platwareProperties;
  }

  List<Request> getInitRequestObject() {
    if (platwareProperties == null) {
      return List();
    }
    var request = List<Request>();
    var jsonData = <String, String>{
      "org_id": platwareProperties.initParams?.orgId,
      "app_id": platwareProperties.initParams?.appId,
      "platform": Platform.isAndroid ? "Android" : "Ios",
    };

    var dataArray = [jsonData];
    if (platwareProperties.initParams.isBackgroundSyncEnabled) {
      request.add(RequestHashImp(Constants.SERVICE_SYNC_CONFIG, body: dataArray)
        ..isSpecialProcess = true);
    }

    return request;
  }

  List<Request> getRegisterRequest() {
    var reqList = List<Request>();
    if (platwareProperties == null) {
      return reqList;
    }
    var jsonData = <String, String>{};
    var dataArray = [jsonData];

    var object =
        RequestHashImp(Constants.SERVICE_REGISTER_APP, body: dataArray);
    object.isSpecialProcess = true;
    object.callingType = CallingType.PR_PR;

    reqList.add(object);
    return reqList;
  }
}
