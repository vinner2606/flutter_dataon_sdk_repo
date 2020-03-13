package decimal.dataon.pwc;

import android.annotation.TargetApi;
import android.content.Context;
import android.os.Build;
import android.security.KeyPairGeneratorSpec;
import android.security.keystore.KeyProperties;

import javax.crypto.Cipher;
import javax.security.auth.x500.X500Principal;

import java.io.IOException;
import java.math.BigInteger;
import java.security.InvalidAlgorithmParameterException;
import java.security.KeyPairGenerator;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.UnrecoverableEntryException;
import java.security.cert.CertificateException;
import java.util.Calendar;

public class KeyStoreCipher {

    static String encrypt(Context context, String plainText) {
        try {
            if (plainText.isEmpty()) {
                return null;
            }
            KeyStore.PrivateKeyEntry privateKeyEntry = getKeyEntry(context);
            PublicKey publicKey = privateKeyEntry.getCertificate().getPublicKey();
            Cipher inCipher = Cipher.getInstance("RSA/ECB/PKCS1Padding");
            inCipher.init(Cipher.ENCRYPT_MODE, publicKey);
            byte[] outputValue = inCipher.doFinal(plainText.getBytes());
            return convertByteArrayToHexString(outputValue);

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    static String decrypt(Context context, String cipherText) {
        try {
            if (cipherText == null || cipherText.isEmpty())
                return null;

            KeyStore.PrivateKeyEntry privateKeyEntry = getKeyEntry(context);
            PrivateKey privateKey = privateKeyEntry.getPrivateKey();
            Cipher inCipher = Cipher.getInstance("RSA/ECB/PKCS1Padding");
            byte[] inputStream = hexStringToByteArray(cipherText.toCharArray());
            inCipher.init(Cipher.DECRYPT_MODE, privateKey);
            byte[] outputValue = inCipher.doFinal(inputStream);
            return new String(outputValue);

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;

    }

    static private KeyStore.PrivateKeyEntry getKeyEntry(Context context) throws KeyStoreException, CertificateException, NoSuchAlgorithmException, IOException, NoSuchProviderException, InvalidAlgorithmParameterException, UnrecoverableEntryException {
        KeyStore keyStore = KeyStore.getInstance("AndroidKeyStore");
        keyStore.load(null);

        String alias = "PWC2.0";

        // Create the keys if necessary
        if (!keyStore.containsAlias(alias)) {
            generateKeyPair(alias, context);
        }

        // Retrieve the keys
        return (KeyStore.PrivateKeyEntry) keyStore.getEntry(alias, null);
    }


    @TargetApi(Build.VERSION_CODES.KITKAT)
   static private void generateKeyPair(String alias, Context context) throws NoSuchAlgorithmException, NoSuchProviderException, InvalidAlgorithmParameterException {
        Calendar notBefore = Calendar.getInstance();
        Calendar notAfter = Calendar.getInstance();
        notAfter.add(Calendar.YEAR, 15);
        String keyType;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            keyType = KeyProperties.KEY_ALGORITHM_RSA;
        } else {
            keyType = "RSA";
        }

        KeyPairGeneratorSpec spec = new KeyPairGeneratorSpec.Builder(context)
                .setAlias(alias)
                .setKeyType(keyType)
                .setKeySize(1024)
                .setSubject(new X500Principal("CN=test"))
                .setSerialNumber(BigInteger.ONE)
                .setStartDate(notBefore.getTime())
                .setEndDate(notAfter.getTime())
                .build();
        KeyPairGenerator generator = KeyPairGenerator.getInstance(keyType, "AndroidKeyStore");
        generator.initialize(spec);

        generator.generateKeyPair();

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

    public static byte[] hexStringToByteArray(char[] data) {
        byte[] out = null;
        try {
            int len = data.length;
            out = new byte[len >> 1];

            // two characters form the hex value.
            for (int i = 0, j = 0; j < len; i++) {
                int f = toDigit(data[j]) << 4;
                j++;
                f = f | toDigit(data[j]);
                j++;
                out[i] = (byte) (f & 0xFF);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        return out;
    }

    private static int toDigit(char ch) {
        int digit = 0;
        try {
            digit = Character.digit(ch, 16);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return digit;
    }
}
