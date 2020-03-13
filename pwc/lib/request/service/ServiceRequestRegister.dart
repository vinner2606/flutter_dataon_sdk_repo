import 'package:geolocator/geolocator.dart';
import 'package:pwc/internal/PWCUtils.dart';
import 'package:pwc/request/Request.dart';
import 'package:pwc/request/service/ServiceRequestImpl.dart';
import 'package:pwc/security/CryptoUtil.dart';
import 'package:pwc/utility/Constants.dart';

class ServiceRequestRegister extends ServiceRequestImpl {
  List<Request> reqList;
  PWCUtils pwcUtils;

  var SEPERETOR = "~";
  var COLON_SEPRETOR = ":";
  var _nounce;

  ServiceRequestRegister(this.reqList, this.pwcUtils)
      : super(reqList, pwcUtils) {
    _nounce = new DateTime.now().millisecondsSinceEpoch;
  }

  @override
  Future<Map<String, String>> getHeaderParameter() async {
    var headerParams = await super.getHeaderParameter();
    var authorization = await getAuthorizationBasic();
    headerParams[Constants.KEY_AUTHORIZATION] = "Basic $authorization";
    headerParams[Constants.KEY_NOUNCE] =
        CryptoUtil.convertIntArrayToHexString(_nounce.toString().codeUnits);
    headerParams.addAll(reqList[0].hashHeaderParam);
    return headerParams;
  }

  String getUsername() {
    var initParams = mPlatwareProperties.initParams;
    var builder = StringBuffer();
    builder.write(
        "${initParams.orgId}$SEPERETOR${initParams.appId}$SEPERETOR${mPWCUtil.deviceDetails.imeiNumber}");
    return builder.toString();
  }

  Future<String> getAuthorizationBasic() async {
    var authorizationCode = StringBuffer();
    authorizationCode
        .write("${getUsername()}${COLON_SEPRETOR}app${COLON_SEPRETOR}$_nounce");

    String encryptionKey = await getEncryptionKey();

    return await mPWCUtil.encryptionUtil
        .encrypt(encryptionKey, authorizationCode.toString());
  }

  Future<String> getEncryptionKey() async {
    String decryptedSecret = await mPWCUtil.getDecryptedSecret();

    if (decryptedSecret.length > 0 && decryptedSecret.length >= 32) {
      return "$_nounce${decryptedSecret}".substring(0, 32);
    } else {
      throw Exception("Client secret is not valid.");
    }
  }

  @override
  Future<Map<String, Object>> getInterface() {
    return super.getInterface();
  }

  @override
  String getURL() {
    String url = reqList[0].url;
    if (null == url) {
      url = mPlatwareProperties?.initParams?.platwareUrl + "/register";
    }
    return url ?? "";
  }

  Future<Map<String, Object>> putLocationDatainHashMap(
      Map<String, Object> interface) async {
    Position position =
        await mPWCUtil.locationManager.getCurrentLocation(timeout: 2);
    if (position != null) {
      interface[Constants.KEY_DEVICE_LATITUDE] = position.latitude;
      interface[Constants.KEY_DEVICE_LONGITUDE] = position.longitude;
    }
    return interface;
  }
}
