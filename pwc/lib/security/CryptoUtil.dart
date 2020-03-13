import 'dart:typed_data';

class CryptoUtil {
  static String convertIntArrayToHexString(List<int> intString) {
    int v;
    try {
      if (intString == null) {
        return null;
      }
      Uint8List byteList = new Uint8List.fromList(intString);
      StringBuffer sb = new StringBuffer();

      for (final aTempArray in byteList) {
        v = aTempArray & 0xff;

        if (v < 16) {
          sb.write('0');
        }
        sb.write(v.toRadixString(16));
      }
      return sb.toString();
    } catch (exp) {}
    return null;
  }
  static String convertByteArrayToHexString( Uint8List byteList) {
    int v;
    try {
      if (byteList == null) {
        return null;
      }
      StringBuffer sb = new StringBuffer();

      for (final aTempArray in byteList) {
        v = aTempArray & 0xff;

        if (v < 16) {
          sb.write('0');
        }
        sb.write(v.toRadixString(16));
      }
      return sb.toString();
    } catch (exp) {}
    return null;
  }
}
