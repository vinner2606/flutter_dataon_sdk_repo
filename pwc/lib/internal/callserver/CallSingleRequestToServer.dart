import 'package:pwc/internal/networkcall/CallServerHttp.dart';
import 'package:pwc/listeners/PWConListener.dart';
import 'package:pwc/request/service/ServiceRequest.dart';
import 'package:pwc/response/NetResponse.dart';

abstract class CallSingleRequestToServer {
  CallSingleRequestToServer(this.pwConListener);

  PWConListener<NetResponse, String, String> pwConListener;

  static const String _processTag = "general_process_without_tag";

  callSingleRequestToServer(ServiceRequest serviceRequest);

  cancelRequest({String tag = _processTag});

  static CallSingleRequestToServer getInstance(
      PWConListener<NetResponse, String, String> pwConListener) {
    return CallServerHttp(pwConListener);
  }
}
