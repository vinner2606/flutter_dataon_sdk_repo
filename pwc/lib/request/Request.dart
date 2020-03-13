import 'package:pwc/model/enums.dart';
import 'package:pwc/utility/Constants.dart';

abstract class Request {
  var requestProcessor = RequestProcessor.BATCH;
  var callingType = CallingType.ER_ER;
  bool isSpecialProcess = false;
  var task = Task.SERVICE;
  String serviceName;
  var hashHeaderParam = Map<String, String>();
  var interfaceParam = Map<String, String>();
  var httpHeaderParameters = Map<String, String>();
  var priority = PriorityServerCall.NORMAL; // this is by default
  var url; // Request generator can add their custom url here
  List<Map<String, dynamic>> getRequest();

  int requestTimeout = Constants.REQUEST_TIMEOUT;

  addHeaderParam(key, value) {
    hashHeaderParam[key] = value;
  }
}
