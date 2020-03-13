import 'package:pwc/internal/PWCUtils.dart';
import 'package:pwc/request/Request.dart';
import 'package:pwc/request/service/ServiceRequestImpl.dart';
import 'package:pwc/utility/Constants.dart';
import 'package:pwc/utility/Utility.dart';

class ServiceRequestLogout extends ServiceRequestImpl {
  ServiceRequestLogout(List<Request> reqList, PWCUtils mPWCUtil)
      : super(reqList, mPWCUtil);

  @override
  Future<Map<String, String>> getHeaderParameter() async {
    var map = await super.getHeaderParameter();
/*
    String decryptingToken= await mPWCUtil.getDecryptedToken()??"";
    String decryptedKey=mPWCUtil.decryptedKey;
    if (decryptedKey != null && decryptingToken != null) {
	    decryptingToken =  await mPWCUtil.encryptionUtil.decrypt(decryptedKey, decryptingToken);
    }*/
    String decryptingToken = await mPWCUtil.getDecryptedToken() ?? "";
    map[Constants.KEY_AUTHORIZATION] = decryptingToken;
    map.addAll(reqList[0].hashHeaderParam);
    return map;
  }

  @override
  String getURL() {
    String url = reqList[0].url;
    if (Utility.isEmpty(url)) {
      url = mPlatwareProperties?.initParams?.platwareUrl + "/logout";
    }
    return url ?? "";
  }
}
