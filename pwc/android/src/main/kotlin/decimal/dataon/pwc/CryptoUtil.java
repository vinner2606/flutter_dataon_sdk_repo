package decimal.dataon.pwc;



import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;


public class CryptoUtil {

    private CryptoUtil(){
        //nothing to do/
    }
    private static final String INITIAL_VECTOR = "d1553cdbef4d0b8c";
    private static final String ENCODING_SCHEME = "UTF-8";
    private static final String TAG = "CryptoUtil";

    // Encrypt text using AES key
    public static String encryptTextUsingAES(String plainText, String aesKeyString) {
        try {
            IvParameterSpec iv = new IvParameterSpec(INITIAL_VECTOR.getBytes(ENCODING_SCHEME));
            SecretKeySpec skeySpec = new SecretKeySpec(aesKeyString.getBytes(ENCODING_SCHEME), "AES");

            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5PADDING");
            cipher.init(Cipher.ENCRYPT_MODE, skeySpec, iv);

            byte[] encrypted = cipher.doFinal(plainText.getBytes());
            return convertByteArrayToHexString(encrypted);
        } catch (Exception ex) {

        }
        return null;
    }

    // Decrypt text using AES key
    public static String decryptTextUsingAES(String encryptedText, String aesKeyString) {
        try {
            IvParameterSpec iv = new IvParameterSpec(INITIAL_VECTOR.getBytes(ENCODING_SCHEME));
            SecretKeySpec skeySpec = new SecretKeySpec(aesKeyString.getBytes(ENCODING_SCHEME), "AES");

            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5PADDING");
            cipher.init(Cipher.DECRYPT_MODE, skeySpec, iv);

            byte[] original = cipher.doFinal(hexStringToByteArray(encryptedText.toCharArray()));
            return new String(original);
        } catch (Exception ex) {

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

        }

        return out;
    }

    private static int toDigit(char ch) {
        int digit = 0;
        try {
            digit = Character.digit(ch, 16);
        } catch (Exception ex) {

        }
        return digit;
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
        }
        return null;
    }
}
