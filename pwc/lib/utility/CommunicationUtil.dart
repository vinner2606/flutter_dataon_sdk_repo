import 'dart:async';

import 'package:flutter/services.dart';
import 'package:pwc/security/EncryptionFactory.dart';

class CommunicationUtil {
  static const MethodChannel _channel = const MethodChannel('pwc');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> getEncryptKeyStoreCipher(String secret) async {
    var argument = <String, String>{"key": secret};
    final String version =
        await _channel.invokeMethod('EncryptKeyStoreCipher', argument);
    return version;
  }

  static Future<String> getDecryptKeyStoreCipher(String secret) async {
    var argument = <String, String>{"key": secret};
    final String version =
        await _channel.invokeMethod('DecryptKeyStoreCipher', argument);
    return version;
  }

  static Future<String> getEncryptedTextInRSA(
      String passphrase, String plainText) async {
    var keys =
        passphrase.replaceAll("\t", "").split(EncryptionFactory.RSA_SEPARATOR);
    String modulus = keys[0];
    String exponent = keys[1];

    var argu = <String, String>{
      "MODULUS": modulus,
      "EXPONENT": exponent,
      "PLAINTEXT": plainText
    };
    final String version = await _channel.invokeMethod("RSA_ENCRYPT", argu);
    return version;
  }

  static Future<String> getDecryptedTextInAES(
      String passphrase, String plainText) async {
    var argu = <String, String>{
      "PASSPHRASE": passphrase,
      "CIPHER_TEXT": plainText
    };
    final String version = await _channel.invokeMethod("AES_DECRYPT", argu);
    return version;
  }

  static Future<String> getEncryptedTextInAES(
      String passphrase, String plainText) async {
    var argu = <String, String>{
      "PASSPHRASE": passphrase,
      "PLAIN_TEXT": plainText
    };
    final String version = await _channel.invokeMethod("AES_ENCRYPT", argu);

    return version;
  }

  static Future<String> generatesha512Hash(String key, String plaintext) async {
    var argu = <String, String>{"KEY": key, "PLAIN_TEXT": plaintext};
    final String hash = await _channel.invokeMethod("SHA512_HASH", argu);

    return hash;
  }
}
