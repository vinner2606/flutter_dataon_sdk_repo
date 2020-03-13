import 'dart:typed_data';

import 'package:pwc/security/CheckSumGenerator.dart';
import 'package:pointycastle/digests/sha512.dart';
import 'package:pwc/utility/CommunicationUtil.dart';

class SHACheckSumGenerator extends CheckSumGenerator {
  @override
  Future<String> generateCheckSum(String key, String message) async {
//    StringBuffer buffer = new StringBuffer();
//    SHA512Digest sha512digest = new SHA512Digest();
//    Uint8List keyUp = new Uint8List.fromList(key.trim().codeUnits);
//    sha512digest.update(keyUp, 0, keyUp.length);
//
//    Uint8List messageByteList =
//        sha512digest.process(new Uint8List.fromList(message.trim().codeUnits));
//    for (final aByte in messageByteList) {
//      int num = ((aByte & 0xff) + 0x100);
//      buffer.write(num.toRadixString(16).substring(1));
//    }
//    return buffer.toString();

    return await CommunicationUtil.generatesha512Hash(key, message);
  }
}
