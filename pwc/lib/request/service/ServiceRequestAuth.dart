import 'dart:convert';

import 'package:pwc/internal/PWCUtils.dart';
import 'package:pwc/request/Request.dart';
import 'package:pwc/request/RequestHashImp.dart';
import 'package:pwc/request/service/ServiceRequestImpl.dart';
import 'package:pwc/security/CryptoUtil.dart';
import 'package:pwc/utility/Constants.dart';
import 'package:pwc/utility/Utility.dart';

class ServiceRequestAuth extends ServiceRequestImpl {
  var _nounce;

  List<Request> reqList;
  PWCUtils pwcUtils;

  ServiceRequestAuth(this.reqList, this.pwcUtils) : super(reqList, pwcUtils) {
    _nounce = new DateTime.now().millisecondsSinceEpoch;
  }

  @override
  String getURL() {
    String url = reqList[0].url;
    if (Utility.isEmpty(url) &&
        mPlatwareProperties?.initParams?.platwareUrl != null) {
      url = mPlatwareProperties?.initParams?.platwareUrl + "/register";
    }
    if (url == null) {
      throw new Exception("Invalid Url Exception");
    }
    return url;
  }

  @override
  Future<Map<String, String>> getHeaderParameter() async {
    var Map = await super.getHeaderParameter();
    var req = reqList[0] as RequestHashImp;
    var hashRequest = req.body[0];
    mPlatwareProperties?.loginId = hashRequest[Constants.KEY_LOGIN_ID];
    await pwcUtils.mFilePersistor.writeFile(
        Constants.PLATWARE_PROPERTIES_JSON_FILENAME,
        jsonEncode(mPlatwareProperties.toJson()));
    String auth = await getAuthorizationBasic(mPlatwareProperties.loginId);
    Map[Constants.KEY_AUTHORIZATION] = "Basic $auth";
    Map[Constants.KEY_NOUNCE] =
        CryptoUtil.convertIntArrayToHexString(_nounce.toString().codeUnits);
    Map[Constants.KEY_REQUESTID] = await getRequestId();

    if (mPWCUtil
            ?.getProperty(Constants.PROPERTY_IS_FORCE_LOGIN)
            ?.toUpperCase() ==
        "Y") {
      Map[Constants.KEY_IS_FORCE_LOGIN] = "Y";
    }
    Map.addAll(reqList[0].hashHeaderParam);
    return Map;
  }

  Future<String> getUsername(String loginId) async {
    var initParams = mPlatwareProperties.initParams;
    var builder = StringBuffer();
    builder.write(initParams.orgId);
    builder.write(SEPERETOR);
    builder.write(initParams.appId);
    builder.write(SEPERETOR);
    builder.write(loginId);
    builder.write(SEPERETOR);
    builder.write(mPWCUtil.deviceDetails.imeiNumber);
    return builder.toString();
  }

  Future<String> getAuthorizationBasic(String loginID) async {
    var authorizationCode = StringBuffer();
    var userName = await getUsername(loginID);
    authorizationCode.write(userName);
    authorizationCode.write(COLON_SEPRETOR);
    authorizationCode.write("user");
    authorizationCode.write(COLON_SEPRETOR);
    authorizationCode.write("$_nounce");

    String encryptionKey = await getEncryptionKey();
    String encryptHeader = await mPWCUtil.encryptionUtil
        .encrypt(encryptionKey, authorizationCode.toString());
    return encryptHeader;
  }

  Future<String> getEncryptionKey() async {
    String decryptedSecret = await mPWCUtil.getDecryptedSecret();

    if (decryptedSecret.length > 0 && decryptedSecret.length >= 32) {
      return "$_nounce$decryptedSecret".substring(0, 32);
    } else {
      throw Exception("Client secret is not valid.");
    }
  }
}
