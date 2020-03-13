import Flutter
import UIKit

import Foundation
import SwiftyRSA
import CryptoSwift
import SwiftKeychainWrapper


public class SwiftPwcPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "pwc", binaryMessenger: registrar.messenger())
    let instance = SwiftPwcPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let argsMap : NSDictionary = call.arguments as! NSDictionary
            print("this is my method" + call.method)
            switch (call.method) {
            case "getPlatformVersion" :
                // result("iPhone")
                result("iPhone" + UIDevice.current.systemVersion)

            case "RSA_ENCRYPT" :
                let publicKey = argsMap["MODULUS"] as! String
                let plainText = argsMap["PLAINTEXT"] as! String
                DispatchQueue.global().async{
                    let cipherText: String = plainText.encryptWithRSA(usingKey: publicKey)
                   
                    DispatchQueue.main.async{
                       result(cipherText)
                    }
                }
            case "AES_ENCRYPT" :
                let passPhrase : String = argsMap["PASSPHRASE"] as! String
                let plainText : String = argsMap["PLAIN_TEXT"] as! String
                DispatchQueue.global().async{
                     let cipherText : String = plainText.encryptAES256(usingKey: passPhrase)
                    DispatchQueue.main.async{
                        result(cipherText)
                    }
                }
            case "AES_DECRYPT" :
                let passPhrase : String = argsMap["PASSPHRASE"] as! String
                let cipherText : String = argsMap["CIPHER_TEXT"] as! String
                DispatchQueue.global().async{
                    let plainText : String = cipherText.decryptAES256(usingKey: passPhrase)
                    DispatchQueue.main.async{
                        result(plainText)
                    }
                }

            case "SHA512_HASH" :
                let passPhrase : String = argsMap["KEY"] as! String
                let plainText : String = argsMap["PLAIN_TEXT"] as! String
                DispatchQueue.global().async{
                    let hash : String = plainText.hmac(usingSalt: passPhrase)
                    DispatchQueue.main.async{
                        result(hash)
                    }
                }
            default:
                result(FlutterMethodNotImplemented)
            }
  }
}
