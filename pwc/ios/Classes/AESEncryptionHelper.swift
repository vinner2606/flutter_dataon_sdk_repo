//
//  PlatwareEncryptHelper.swift
//  PlatwareEncryption
//
//  Created by Shivang Garg on 22/06/18.
//  Copyright © 2018 Shivang Garg. All rights reserved.
//

import Foundation
import CryptoSwift
import Security

extension String {
    
    // MARK: - Properties
    private static var _initialVector = "d1553cdbef4d0b8c"
    public static var aesInitialVector: String {
        get {
            return String._initialVector
        }
        set(newValue) {
            String._initialVector = newValue
        }
    }
    
    // MARK: - AES Encryption Decryption Helper methods
    // MARK:  Public Encryption AES 128 bit Helpers
    
    
    /**
     Encrypt the string using 128 bit AES Encryption
     - parameters:
     - key: Key which is to be used for encrypting string. This key should be of 16 digit length
     - important: This is a String extention
     - Author: Shivang Garg
     */
    public func encryptAES128(usingKey key:String) -> String {
        
        let aesKey: [UInt8] = Array(key.utf8) as [UInt8]
        assert(aesKey.count == 16, "Key provided is not strong enough for AES 128 bit encryption")
        return aesEncrypt(usingKey: key)
    }
    
    
    /**
     Decrypt the string using 128 bit AES Encryption
     - parameters:
     - key: Key which is to be used for encrypting string. This key should be of 16 digit length
     - important: This is a String extention
     - Author: Shivang Garg
     */
    public func decryptAES128(usingKey key:String) -> String {
        
        //Strong key determination
        let aesKey: [UInt8] = Array(key.utf8) as [UInt8]
        assert(aesKey.count == 16, "Key provided is not strong enough for AES 128 bit encryption")
        return aesDecrypt(usingKey: key)
        
    }
    
    // MARK:  Public Encryption AES 192 bit Helpers
    /**
     Encrypt the string using 192 bit AES Encryption
     - parameters:
     - key: Key which is to be used for encrypting string. This key should be of 24 digit length
     - important: This is a String extention
     - Author: Shivang Garg
     */
    public func encryptAES192(usingKey key: String) -> String {
        
        let aesKey: [UInt8] = Array(key.utf8) as [UInt8]
        assert(aesKey.count == 24, "Key provided is not strong enough for AES 192 bit encryption")
        return aesEncrypt(usingKey: key)
    }
    
    /**
     Decrypt the string using 192 bit AES Encryption
     - parameters:
     - key: Key which is to be used for encrypting string. This key should be of 24 digit length
     - important: This is a String extention
     - Author: Shivang Garg
     */
    public func decryptAES192(usingKey key:String) -> String {
        
        //Strong key determination
        let aesKey: [UInt8] = Array(key.utf8) as [UInt8]
        assert(aesKey.count == 24, "Key provided is not strong enough for AES 192 bit encryption")
        return aesDecrypt(usingKey: key)
        
    }
    
    // MARK:  Public Encryption AES 256 bit Helpers
    /**
     Encrypt the string using 256 bit AES Encryption
     - parameters:
     - key: Key which is to be used for encrypting string. This key should be of 32 digit length
     - important: This is a String extention
     - Author: Shivang Garg
     */
    public func encryptAES256(usingKey key: String) -> String {
        
        let aesKey: [UInt8] = Array(key.utf8) as [UInt8]
        assert(aesKey.count == 32, "Key provided is not strong enough for AES 256 bit encryption")
        return aesEncrypt(usingKey: key)
    }
    
    /**
     Decrypt the string using 256 bit AES Encryption
     - parameters:
     - key: Key which is to be used for encrypting string. This key should be of 32 digit length
     - important: This is a String extention
     - Author: Shivang Garg
     */
    public func decryptAES256(usingKey key:String) -> String {
        
        //Strong key determination
        let aesKey: [UInt8] = Array(key.utf8) as [UInt8]
        assert(aesKey.count == 32, "Key provided is not strong enough for AES 256 bit encryption")
        return aesDecrypt(usingKey: key)
        
    }
    
    // MARK:  Private AES helper methods
    fileprivate func aesEncrypt(usingKey key: String) -> String {
        do {
           
                let aes = try AES(key: Array(key.utf8) as [UInt8], blockMode: CBC(iv: Array(String.aesInitialVector.utf8)), padding: .pkcs5)
                // aes128
                let ciphertext = try aes.encrypt(Array(self.utf8))
                let encryptedText =   ciphertext.hexa
                
                return encryptedText

           
        } catch {
            NSLog("Error while encrypting string = \(error.localizedDescription)")
            return ""
        }
    }
    
    fileprivate func aesDecrypt(usingKey key: String) -> String {
        
        //Converting inputed hex string to Array<UInt8>
    
        let cipherText = Array<UInt8>.init(hex: self)
        
        do {
            let aes = try AES(key: Array(key.utf8) as [UInt8], blockMode: CBC(iv: Array(String.aesInitialVector.utf8)), padding: .pkcs5) // aes128
            let decrypted = try aes.decrypt(cipherText)
            return String(data: Data(decrypted), encoding: .utf8) ?? ""
        } catch {
            NSLog("Error while decrypting string = \(error.localizedDescription)")
            return ""
        }
    }
    
    var hexaBytes: [UInt8] {
        var position = startIndex
        return (0..<count/2).compactMap { _ in    // for Swift 4.1 or later use compactMap instead of flatMap
            defer { position = index(position, offsetBy: 2) }
            return UInt8(self[position...index(after: position)], radix: 16)
        }
    }
    var hexaData: Data { return hexaBytes.data }
    
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}



extension Collection where Element == UInt8 {
    var data: Data {
        return Data(self)
    }
    var hexa: String {
        return map{ String(format: "%02X", $0) }.joined()
    }
}
