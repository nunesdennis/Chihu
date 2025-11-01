//
//  PostSchema.swift
//  Chihu
//
//  Created by Dennis Nunes on 15/04/25.
//

import Foundation
import TootSDK

struct UserSchema: Decodable {
    let id: String
    let acct: String
    let displayName: String
    let avatar: String
}

extension UserSchema {
    func asClass() -> Account {
        .init(id: self.id,
              acct: self.acct,
              url: "",
              displayName: self.displayName,
              note: "",
              avatar: self.avatar,
              header: "",
              headerStatic: "",
              locked: false,
              emojis: [],
              createdAt: .init(),
              postsCount: .zero,
              followersCount: .zero,
              followingCount: .zero,
              fields: [])
    }
}

struct PostSchema: Decodable {
    let id: String
    let account: UserSchema
    let content: String
    let sensitive: Bool
    let spoilerText: String
    let text: String
    var language: String?
    var reposted: Bool?
    var favourited: Bool?
    var favouritesCount: Int?
    var repostsCount: Int?
    var repliesCount: Int?
    var url: String?
    var application: TootApplication?
}

extension PostSchema {
    func asClass() -> Post {
        .init(id: self.id,
              uri: "",
              createdAt: .init(),
              account: account.asClass(),
              content: self.content,
              visibility: .unlisted,
              sensitive: self.sensitive,
              spoilerText: self.spoilerText,
              mediaAttachments: [],
              application: self.application,
              mentions: [],
              tags: [],
              emojis: [],
              repostsCount: self.repostsCount ?? .zero,
              favouritesCount: self.favouritesCount ?? .zero,
              repliesCount: self.repliesCount ?? .zero,
              url: self.url,
              repost: nil,
              favourited: self.favourited,
              reposted: self.reposted)
    }
}

struct PostsSchema: Decodable {
    let data: [PostSchema]
}
