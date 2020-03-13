import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pwc/security/CheckSumGenerator.dart';

class HMACChecksumGenerator extends CheckSumGenerator {
  @override
  Future<String> generateCheckSum(String key, String message) {
    StringBuffer buffer = new StringBuffer();
    List<int> secretBytes = utf8.encode(key);
    List<int> messageBytes = utf8.encode(message);
    Hmac hmac = new Hmac(sha256, secretBytes);
    var digest = hmac.convert(messageBytes);
    Uint8List res = new Uint8List.fromList(digest.bytes);
    for (int i = 0; i < res.length; i++) {
      buffer.write(res[i].toRadixString(16));
    }
    return Future.value(buffer.toString().toUpperCase());
  }
}
