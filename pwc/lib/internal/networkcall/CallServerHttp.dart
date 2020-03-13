import 'package:pwc/internal/callserver/CallSingleRequestToServer.dart';
import 'package:pwc/internal/core/CorePlatware.dart';
import 'package:pwc/internal/networkcall/PWCStringRequest.dart';
import 'package:pwc/internal/networkcall/PlatwareNetworkClient.dart';
import 'package:pwc/listeners/PWConListener.dart';
import 'package:pwc/request/service/ServiceRequest.dart';
import 'package:pwc/response/NetResponse.dart';

class CallServerHttp extends CallSingleRequestToServer {
  PWConListener<NetResponse, String, String> pwConListener;

  CallServerHttp(PWConListener<NetResponse, String, String> pwConListener)
      : super(pwConListener) {
    this.pwConListener = pwConListener;
  }

  @override
  callSingleRequestToServer(ServiceRequest serviceRequest) async {
    PWCStringRequest pwcStringRequest = new PWCStringRequest(
        serviceRequest.getURL(),
        "POST",
        pwConListener,
        serviceRequest,
        await serviceRequest.getServiceRequestBody(),
        serviceRequest.tagName(),
        serviceRequest.getRequestTimeout());

    PlatwareNetworkClient platwareNetworkClient =
        PlatwareNetworkClient.getInstance();
    platwareNetworkClient.call(pwcStringRequest.listener, pwcStringRequest.url,
        pwcStringRequest.method,
        data: pwcStringRequest.requestBody,
        headers: await pwcStringRequest.getHeaders(),
        tag: pwcStringRequest.tag,
        timeout: pwcStringRequest.timeout,
        certificateFiles: CorePlatware().initParms.sslCertificatePath);
  }

  @override
  cancelRequest({String tag}) {
    return null;
  }
}
