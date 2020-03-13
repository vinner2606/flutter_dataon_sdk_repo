import 'package:collection/collection.dart';
import 'package:pwc/internal/PWCUtils.dart';
import 'package:pwc/internal/callserver/CallServer.dart';
import 'package:pwc/internal/callserver/CallSingleRequestToServer.dart';
import 'package:pwc/listeners/PWCCallback.dart';
import 'package:pwc/request/Request.dart';
import 'package:pwc/request/service/ServiceRequest.dart';
import 'package:pwc/request/service/ServiceRequestAuth.dart';
import 'package:pwc/request/service/ServiceRequestGatway.dart';
import 'package:pwc/request/service/ServiceRequestLogout.dart';
import 'package:pwc/request/service/ServiceRequestRegister.dart';
import 'package:pwc/request_validator/validator.dart';
import 'package:pwc/response/Response.dart';
import 'package:pwc/utility/Constants.dart';

class CallServerImpl extends CallServer {
  PWCCallback<List<Response>> mCallback;

  CallServerImpl(this.mCallback) : super(mCallback);

  List<Request> reqList;

  @override
  List<Request> getRequestList() {
    return reqList;
  }

  @override
  void callServer(List<Request> reqList) {
    this.reqList = reqList;
    if (validate(reqList)) {
      var request = generateRequestListInBatch(reqList);
      request.forEach((request) {
        ServiceRequest serviceRequest;

        switch (request[0].serviceName) {
          case Constants.SERVICE_REGISTER_APP:
            {
              serviceRequest = ServiceRequestRegister(request, mPwcUtil);
              break;
            }
          case Constants.SERVICE_AUTH:
            {
              serviceRequest = ServiceRequestAuth(request, mPwcUtil);
              break;
            }
          case Constants.SERVICE_LOGOUT:
            {
              serviceRequest = ServiceRequestLogout(request, mPwcUtil);
              break;
            }
          default:
            {
              serviceRequest = new ServiceRequestGateway(request, mPwcUtil);
            }
        }
        if (serviceRequest != null) {
          map[serviceRequest.tagName()] = serviceRequest;
          var callSingleRequestToServer =
              CallSingleRequestToServer.getInstance(this);
          callSingleRequestToServer.callSingleRequestToServer(serviceRequest);
        }
      });
    }
  }

  bool validate(List<Request> reqList) {
    var requestCountValidation = RequestCountValidation();
    requestCountValidation.setNextValidator(NetworkValidator().setNextValidator(
        InitializationValidator().setNextValidator(ConfigurationValidator())));
    return requestCountValidation.validate(reqList, mCallback, PWCUtils());
  }

  List<List<Request>> generateRequestListInBatch(List<Request> params) {
    var groupbyURLType = groupBy(params, (obj) {
      Request request = obj;
      return '${request.url}${request.hashHeaderParam.toString()}${request.requestTimeout}${request.url}';
    });
    return groupbyURLType.values.toList();
  }
}
