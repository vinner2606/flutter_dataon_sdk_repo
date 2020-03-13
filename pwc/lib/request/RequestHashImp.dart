import 'package:pwc/request/Request.dart';

class RequestHashImp extends Request {
  var serviceName;
  List<Map<String, Object>> body = List<Map<String, Object>>();
  Map<String, String> interfaceParam;

  RequestHashImp(this.serviceName, {this.body, this.interfaceParam}) {
    if (body == null) {
      body = [new Map<String, Object>()];
    }
  }

  @override
  List<Map<String, dynamic>> getRequest() {
    if (body != null && body.length > 0) {
      return body;
    } else {
      return new List();
    }
  }
}
