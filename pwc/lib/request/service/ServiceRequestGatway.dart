import 'package:pwc/internal/PWCUtils.dart';
import 'package:pwc/request/Request.dart';
import 'package:pwc/request/service/ServiceRequestImpl.dart';
import 'package:pwc/utility/Constants.dart';
import 'package:pwc/utility/Utility.dart';

class ServiceRequestGateway extends ServiceRequestImpl {
  ServiceRequestGateway(List<Request> reqList, PWCUtils mPWCUtil)
      : super(reqList, mPWCUtil);

  @override
  Future<Map<String, String>> getHeaderParameter() async {
    var map = await super.getHeaderParameter();

    String decryptedToken = await mPWCUtil.getDecryptedToken();
    String decryptedRegistrationId = await mPWCUtil.decryptedRegistrationId;
    map[Constants.KEY_AUTHORIZATION] =
        decryptedToken ?? decryptedRegistrationId ?? "";
    map.addAll(reqList[0].hashHeaderParam);
    return map;
  }

  @override
  String getURL() {
    String url = reqList[0].url;
    if (Utility.isEmpty(url)) {
      url = mPlatwareProperties?.initParams?.platwareUrl + "/gateway";
    }
    return url ?? "";
  }
}
