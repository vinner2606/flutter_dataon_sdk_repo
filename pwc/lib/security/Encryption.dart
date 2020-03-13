
abstract class Encryption{
  String tag;
  Future<String> encrypt(String passphrase, String plainText);
  Future<String> decrypt(String passphrase, String plainText);
}