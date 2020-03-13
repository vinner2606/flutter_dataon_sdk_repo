package decimal.dataon.pwc;

public abstract class Encryption {
    abstract String encrypt(String passphrase, String plainText);

    abstract String decrypt(String passphrase, String cipherText);
    abstract String encrypt(String mod,String expo, String plainText);


}
