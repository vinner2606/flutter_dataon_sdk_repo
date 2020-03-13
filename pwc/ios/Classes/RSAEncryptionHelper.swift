//
//  RSAEncryptionHelper.swift
//  PlatwareClient
//
//  Created by Shivang Garg on 28/06/18.
//  Copyright © 2018 Shivang Garg. All rights reserved.
//

import Foundation
import SwiftyRSA
import Security
import SwiftKeychainWrapper

extension String {
    
    // MARK: - RSA Encryption Decryption Helper methods
    public func encryptWithRSA(usingKey publicKeyPEM: String) -> String {
        do {
            let publicKey = try PublicKey(pemEncoded: "\n\(publicKeyPEM)\n")
            let clear = try ClearMessage(string: self, using: .utf8)
            let encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1)
            let data = encrypted.data
            return data.toHexString()
        } catch {
            print("〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️")
            print("🔴 Error while encrypting string = \(error.localizedDescription)")
            print("〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️")
            return ""
        }
    }
    
}
