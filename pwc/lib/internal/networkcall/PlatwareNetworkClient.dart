import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pwc/internal/PWCUtils.dart';
import 'package:pwc/listeners/PWConListener.dart';
import 'package:pwc/model/FilePersistor.dart';
import 'package:pwc/response/NetResponse.dart';

abstract class PlatwareNetworkClient {
  static PlatwareNetworkClient _platwareNetworkClient;

  PlatwareNetworkClient._();

  static getInstance() {
    if (_platwareNetworkClient == null) {
      _platwareNetworkClient = new PlatwareNetworkClientImpl();
    }
    return _platwareNetworkClient;
  }

  void call(PWConListener<NetResponse, String, String> listener,
      String requestUrl, String method,
      {Map<String, Object> headers,
      Object data,
      List<String> certificateFiles,
      String tag,
      int timeout});
}

class PlatwareNetworkClientImpl implements PlatwareNetworkClient {
  @override
  void call(PWConListener<NetResponse, String, String> listener,
      String requestUrl, String method,
      {Map<String, Object> headers,
      Object data,
      var certificateFiles,
      String tag,
      int timeout = 60}) async {
    var context = SecurityContext();
    if (certificateFiles != null) {
      context = await getSecCont(certificateFiles);
      print("Certificates attached");
    } else {
      print("Certificates not attached");
    }
    callingServer(context, timeout, requestUrl, headers, listener, tag, data);
  }

  Future<SecurityContext> getSecCont(certificateFiles) async {
    var cont = SecurityContext();
    for (var file in certificateFiles) {
      ByteData data = await rootBundle.load(file);
//        SecurityContext context = SecurityContext.defaultContext;
      cont.setTrustedCertificatesBytes(data.buffer.asUint8List());
//      cont.setTrustedCertificates(file);
      print("Certificates attaching");
//        context.setTrustedCertificatesBytes(await new File(file).readAsBytes());
    }
    return cont;
  }

  void callingServer(
      context, timeout, requestUrl, headers, listener, tag, data) async {
    print("Calling with context");
    HttpClient client = new HttpClient(context: context);
    PWCUtils pwcUtils = PWCUtils();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) =>
            false ||
            (pwcUtils?.mPlatwareProperties?.initParams?.isSSLByPassRequired ??
                false));
    Duration timeoutDuration = new Duration(seconds: timeout);
    client.connectionTimeout = timeoutDuration;
    onTimeout() {
      listener
          .onIOExceptionOccured(new TimeoutException("Timed out").toString());
    }

    try {
      var request = await client
          .openUrl(
            Method.POST,
            Uri.parse(requestUrl),
          )
          .timeout(timeoutDuration, onTimeout: onTimeout);
      request.headers.contentType =
          new ContentType("application", "json", charset: "utf-8");
      headers.forEach((key, value) {
        request.headers.add(key, value);
      });
      Object uploadingData = await data;
      print("Headers $tag" + "  " + headers.toString());
      print("Request $tag" + "   " + data.toString());
      request.write(json.encode(uploadingData));

      var response =
          await request.close().timeout(timeoutDuration, onTimeout: onTimeout);
      print("response recieved");
      NetResponse netResponse = new NetResponse();
      Map<String, Object> responseHeader = new LinkedHashMap(
          equals: (a, b) => a.toUpperCase() == b.toUpperCase(),
          hashCode: (a) => a.toUpperCase().hashCode);
      response.headers.forEach((name, value) {
        try {
          responseHeader[name] = response.headers.value(name);
        } catch (e) {
          print(e);
        }
      });
      netResponse.header = responseHeader;
      print("header is parsed");
      String resData = await response.transform(utf8.decoder).join();
      print("after response transforming");
      netResponse.data = resData;
      netResponse.statusCode = response.statusCode;
      listener.onCompleted(netResponse, tag);
    } on SocketException catch (se) {
      print(se?.toString());
      listener.onIOExceptionOccured(
          "Something went wrong. Please check your internet connection.");
    } catch (exception) {
      print(exception?.toString());
      listener.onIOExceptionOccured(
          "Something went wrong. ${exception.toString()}");
    } finally {
      try {
        client.close();
      } catch (e) {
        print(e.toString());
      }
    }
  }
}

class Method {
  static int DEPRECATED_GET_OR_POST = -1;
  static int GET = 0;
  static String POST = "POST";
  static int PUT = 2;
  int DELETE = 3;
  int HEAD = 4;
  int OPTIONS = 5;
  int TRACE = 6;
  int PATCH = 7;
}
