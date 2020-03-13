import 'package:pwc/model/SyncTableBO.dart';
import 'package:pwc/request/RequestHashImp.dart';

class RequestOutSync extends RequestHashImp {
  String serviceName;
  List<Map<String, Object>> body;
  Map<String, String> interfaceParam;
  var isOutboundSyncRequest = true;
  SyncTableBO tableBO;

  RequestOutSync(this.serviceName, this.body, this.interfaceParam)
      : super(serviceName, body: body, interfaceParam: interfaceParam);
}
