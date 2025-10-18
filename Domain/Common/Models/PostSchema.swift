//
//  PostSchema.swift
//  Chihu
//
//  Created by Dennis Nunes on 15/04/25.
//

import Foundation

struct UserSchema: Decodable {
    let id: String
    let acct: String
    let displayName: String
    let avatar: String
}

struct PostSchema: Decodable {
    let id: String
    let account: UserSchema
    let content: String
    let sensitive: Bool
    let spoilerText: String
    var language: String?
    let text: String
    var favourited: Bool?
}

struct PostsSchema: Decodable {
    let data: [PostSchema]
}
