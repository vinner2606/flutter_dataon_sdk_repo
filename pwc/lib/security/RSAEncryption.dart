import 'package:pwc/security/Encryption.dart';
import 'package:pwc/utility/CommunicationUtil.dart';

class RSAEncryption extends Encryption {
  static RSAEncryption instance = RSAEncryption();
  @override
  Future<String> decrypt(String passphrase, String plainText) {
    return Future.value(plainText);
  }

  @override
  Future<String> encrypt(String passphrase, String plainText) async {
    String encrypt = "";
    encrypt =
        await CommunicationUtil.getEncryptedTextInRSA(passphrase, plainText);
    return encrypt;
  }
}
