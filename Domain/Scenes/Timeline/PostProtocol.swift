//
//  PostProtocol.swift
//  Chihu
//
//  Created by Dennis Nunes on 15/04/25.
//

import Foundation
import TootSDK

protocol AccountProtocol {
    var displayName: String? { get }
    var acct: String { get }
    var avatar: String { get }
}

extension AccountProtocol {
    func asClass() -> Account {
        .init(id: "",
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

protocol PostProtocol: Identifiable {
    var id: String { get }
    var sensitive: Bool { get }
    var repostValue: (any PostProtocol)? { get }
    var accountValue: (any AccountProtocol) { get }
    var spoilerText: String { get }
    var content: String? { get }
    var applicationValue: ApplicationProtocol? { get }
    var favourited: Bool? { get }
    var favouritesCount: Int { get }
    var repostsCount: Int { get }
    var repliesCount: Int { get }
    var url: String? { get }
}

extension PostProtocol {
    func asClass() -> Post {
        .init(id: self.id,
              uri: "",
              createdAt: .init(),
              account: self.accountValue.asClass(),
              content: self.content,
              visibility: .unlisted,
              sensitive: self.sensitive,
              spoilerText: self.spoilerText,
              mediaAttachments: [],
              application: self.applicationValue?.asClass(),
              mentions: [],
              tags: [],
              emojis: [],
              repostsCount: self.repostsCount,
              favouritesCount: self.favouritesCount,
              repliesCount: self.repliesCount,
              url: self.url,
              repost: self.repostValue?.asClass(),
              favourited: self.favourited)
    }
}

protocol ApplicationProtocol {
    /// The name of your application.
    var name: String { get }
}

extension ApplicationProtocol {
    func asClass() -> TootApplication {
        .init(name: self.name)
    }
}
