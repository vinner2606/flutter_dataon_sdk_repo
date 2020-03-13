import 'package:encrypt/encrypt.dart';
import 'package:pwc/security/CryptoUtil.dart';
import 'package:pwc/security/Encryption.dart';
import 'package:pwc/utility/CommunicationUtil.dart';
import 'package:pwc/utility/Constants.dart';

class AesEncryption extends Encryption {
  int keySize = Constants.AES_KEY_LENGTH;
  int iterationCount = Constants.AES_KEY_GENERATION_ITERATION_COUNT;
  final String INITIAL_VECTOR = "d1553cdbef4d0b8c";

  static AesEncryption instance = AesEncryption();
  @override
  Future<String> decrypt(String passphrase, String plainText) {
    return Future.value(
        CommunicationUtil.getDecryptedTextInAES(passphrase, plainText));
    /*

    var key = Key.fromUtf8(passphrase);
    final iv = IV.fromUtf8(INITIAL_VECTOR);
    Encrypter encrypter = Encrypter(AES(key, iv, mode: AESMode.cbc));
    return Future.value(encrypter.decrypt(new Encrypted.fromBase16(plainText)).toString());*/
  }

  @override
  Future<String> encrypt(String passphrase, String plainText) {
//    var key = Key.fromUtf8(passphrase);
//    final iv = IV.fromUtf8(INITIAL_VECTOR);
//    Encrypter encrypter = Encrypter(AES(key, iv, mode: AESMode.cbc));
//    return Future.value(CryptoUtil.convertByteArrayToHexString(
//        encrypter.encrypt(plainText).bytes));
  return CommunicationUtil.getEncryptedTextInAES(passphrase, plainText);

  }
}
