import 'dart:io';

import 'package:pwc/internal/PWCUtils.dart';
import 'package:pwc/listeners/PWCCallback.dart';
import 'package:pwc/request/Request.dart';
import 'package:pwc/response/Response.dart';
import 'package:pwc/utility/Constants.dart';
import 'package:pwc/utility/Utility.dart';
import 'package:root_access/root_access.dart';

abstract class ReqValidator {
  ReqValidator reqValidator;

  setNextValidator(ReqValidator reqValidator) {
    this.reqValidator = reqValidator;
  }

  bool validate(List<Request> requestList, PWCCallback<List<Response>> callback,
      PWCUtils mPWCUtils);
}

class ConfigurationValidator extends ReqValidator {
  @override
  bool validate(List<Request> requestList, PWCCallback<List<Response>> callback,
      PWCUtils mPWCUtils) {
    var initParam = mPWCUtils.mPlatwareProperties.initParams;
    var isSpecialProcesses =
        requestList.indexWhere((request) => request.isSpecialProcess == true) !=
            -1;
    if (!mPWCUtils.isAllConfigurationFileAvailable(initParam) &&
        !isSpecialProcesses) {
      mPWCUtils.loadAllConfigurations();
      if (!mPWCUtils.isAllConfigurationFileAvailable(initParam)) {
        return reqValidator?.validate(requestList, callback, mPWCUtils) ?? true;
      } else {
        return reqValidator?.validate(requestList, callback, mPWCUtils) ?? true;
      }
    } else {
      return reqValidator?.validate(requestList, callback, mPWCUtils) ?? true;
    }
  }
}

class InitializationValidator extends ReqValidator {
  @override
  bool validate(List<Request> requestList, PWCCallback<List<Response>> callback,
      PWCUtils mPWCUtils) {
    var initParam = mPWCUtils.mPlatwareProperties.initParams;
    if (initParam == null) {
      callback.onFailure("Initialization is not done yet.");
      return false;
    } else {
      return reqValidator?.validate(requestList, callback, mPWCUtils) ?? true;
    }
  }
}

class NetworkValidator extends ReqValidator {
  @override
  bool validate(List<Request> requestList, PWCCallback<List<Response>> callback,
      PWCUtils mPWCUtils) {
    if (!mPWCUtils.isInternetConnected) {
      callback.onFailure("Internet connectivity is unavailable");
      return false;
    } else {
      return reqValidator?.validate(requestList, callback, mPWCUtils) ?? true;
    }
  }
}

class RegistrationValidator {
  bool validate(List<Request> requestList, PWCUtils mPWCUtils) {
    var platwareProperties = mPWCUtils.mPlatwareProperties;

    if (requestList[0].serviceName != Constants.SERVICE_REGISTER_APP &&
        (Utility.isEmpty(platwareProperties?.registrationId))) {
      return false;
    }
    return true;
  }
}

class RequestCountValidation extends ReqValidator {
  @override
  bool validate(List<Request> requestList, PWCCallback<List<Response>> callback,
      PWCUtils mPWCUtils) {
    if (requestList.isEmpty) {
      callback
          .onFailure("Request List is empty, Please provide request object");
      return false;
    } else {
      return reqValidator?.validate(requestList, callback, mPWCUtils) ?? true;
    }
  }
}

class RootedDeviceValidator extends ReqValidator {
  PWCUtils mPWCUtils;
  var ERROR_MSG = "Rooted device is not allowed.";

  Future<bool> get isDeviceRooted async {
    var check1 = await checkRootMethod1();
    var check2 = checkRootMethod2();
    var check3 = await checkRootMethod3();
    return check1 || check2 || check3;
  }

  @override
  bool validate(List<Request> requestList, PWCCallback<List<Response>> callback,
      PWCUtils mPWCUtils) {
    this.mPWCUtils = mPWCUtils;
    isDeviceRooted.then((flag) {
      if (flag &&
          mPWCUtils.mPlatwareProperties?.initParams?.isRootedDeviceAllowed !=
              true) {
        callback.onFailure(ERROR_MSG);
        return false;
      } else {
        return reqValidator?.validate(requestList, callback, mPWCUtils) ?? true;
      }
    });
  }

  Future<bool> checkRootMethod1() async {
    var deviceDetail = await mPWCUtils.deviceDetails;
    //return deviceDetail.tags.contains("test-keys");
    return false;
  }

  bool checkRootMethod2() {
    var paths = [
      "/system/app/Superuser.apk",
      "/sbin/su",
      "/system/bin/su",
      "/system/xbin/su",
      "/data/local/xbin/su",
      "/data/local/bin/su",
      "/system/sd/xbin/su",
      "/system/bin/failsafe/su",
      "/data/local/su"
    ].toList();
    paths.forEach((file) {
      try {
        if (File(file).existsSync()) return true;
      } on Exception {
        return false;
      }
    });
    return false;
  }

  Future<bool> checkRootMethod3() async => await RootAccess.rootAccess;
}
