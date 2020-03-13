import 'dart:convert';
import 'dart:core';

import 'package:pwc/listeners/PWConListener.dart';
import 'package:pwc/request/service/ServiceRequest.dart';
import 'package:pwc/request/service/ServiceRequestRegister.dart';
import 'package:pwc/response/NetResponse.dart';
import 'package:pwc/security/EncryptionFactory.dart';
import 'package:pwc/utility/Constants.dart';

class PWCStringRequest {
  String url;
  String method;
  PWConListener<NetResponse, String, String> listener;
  ServiceRequest serviceRequest;
  Object _requestBody;

  Object get requestBody {
    return _requestBody;
  }

  var ENCODING_TYPE = "utf-8";
  String tag;
  int timeout;

  PWCStringRequest(this.url, this.method, this.listener, this.serviceRequest,
      this._requestBody, this.tag, this.timeout);

  String getBodyContentType() {
    return "application/json; charset=utf-8";
  }

  Future<Map<String, Object>> getHeaders() async {
    var stopWatch = Stopwatch()..start();
    var hashHeader = await serviceRequest.getHeaderParameter();
    print("request header  $tag  " + hashHeader.toString());
    var checkSumGenerator = EncryptionFactory.getCheckSumGenerator(
        Constants.TYPE_CHECKSUM_GENERATOR);
    var txnKey = serviceRequest.getTxtKey();
    print("txnkey1 - " + txnKey);
    var hashValue;
    if (serviceRequest is ServiceRequestRegister) {
      String decryptedSecret =
          await serviceRequest.getPWCUtils().getDecryptedSecret();
      hashValue = await checkSumGenerator.generateCheckSum(
          decryptedSecret, hashHeader[Constants.KEY_AUTHORIZATION] ?? "");
    } else {
      var tempRequestBody = await requestBody;
      if (tempRequestBody is String) {
        hashValue =
            await checkSumGenerator.generateCheckSum(txnKey, tempRequestBody);
      } else {
        hashValue = await checkSumGenerator.generateCheckSum(
            txnKey, json.encode(tempRequestBody));
      }
      print("time in header hash ${stopWatch.elapsed.inMilliseconds}");
    }

    await serviceRequest.addHeaderParameter(
        Constants.HASH_VALUE, hashValue ?? "", hashHeader);
    return Future.value(hashHeader);
  }
}
