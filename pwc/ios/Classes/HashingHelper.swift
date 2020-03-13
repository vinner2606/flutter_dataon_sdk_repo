//
//  HashingHelper.swift
//  PlatwareClient
//
//  Created by Shivang Garg on 28/06/18.
//  Copyright © 2018 Shivang Garg. All rights reserved.
//

import Foundation
import Security
import CryptoSwift
import CommonCrypto

extension String {

    public func hmac(usingSalt salt:String) -> String {
        let partial1 = (Array((salt + self).utf8) as [UInt8]).sha512()
        return partial1.toHexString()
    }
    
//    func hmac(hashName:String, message:Data, key:Data) -> Data? {
//        let algos = ["SHA1":   (kCCHmacAlgSHA1,   CC_SHA1_DIGEST_LENGTH),
//                     "MD5":    (kCCHmacAlgMD5,    CC_MD5_DIGEST_LENGTH),
//                     "SHA224": (kCCHmacAlgSHA224, CC_SHA224_DIGEST_LENGTH),
//                     "SHA256": (kCCHmacAlgSHA256, CC_SHA256_DIGEST_LENGTH),
//                     "SHA384": (kCCHmacAlgSHA384, CC_SHA384_DIGEST_LENGTH),
//                     "SHA512": (kCCHmacAlgSHA512, CC_SHA512_DIGEST_LENGTH)]
//        guard let (hashAlgorithm, length) = algos[hashName]  else { return nil }
//        var macData = Data(count: Int(length))
//
//        macData.withUnsafeMutableBytes {macBytes in
//            message.withUnsafeBytes {messageBytes in
//                key.withUnsafeBytes {keyBytes in
//                    CCHmac(CCHmacAlgorithm(hashAlgorithm),
//                           keyBytes,     key.count,
//                           messageBytes, message.count,
//                           macBytes)
//                }
//            }
//        }
//        return macData
//    }
//
////    public func hmac(hashName:Hash, key:String) -> String {
//    public func hmac(usingSalt key:String) -> String {
//        let messageData = self.data(using:.utf8)!
//        let keyData = key.data(using:.utf8)!
//        return hmac(hashName:Hash.SHA512.rawValue, message:messageData, key:keyData)?.toHexString() ?? ""
//    }
}

public enum Hash:String {
    case SHA1 = "SHA1"
    case MD5 = "MD5"
    case SHA224 = "SHA224"
    case SHA256 = "SHA256"
    case SHA384 = "SHA384"
    case SHA512 = "SHA512"
}
