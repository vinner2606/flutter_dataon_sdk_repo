package decimal.dataon.pwc;

import android.util.Log;

import java.security.MessageDigest;

/**
 * Created by decimal on 31/3/18.
 */
public class SHACheckSumGenerator {


    private static final String ENCODING_SCHEME = "UTF-8";


    public static String generateCheckSum( String key,  String message) {
        String generatedHash = "";

        MessageDigest md;
        try {
            md = MessageDigest.getInstance("SHA-512");
            md.update(key.getBytes(ENCODING_SCHEME));
            byte[] bytes = md.digest(message.getBytes(ENCODING_SCHEME));
            StringBuilder sb = new StringBuilder();
            for (byte aByte : bytes) {
                sb.append(Integer.toString((aByte & 0xff) + 0x100, 16).substring(1));
            }
            generatedHash = sb.toString();

        } catch (Exception e) {
        Log.d("Shachecksum android","errror in hashing " + e.toString());
        }

        return generatedHash;

    }
}
