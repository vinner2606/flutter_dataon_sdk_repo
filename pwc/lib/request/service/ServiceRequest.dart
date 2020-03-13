import 'dart:core';

import 'package:pwc/internal/PWCUtils.dart';
import 'package:pwc/model/enums.dart';
import 'package:pwc/request/Request.dart';

abstract class ServiceRequest {
  PWCUtils getPWCUtils();

  String tagName();

  Object getServiceRequestBody();

  Future<Map<String, Object>> getHeaderParameter();

  addHeaderParameter(String key, String value, Map<String, String> Map);

  String getURL();

  PriorityServerCall getPriority();

  String getTxtKey();

  CallingType getCallingType();

  Future<Map<String, String>> getResponseHeaders();

  String getResponseCode();

  int getRequestTimeout();

  List<Request> getRequestList();

  RequestProcessor getRequestProcessor();

  Future<String> getRequestId();
}
