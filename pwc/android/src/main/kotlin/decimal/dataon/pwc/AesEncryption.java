package decimal.dataon.pwc;

class AesEncryption extends Encryption {



    @Override
    String encrypt(String passphrase, String plainText) {
        return null;
    }

    @Override
    String decrypt(String passphrase, String cipherText) {
        return CryptoUtil.decryptTextUsingAES(cipherText,passphrase);
    }

    @Override
    String encrypt(String mod, String expo, String plainText) {
        return null;
    }

}