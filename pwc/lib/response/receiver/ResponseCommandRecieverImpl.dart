import 'dart:convert';

import 'package:pwc/internal/CallServerInit.dart';
import 'package:pwc/internal/PWCUtils.dart';
import 'package:pwc/listeners/PWCCallback.dart';
import 'package:pwc/model/PlatwarePropertyModel.dart';
import 'package:pwc/request/Request.dart';
import 'package:pwc/request/service/ServiceRequest.dart';
import 'package:pwc/response/NetResponse.dart';
import 'package:pwc/response/Response.dart';
import 'package:pwc/response/ServiceResponseImpl.dart';
import 'package:pwc/response/receiver/ResponseCommandReciever.dart';
import 'package:pwc/utility/Constants.dart';

class ResponseCommandReceiverImpl extends ResponseCommandReciever {
  PWCUtils utils = new PWCUtils();
  NetResponse netResponse;
  ServiceRequest serviceRequest;

  ResponseCommandReceiverImpl(this.netResponse, this.serviceRequest);

  @override
  void authenticateUser() {
    clearUserLoginData();
    //PWCUtils.getInstance(mContext).moveToLoginActivity()
  }

  clearUserLoginData() async {
    utils.decryptedToken = null;
    utils.loginId = null;
    PlatwareProperties platProperty =
        await utils.mFilePersistor.getPlatwarePropertiesFromFile();
    platProperty?.isSessionExpired = true;
    platProperty?.token = null;
    platProperty?.loginId = null;
    utils.mFilePersistor.writeFile(Constants.PLATWARE_PROPERTIES_JSON_FILENAME,
        jsonEncode(platProperty?.toJson()));
  }

  @override
  Future<List<Response>> handleResponse() async {
    var serviceResponse = new ServiceResponseImpl(serviceRequest, netResponse);
    var resList = await serviceResponse.getResponseList();
    await serviceResponse.saveResponseInDB(resList);
    return resList;
  }

  @override
  Request killMultipleSession(Request request) {
    return null;
  }

  @override
  void logoutUser() {
    clearUserLoginData();
  }

  void clearAuthenticationData() async {
    utils.registrationId = null;
    utils.decryptedToken = null;
    utils.loginId = null;
    PlatwareProperties platProperty =
        await utils.mFilePersistor.getPlatwarePropertiesFromFile();
    platProperty?.registrationId = null;
    platProperty?.token = null;
    platProperty?.modulus = null;
    platProperty?.exponent = null;
    platProperty?.loginId = null;
    platProperty?.isSessionExpired = true;
    utils.mFilePersistor.writeFile(Constants.PLATWARE_PROPERTIES_JSON_FILENAME,
        jsonEncode(platProperty.toJson()));
  }

  @override
  void registerUser(
      Function callback, PWCCallback<List<Response>> mCallback) async {
    clearAuthenticationData();
    if (utils.mPlatwareProperties?.initParams != null) {
      var calServerInit = new CallServerInit(
          utils.mPlatwareProperties.initParams,
          new _InternalCallback(callback, mCallback));
      await calServerInit.init();
      calServerInit.callServer(calServerInit.getRegisterRequest());
    }
  }
}

class _InternalCallback extends PWCCallback<List<Response>> {
  Function callback;
  PWCCallback<List<Response>> mCallback;

  _InternalCallback(this.callback, this.mCallback);

  @override
  onFailure(String ex, {String code}) {
    mCallback.onFailure(ex, code: "402");
    return null;
  }

  @override
  onResponse(List<Response> t) {
    callback();
  }
}
