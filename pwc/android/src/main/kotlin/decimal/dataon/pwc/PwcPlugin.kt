package decimal.dataon.pwc

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class PwcPlugin : MethodCallHandler {
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "pwc")
            channel.setMethodCallHandler(PwcPlugin())
        }
    }

    override fun onMethodCall(methodCall: MethodCall, result: Result) {
        if (methodCall.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE)
        } else if (methodCall.method.equals("RSA_ENCRYPT")) {
            val argument = methodCall.arguments as Map<*, *>
            val modulus = argument.get("MODULUS") as String
            val exponent = argument.get("EXPONENT") as String
            val plainText = argument.get("PLAINTEXT") as String
            val encryption = RsaEncryption()
            result.success(encryption.encrypt(modulus, exponent, plainText))
        } else if (methodCall.method.equals("AES_DECRYPT")) {
            val argument = methodCall.arguments as Map<*, *>
            val passPhrase = argument.get("PASSPHRASE") as String
            val cipherText = argument.get("CIPHER_TEXT") as String
            val encryption = decimal.dataon.pwc.AesEncryption()
            result.success(encryption.decrypt(passPhrase, cipherText))
        } else if (methodCall.method.equals("AES_ENCRYPT")) {
            val argument = methodCall.arguments as Map<*, *>
            val passPhrase = argument.get("PASSPHRASE") as String
            val plainText = argument.get("PLAIN_TEXT") as String
            result.success(CryptoUtil.encryptTextUsingAES(plainText, passPhrase))
        } else if (methodCall.method.equals("SHA512_HASH")) {
            val argument = methodCall.arguments as Map<*, *>
            val passPhrase = argument.get("KEY") as String
            val plainText = argument.get("PLAIN_TEXT") as String
            result.success(SHACheckSumGenerator.generateCheckSum(passPhrase,plainText))
        } else {
            result.notImplemented()
        }
    }
}
