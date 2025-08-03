//
//  KeychainManager.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 17/09/24.
//

import Foundation
import Security

final class KeychainManager {
    private let SecAttrAccessGroup: String! = kSecAttrAccessGroup as String
    private var accessGroup: String {
        (EnvironmentKeys.getValueFor(.teamId) ?? "") + ".me.nunesdennis.Chihu.sharedKeychain"
    }
    
    static let instance = KeychainManager()
    private init() {}

    enum KeychainError: Error {
        case unknown(OSStatus)
    }
    
    func deleteToken(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            SecAttrAccessGroup: accessGroup
        ]
        
        // Delete existing item if exists
        SecItemDelete(query as CFDictionary)
    }
    
    func saveToken(_ token: String, forKey key: String) throws {
        if let data = token.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked,
                SecAttrAccessGroup: accessGroup
            ]

            // Delete existing item if exists
            SecItemDelete(query as CFDictionary)
            
            let status = SecItemAdd(query as CFDictionary, nil)

            guard status == errSecSuccess else {
               throw KeychainError.unknown(status)
            }
        }
    }
    
    func getToken(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            SecAttrAccessGroup: accessGroup
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess, let data = dataTypeRef as? Data {
             return String(data: data, encoding: .utf8)
        }

        return nil
    }
}
