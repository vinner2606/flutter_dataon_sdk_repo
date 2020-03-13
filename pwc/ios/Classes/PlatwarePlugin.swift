//
//  SwiftSimpleRSAPlugin.swift
//  Runner
//
//  Created by Neha Singh on 01/05/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation
import SwiftyRSA
import CryptoSwift
import SwiftKeychainWrapper


public class PlatwarePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "platware", binaryMessenger: registrar.messenger())
        let instance = PlatwarePlugin()
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
            let cipherText: String = plainText.encryptWithRSA(usingKey: publicKey)
            result(cipherText)
            
        case "AES_ENCRYPT" :
            let passPhrase : String = argsMap["PASSPHRASE"] as! String
            let plainText : String = argsMap["PLAIN_TEXT"] as! String
            let cipherText : String = plainText.encryptAES256(usingKey: passPhrase)
            result(cipherText)
            
            
        case "AES_DECRYPT" :
            let passPhrase : String = argsMap["PASSPHRASE"] as! String
            let cipherText : String = argsMap["CIPHER_TEXT"] as! String
            let plainText : String = cipherText.decryptAES256(usingKey: passPhrase)
            result(plainText)
            
            
        default:
            let publicKey = argsMap["MODULUS"] as! String
            let plainText = argsMap["PLAINTEXT"] as! String
            let cipherText: String = plainText.encryptWithRSA(usingKey: publicKey)
            result(cipherText)
            //result(FlutterMethodNotImplemented)
        }
    }
    
}
