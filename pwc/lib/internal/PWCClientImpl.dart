import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:pwc/RequestFactory.dart';
import 'package:pwc/datastore/DAO.dart';
import 'package:pwc/internal/CallServerInit.dart';
import 'package:pwc/internal/PWCClient.dart';
import 'package:pwc/internal/PWCUtils.dart';
import 'package:pwc/internal/callserver/CallServer.dart';
import 'package:pwc/internal/callserver/CallServerImpl.dart';
import 'package:pwc/listeners/PWCCallback.dart';
import 'package:pwc/model/PlatwarePropertyModel.dart';
import 'package:pwc/model/enums.dart';
import 'package:pwc/request/Request.dart';
import 'package:pwc/request/RequestInitImpl.dart';
import 'package:pwc/request_validator/validator.dart';
import 'package:pwc/response/Response.dart';
import 'package:pwc/utility/AppSharedPreference.dart';
import 'package:pwc/utility/Constants.dart';
import 'package:pwc/utility/Utility.dart';

class PWCClientImpl extends PWCClient {
  PWCUtils mPWCUtils;

  PWCClientImpl() {
    mPWCUtils = PWCUtils();
  }

  @override
  executeRequest(PWCCallback<List<Response>> callback, var requestList) {
    if (requestList == null || requestList.isEmpty) {
      callback.onFailure("Please pass request object");
    } else {
      List<Request> list = requestList;
      callAPI(list, callback);
    }
  }

  callAPI(List<Request> requestList, PWCCallback<List<Response>> callback) {
    Map<Task, List<Request>> groupByTaskType = groupBy(requestList, (obj) {
      return obj.task;
    });

    groupByTaskType.forEach((task, request) {
      var requestList = request;

      switch (task) {
        case Task.SERVICE:
          {
            processService(requestList, callback);
            break;
          }
        case Task.INIT:
          {
            initializePlatware(requestList[0], callback);
            break;
          }
        case Task.AUTHENTICATE:
          {
            processService(requestList, callback);

            break;
          }

        case Task.KILL_ALL_SESSION:
          {
            break;
          }
        case Task.LOGOUT:
          {
            break;
          }
        default:
          {
            break;
          }
      }
    });
  }

  initializePlatware(
      Request request, PWCCallback<List<Response>> callback) async {
    if (request is RequestInitImpl) {
      var calServerInit = CallServerInit(request.initParams, callback);
      await calServerInit.init();
      var platProperties = calServerInit.platwareProperties;
      var requestListInit = calServerInit.getInitRequestObject();

      if (platProperties == null) {
        callback
            .onFailure("Some error occured, could not initialized platware.");
        return;
      }

      var regID = platProperties.registrationId;
      if (null == regID || regID.isEmpty) {
        var callServer =
            CallServerImpl(new RegisterCallback(callback, mPWCUtils));
        var registerRequestList = calServerInit.getRegisterRequest();
        callServer.callServer(registerRequestList);
      } else {
        loadConfiguration(requestListInit, platProperties, callback);
      }
    } else {
      throw Exception("Invalid request object type. It is not instance" +
          "of RequestInitImpl");
    }
  }

  loadConfiguration(List<Request> requestList,
      PlatwareProperties platProperties, PWCCallback<List<Response>> callback) {
    if (!mPWCUtils
        .isAllConfigurationFileAvailable(platProperties?.initParams)) {
      CallServer callServer = CallServerImpl(callback);
      callServer.callServer(requestList);
    } else {
      callback.onResponse(List());
    }
  }

  processService(
      List<Request> requestList, PWCCallback<List<Response>> callback) {
    if (RegistrationValidator().validate(requestList, mPWCUtils)) {
      sendRequest(requestList, callback);
    } else {
      if (mPWCUtils.mPlatwareProperties?.initParams != null) {
        functionCallback() {
          sendRequest(requestList, callback);
        }

        initializePlatware(
            RequestFactory.getInitializationRequest(
                mPWCUtils.mPlatwareProperties?.initParams, null),
            new PlatwareReInit(functionCallback(), callback));
      } else {
        callback.onFailure("App is not registered");
      }
    }
  }

  @override
  Future<bool> isSessionExpired() async {
    PlatwareProperties status =
        await mPWCUtils?.mFilePersistor?.getPlatwarePropertiesFromFile();
    return status?.isSessionExpired ?? false;
  }

  @override
  openSyncScreen() {
    return null;
  }

  void sendRequest(
      List<Request> requestList, PWCCallback<List<Response>> callback) async {
    taskCallback() {
      CallServer callServer = CallServerImpl(callback);
      callServer.callServer(requestList);
    }

    taskFailure() {
      callback.onFailure("Newer version available.");
    }

    AppSharedPreference appSharedPreference =
        await AppSharedPreference.getInstance();
    int lastPropertySyncTime = appSharedPreference
        .getValue(AppSharedPreference.LAST_PROPERTY_SYNC_TIME, defaultValue: 0);

    if (!Utility.isAppIsInBackground() &&
        Utility.checkDateChange(lastPropertySyncTime)) {
      functionCallback() {
        postValidationOnPropertyMaster(taskCallback, taskFailure);
      }

      CallServer callServer = new CallServerImpl(
          new PostValidationStartTask(functionCallback, callback));

      callServer.callServer([
        RequestFactory.getServiceRequest(Constants.SERVICE_PROPERTY_MASTER)
      ]);
    } else {
      if ("Y" ==
          mPWCUtils
              .getProperty(Constants.KEY_VERSION_UPDATE_MANDATORY)
              .toUpperCase()) {
        postValidationOnPropertyMaster(taskCallback(), taskFailure());
      } else {
        taskCallback();
      }
    }
  }

  void postValidationOnPropertyMaster(Function task, Function onUpdate) async {
    var serverAppVersion = mPWCUtils.getProperty(Constants.KEY_VERSION_NUMBER);
    if ((serverAppVersion != null &&
        isGreaterThan(serverAppVersion, mPWCUtils.applicationVersion))) {
      if (!Utility.isAppIsInBackground()) {
        onUpdate();
      } else {
        task();
      }
    } else {
      task();
    }
    var pwcConfigVersion =
        mPWCUtils.getProperty(Constants.KEY_PWC_CONFIG_VERSION);
    var platwareProperties =
        await mPWCUtils.mFilePersistor.getPlatwarePropertiesFromFile();
    if (!Utility.isEmpty(pwcConfigVersion) &&
        pwcConfigVersion != platwareProperties?.pwClientVersion) {
      var callServerInit = new CallServerInit(platwareProperties?.initParams,
          new PlatwareSyncConfigTask(mPWCUtils, pwcConfigVersion));
      await callServerInit.init();

      callServerInit.callServer(callServerInit.getInitRequestObject());
    }
  }

  bool isGreaterThan(String from, String to) {
    try {
      var delimiter = ".";
      var tokenizeString = from.split(delimiter);
      var appTokenString = to.split(delimiter);
      var tokenSize = min(tokenizeString.length, appTokenString.length);
      for (var i = 0; i < tokenSize; i++) {
        if (int.parse(tokenizeString[i]) == int.parse(appTokenString[i])) {
          continue;
        } else {
          return int.parse(tokenizeString[i]) > int.parse(appTokenString[i]);
        }
      }
    } catch (e) {}
    return false;
  }

  @override
  DAO getDAO() {
    return mPWCUtils.getDao();
  }

  @override
  Future<String> getLastSyncCount() async {
    var pref = await AppSharedPreference.getInstance();
    return (pref.getValue(AppSharedPreference.KEY_LAST_DATA_SYNC_COUNT) ?? 0)
        .toString();
  }

  @override
  Future<String> getLastSyncTime() async {
    var pref = await AppSharedPreference.getInstance();
    int time = pref.getValue(AppSharedPreference.KEY_LAST_DATA_SYNC_TIME,
        defaultValue: 0);
    if (time != 0) {
      var currentTime = DateFormat("HH:mm:ss")
          .format(DateTime.fromMillisecondsSinceEpoch(time, isUtc: false));
      return currentTime;
    }
  }
}

class RegisterCallback extends PWCCallback<List<Response>> {
  PWCCallback<List<Response>> callback;
  PWCUtils mPWCUtils;

  RegisterCallback(this.callback, this.mPWCUtils);

  @override
  onFailure(String ex, {String code}) {
    callback.onFailure(ex, code: code);
    return null;
  }

  @override
  onResponse(List<Response> t) async {
    var platwareProperty = await mPWCUtils.getUpdatedPlatwareProperty();
    if (platwareProperty?.initParams != null) {
      var callServerInit =
          CallServerInit(platwareProperty.initParams, callback);
      await callServerInit.init();
      callServerInit.callServer(callServerInit.getInitRequestObject());
    } else {
      callback.onFailure(Constants.ERROR);
    }
  }
}

class PlatwareReInit extends PWCCallback<List<Response>> {
  Function functionCallback;
  PWCCallback<List<Response>> callback;

  PlatwareReInit(this.functionCallback, this.callback);

  @override
  onFailure(String ex, {String code}) {
    callback.onFailure(ex, code: code);
  }

  @override
  onResponse(List<Response> t) {
    functionCallback();
  }
}

class PostValidationStartTask extends PWCCallback<List<Response>> {
  Function functionCallback;
  PWCCallback<List<Response>> callback;

  PostValidationStartTask(this.functionCallback, this.callback);

  @override
  onFailure(String ex, {String code}) {
    return callback.onFailure(ex, code: code);
  }

  @override
  onResponse(List<Response> t) {
    functionCallback();
  }
}

class PlatwareSyncConfigTask extends PWCCallback<List<Response>> {
  PWCUtils mPWCUtils;
  var pwcConfigVersion;

  PlatwareSyncConfigTask(this.mPWCUtils, this.pwcConfigVersion);

  @override
  onFailure(String ex, {String code}) {}

  @override
  onResponse(List<Response> t) async {
    PlatwareProperties platwareProperties =
        await mPWCUtils.mFilePersistor.getPlatwarePropertiesFromFile();
    platwareProperties?.pwClientVersion = pwcConfigVersion;
    mPWCUtils.mFilePersistor.writeFile(
        Constants.PLATWARE_PROPERTIES_JSON_FILENAME,
        jsonEncode(platwareProperties.toJson()));
  }
}
