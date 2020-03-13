import 'dart:core';

import 'package:pwc/model/PlatwarePropertyModel.dart';
import 'package:pwc/model/enums.dart';
import 'package:pwc/request/RequestHashImp.dart';
import 'package:pwc/request/RequestInitImpl.dart';
import 'package:pwc/utility/Constants.dart';

class RequestFactory {
  RequestFactory();

  static RequestInitImpl getInitializationRequest(
      InitParams initParam, Map<String, String> interfaceParam) {
    return RequestInitImpl(Task.INIT, initParam, interfaceParam);
  }

  static RequestHashImp getAuthenticationRequest(
      String loginId, String password, Map<String, Object> otherBodyData,
      {Map<String, Object> interfaceParam}) {
    List<Map<String, Object>> body = new List();
    body.add(addValueToMap(
        {Constants.KEY_LOGIN_ID: loginId, Constants.KEY_PASSWORD: password},
        otherBodyData));
    RequestHashImp requestHashImp = RequestHashImp(Constants.SERVICE_AUTH,
        body: body, interfaceParam: interfaceParam);
    requestHashImp.isSpecialProcess = true;
    requestHashImp.callingType = CallingType.ER_ER;
    return requestHashImp;
  }

  static Map<String, Object> addValueToMap(
      Map<String, Object> map1, Map<String, Object> map2) {
    if (null != map2) map1.addAll(map2);
    return map1;
  }

  static getLogoutRequest() {
    return getServiceRequest(Constants.SERVICE_LOGOUT);
  }

  static RequestHashImp getServiceRequest(String serviceName,
      {List<Map<String, Object>> listHashMap,
      Map<String, String> interfaceParam}) {
    return RequestHashImp(serviceName,
        body: listHashMap, interfaceParam: interfaceParam);
  }
}
