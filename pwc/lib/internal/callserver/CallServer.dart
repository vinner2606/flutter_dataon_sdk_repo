import 'dart:convert';

import 'package:pwc/internal/PWCUtils.dart';
import 'package:pwc/internal/callserver/CallServerImpl.dart';
import 'package:pwc/listeners/Consumer.dart';
import 'package:pwc/listeners/PWCCallback.dart';
import 'package:pwc/listeners/PWConListener.dart';
import 'package:pwc/model/Record.dart';
import 'package:pwc/request/Request.dart';
import 'package:pwc/request/service/ServiceRequest.dart';
import 'package:pwc/response/NetResponse.dart';
import 'package:pwc/response/Response.dart';
import 'package:pwc/response/commands/AuthenticateCommand.dart';
import 'package:pwc/response/commands/Command.dart';
import 'package:pwc/response/commands/HandleResponseCommand.dart';
import 'package:pwc/response/commands/LogoutCommand.dart';
import 'package:pwc/response/commands/MultipleSessionCommand.dart';
import 'package:pwc/response/commands/RegisterCommand.dart';
import 'package:pwc/response/receiver/ResponseCommandReciever.dart';
import 'package:pwc/response/receiver/ResponseCommandRecieverImpl.dart';
import 'package:pwc/utility/Constants.dart';
import 'package:pwc/utility/Utility.dart';

abstract class CallServer extends PWConListener<NetResponse, String, String> {
  PWCCallback<List<Response>> mCallback;

  Map<String, ServiceRequest> map = Map<String, ServiceRequest>();
  var startTimeMillis = DateTime.now().millisecondsSinceEpoch;

  // list to hold succeed response
  var responseList = List<Response>();
  var mPwcUtil = PWCUtils();

  bool autoRegisterCallOnFailure = true;

  List<Request> getRequestList();

  callServer(List<Request> reqList);

  CallServer(this.mCallback);

  @override
  onCompleted(NetResponse netResponse, String tag) {
    if (netResponse.data != null && netResponse.data.isNotEmpty) {
      var serviceRequest = map.remove(tag);
      if (serviceRequest != null) {
        try {
          ResponseCommandReciever receiver =
              ResponseCommandReceiverImpl(netResponse, serviceRequest);
          Command command = getCommand(netResponse, receiver);
          command?.execute();
        } catch (e, stacktrace) {
          print(stacktrace);
          mCallback?.onFailure(e.message ?? "");
          mCallback = null;
        }
      } else {
        mCallback?.onFailure("Something went wrong");
        mCallback = null;
      }
    } else {
      mCallback?.onFailure("Response is empty for $tag");
      mCallback = null;
    }
    return null;
  }

  @override
  onIOExceptionOccured(String exception) {
    mCallback?.onFailure(exception ?? "Something went wrong.");
    mCallback = null;
  }

  Command getCommand(
      NetResponse netResponse, ResponseCommandReciever receiver) {
    var reqList = getRequestList();
    Command command;
    if (netResponse.statusCode == 200) {
      HandleResponseCommand handleResponseCommand = new HandleResponseCommand(
          receiver, new SuccessResponseListener(mCallback));
      command = handleResponseCommand;
    } else {
      print("CallServer" + netResponse.data);
      try {
        Map<String, Object> errorObject = jsonDecode(netResponse.data);
        var errorCode = errorObject[Constants.KEY_STATUS];
        String errorMessage = Utility.getNotNullAndNotEmpty([
          errorObject[Constants.KEY_ERRORHINT],
          errorObject[Constants.KEY_MESSAGE],
          "Something went wrong"
        ]);
        if (errorMessage?.length > 200) {
          errorMessage = errorMessage.substring(0, 200);
        }

        switch (errorCode) {
          case "402":
          case "622":
          case "628":
          case "528":
            if (reqList[0].serviceName == Constants.SERVICE_AUTH) {
              mCallback
                  ?.onFailure(errorMessage ?? Constants.ERROR_AUTH_FAILURE);
              mCallback = null;
            } else {
              command = new AuthenticateCommand(receiver);
              mCallback?.onFailure(
                  errorMessage ?? Constants.ERROR_INVALIDSESSION,
                  code: errorCode);
              mCallback = null;
            }
            break;
          case "401":
          case "537":
          case "627":
            if (reqList[0].serviceName != Constants.SERVICE_REGISTER_APP) {
              if (autoRegisterCallOnFailure) {
                command = new RegisterCommand(receiver, () {
                  CallServerImpl cs = CallServerImpl(mCallback);
                  cs.autoRegisterCallOnFailure = false;
                  cs.callServer(reqList);
                }, mCallback);
                break;
              } else {
                mCallback?.onFailure(
                    errorMessage ?? Constants.ERROR_INVALIDSESSION,
                    code: errorCode);
                mCallback = null;
              }
              command = AuthenticateCommand(receiver);
            } else {
              mCallback?.onFailure(
                  errorMessage ?? Constants.ERROR_DEVICE_REGISTRATION);
              mCallback = null;
            }
            break;
          case "621":
            //DialogActivity.callback = null
            //DialogActivity.callback = new MultipleSessionListener(mCallback);
            mCallback?.onFailure(errorMessage, code: errorCode);
            mCallback = null;
            command = MultipleSessionCommand(receiver, reqList[0]);
            break;
          case "625":
          case "620":
            var response = Response.name(Constants.SERVICE_LOGOUT);
            Record record = new Record();
            var data = <String, String>{
              "status": "SUCCESS",
              "message": "Logout successfully"
            };
            record.data = [data];
            response.records = [record];
            mCallback?.onResponse([response]);
            command = new LogoutCommand(receiver);
            break;
          default:
            mCallback.onFailure(errorMessage, code: errorCode);
            break;
        }
      } catch (e) {
        print("CallServer error parsing ${netResponse.data}");
        mCallback.onFailure("${netResponse.data}");
      }
    }
    return command;
  }
}

abstract class PCallback {
  void onSuccess(Object obj);

  void onFailure(String ex);
}

class MultipleSessionListener extends PCallback {
  PWCCallback<List<Response>> mCallback;

  MultipleSessionListener(this.mCallback);

  @override
  void onFailure(String ex) {
    mCallback?.onFailure(ex);
  }

  @override
  void onSuccess(Object obj) {
    mCallback?.onResponse(obj as List<Response>);
  }
}

class SuccessResponseListener extends Consumer<List<Response>> {
  PWCCallback<List<Response>> mCallback;

  SuccessResponseListener(this.mCallback);

  @override
  void accept(t) {
    if (mCallback != null) {
      mCallback.onResponse(t);
    }
    mCallback = null;
  }
}
