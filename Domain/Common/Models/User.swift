//
//  User.swift
//  Chihu
//
//

import Foundation

struct User: Decodable {
    let url: String
    let externalAccount: String?
    let displayName: String
    let avatar: String
    let username: String
    
    enum CodingKeys: String, CodingKey {
        case url
        case externalAccount = "external_acct"
        case displayName = "display_name"
        case avatar
        case username
    }
}
