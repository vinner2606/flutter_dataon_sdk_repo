package decimal.dataon.pwc;

import java.math.BigInteger;
import java.security.InvalidKeyException;
import java.security.KeyFactory;
import java.security.NoSuchAlgorithmException;
import java.security.PublicKey;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.KeySpec;
import java.security.spec.RSAPublicKeySpec;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;


import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;

public class RsaEncryption extends Encryption {
    private String transformation = "RSA/ECB/PKCS1Padding";



    @Override
    String encrypt(String mod,String expo, String plainText) {
        BigInteger modulus = new BigInteger(mod);
        BigInteger exponent = new BigInteger(expo);
        String encryptedString = "";
        try {
            encryptedString = encrypt(plainText, modulus, exponent);
        } catch (InvalidKeySpecException e) {
            e.printStackTrace();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        } catch (NoSuchPaddingException e) {
            e.printStackTrace();
        } catch (InvalidKeyException e) {
            e.printStackTrace();
        } catch (BadPaddingException e) {
            e.printStackTrace();
        } catch (IllegalBlockSizeException e) {
            e.printStackTrace();
        }

        return encryptedString;
    }

    @Override
    String encrypt(String passphrase, String plainText) {
        return null;
    }

    @Override
    String decrypt(String passphrase, String cipherText) {
        return null;
    }


    // Code to Encrypt
    private String encrypt(String inputString, BigInteger modulus,
                           BigInteger exponent) throws InvalidKeySpecException, NoSuchAlgorithmException, NoSuchPaddingException, InvalidKeyException, BadPaddingException, IllegalBlockSizeException {
        byte[] bt = inputString.getBytes();
        try {
            PublicKey pubKey = getPublicKey(modulus, exponent);
            //            Security.addProvider(new org.bouncycastle.jce.provider.BouncyCastleProvider());
            Cipher cipher = Cipher.getInstance(transformation);
            cipher.init(Cipher.ENCRYPT_MODE, pubKey);
            byte[] outputValue = cipher.doFinal(bt);

            return convertByteArrayToHexString(outputValue);
        } catch (Exception ex) {
            ex.printStackTrace();
            ;
        }

        return "";
    }


    private PublicKey getPublicKey(BigInteger modulus, BigInteger exponent) throws InvalidKeySpecException, NoSuchAlgorithmException {

        KeySpec keySpec = new RSAPublicKeySpec(modulus, exponent);
        KeyFactory fact = KeyFactory.getInstance("RSA");
        return fact.generatePublic(keySpec);
    }

    public static String convertByteArrayToHexString(byte[] tempArray) {

        int v;
        try {
            if (tempArray == null) {
                return null;
            }
            StringBuilder sb = new StringBuilder(tempArray.length * 2);

            for (byte aTempArray : tempArray) {
                v = aTempArray & 0xff;

                if (v < 16) {
                    sb.append('0');
                }
                sb.append(Integer.toHexString(v));

            }
            return sb.toString();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
