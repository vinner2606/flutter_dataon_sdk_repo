import 'dart:convert';
import 'dart:math';
import 'dart:io' show Platform;
import 'package:geolocator/geolocator.dart';
import 'package:pwc/internal/PWCUtils.dart';
import 'package:pwc/model/FilePersistor.dart';
import 'package:pwc/model/PlatwarePropertyModel.dart';
import 'package:pwc/model/enums.dart';
import 'package:pwc/request/Request.dart';
import 'package:pwc/request/service/ServiceRequest.dart';
import 'package:pwc/security/EncryptionFactory.dart';
import 'package:pwc/security/RSAEncryption.dart';
import 'package:pwc/utility/Constants.dart';
import 'package:pwc/utility/Utility.dart';

class ServiceRequestImpl extends ServiceRequest {
  PlatwareProperties mPlatwareProperties;
  String mTxnKey;
  CallingType mCallingType;

  PriorityServerCall mPriority;
  Map<String, String> responseHeader;
  String _tagName;
  String resCode;
  int requestTimeout = 60000;
  RequestProcessor requestProcessor;

  List<Request> reqList;
  PWCUtils mPWCUtil;
  String _requestId;
  String SEPERETOR = "~";
  String COLON_SEPRETOR = ":";
  FilePersistor mFilePersistor = FilePersistor();

  ServiceRequestImpl(this.reqList, this.mPWCUtil) {
    try {
      mTxnKey = PWCUtils.pwSessionID();
      Request request = reqList[0];
      this.mPlatwareProperties = mPWCUtil.mPlatwareProperties;
      this.mCallingType = request.callingType;
      this.mPriority = request.priority;
      this.requestProcessor = request.requestProcessor;
      this.requestTimeout = request.requestTimeout;
      setRequestId();
    } catch (ex, stacktrace) {
      print(stacktrace);
    }
  }
  setRequestId() async {
    this._requestId = await getRequestId();
  }

  @override
  addHeaderParameter(String key, String value, Map<String, String> map) {
    map[key] = value;
  }

  @override
  CallingType getCallingType() => mCallingType;

  String getClientName() {
    StringBuffer clientName = new StringBuffer();
    clientName.write(mPlatwareProperties?.initParams?.orgId);
    clientName.write(SEPERETOR);
    clientName.write(mPlatwareProperties?.initParams?.appId);
    return clientName.toString();
  }

  @override
  PWCUtils getPWCUtils() => mPWCUtil;

  @override
  PriorityServerCall getPriority() => mPriority;

  @override
  Future<String> getRequestId() async {
    if (null == _requestId) {
      var reqID = StringBuffer();
      var imeiNumber = mPlatwareProperties?.deviceDetails?.imeiNumber ?? "";
      if (imeiNumber.length > 10) {
        imeiNumber = imeiNumber
            .substring(imeiNumber.length - 10, imeiNumber.length)
            .replaceAll("-", "");
      }
      reqID.write(mPlatwareProperties?.initParams?.orgId);
      reqID.write(mPlatwareProperties?.initParams?.appId);
      reqID.write(imeiNumber);
      var loginId = await mPWCUtil.getLoginId();

      reqID.write(loginId ?? "--");
      reqID.write((Random().nextDouble() * 1000).toInt());
      reqID.write(Utility.currentFormattedTimestamp(
          dateFormat: DateTimeFormat.DD_MM_YYYY_HH_MM_SS_SSS));
      _requestId = reqID.toString();
    }
    return _requestId;
  }

  @override
  List<Request> getRequestList() => reqList;

  @override
  int getRequestTimeout() => requestTimeout;

  @override
  String getResponseCode() => resCode;

  @override
  Future<Map<String, String>> getResponseHeaders() {
    return Future.value(responseHeader);
  }

  @override
  Future<Object> getServiceRequestBody() async {
    Map<String, Object> interfaces = new Map();
    interfaces[Constants.KEY_INTERFACE] = await getInterface();

    Map<String, Object> jsonServices = Map();

    reqList.forEach((request) {
      jsonServices[request.serviceName] = request.getRequest();
    });

    interfaces[Constants.KEY_SERVICES] = jsonServices;
    print("RequestData $_tagName" + interfaces.toString());
    return await checkForEncryption(interfaces);
  }

  Object checkForEncryption(Object reqBody) async {
    if (CallingType.ER_ER == mCallingType ||
        CallingType.ER_PR == mCallingType) {
      var stopWatch = Stopwatch()..start();
      Map reqBodyUp = Utility.toMap(reqBody);
      var encryptRequest = await mPWCUtil.encryptionUtil
          .encrypt(mTxnKey, json.encode(reqBodyUp));
      var requestData = Map<String, Object>();
      requestData[Constants.KEY_REQUEST] = encryptRequest;
      print(
          "time in encryption ${tagName()} is ${stopWatch.elapsed.inMilliseconds}");
      return requestData;
    } else {
      return reqBody;
    }
  }

  @override
  Future<Map<String, String>> getHeaderParameter() async {
    var requestId = await getRequestId();
    String encryptTxnKey = await encryptRSA(mTxnKey);

    var securityVersion;
    var platform;

    if (Platform.isAndroid) {
      securityVersion = "0";
      platform = "F_Android";
    } else if (Platform.isIOS) {
      securityVersion = "1";
      platform = "F_iOS";
    }

    var headerParams = <String, String>{
      Constants.KEY_SECUIRITY_VERSION: securityVersion,
      Constants.KEY_PLATFORM: platform,
      Constants.KEY_OUT_PROCESS_ID: tagName(),
      Constants.KEY_REQUESTID: requestId,
      Constants.KEY_TXN_KEY: encryptTxnKey,
      Constants.KEY_CLIENT_ID: getClientName(),
      Constants.KEY_REQUESTTYPE: mCallingType.value
    };
    return headerParams;
  }

  Future<String> encryptRSA(String plainText) async {
    try {
      RSAEncryption rsaEncryption = RSAEncryption.instance;
      var modulus = mPlatwareProperties.modulus ?? "";
      var exponent = mPlatwareProperties.exponent ?? "";
      if (modulus.isEmpty || exponent.isEmpty) return plainText;
      String encrypting = await rsaEncryption.encrypt(
          '$modulus${EncryptionFactory.RSA_SEPARATOR}$exponent', plainText);
      return encrypting;
    } catch (e) {
      print(e);
    }
    return plainText;
  }

  Future<Map<String, Object>> getInterface() async {
    Map<String, Object> interface = new Map();

    interface = {
      Constants.KEY_APP_VERSION: mPWCUtil.applicationVersion,
      Constants.KEY_DEVICE_TIMESTAMP: Utility.currentFormattedTimestamp(),
      Constants.KEY_PW_CLIENT_VERSION: mPlatwareProperties?.pwClientVersion,
      Constants.KEY_SIM_ID: mPlatwareProperties?.deviceDetails?.simId,
      Constants.KEY_OS_VERSION:
          mPlatwareProperties?.deviceDetails?.androidVersion,
      Constants.KEY_IMEI_NO: mPlatwareProperties?.deviceDetails?.imeiNumber,
      Constants.KEY_DEVICE_MAKE: mPlatwareProperties?.deviceDetails?.deviceMake,
      Constants.KEY_DEVICE_MODEL:
          mPlatwareProperties?.deviceDetails?.deviceModel,
      Constants.KEY_PW_VERSION: mPlatwareProperties?.platwareVersion,
      Constants.KEY_IMEI_NO: mPlatwareProperties?.deviceDetails?.imeiNumber,
    };
    interface["PW_CLIENT_VERSION"] = "2.0";
    Position position = await mPWCUtil.locationManager.getCurrentLocation();
    if (position != null) {
      interface[Constants.KEY_DEVICE_LATITUDE] = position.latitude;
      interface[Constants.KEY_DEVICE_LONGITUDE] = position.longitude;
    }
    if (reqList[0].interfaceParam != null) {
      reqList[0].interfaceParam.forEach((key, value) {
        interface[key] = value;
      });
    }
    return Future.value(interface);
  }

  @override
  String getTxtKey() {
    return mTxnKey;
  }

  @override
  RequestProcessor getRequestProcessor() {
    return requestProcessor;
  }

  @override
  String tagName() {
    if (_tagName == null) {
      var tagName = StringBuffer();
      for (var i = 0; i < reqList.length; i++) {
        tagName.write(reqList[i].serviceName);
        if (i != reqList.length - 1) tagName.write(SEPERETOR);
      }
      _tagName = tagName.toString();
    }
    return _tagName;
  }

  @override
  String getURL() {
    return null;
  }
}
