
import 'package:pwc/request/service/ServiceRequest.dart';
import 'package:pwc/response/NetResponse.dart';

abstract class NetworkResponse {
  void onCompleted(NetResponse netResponse, ServiceRequest serviceRequest);

  void OnError(Exception e, ServiceRequest serviceRequest);
}
