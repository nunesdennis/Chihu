//
//  CatalogPostsModel.swift
//  Chihu
//
//  Created by Dennis Nunes on 15/04/25.
//

import Foundation
import TootSDK

enum CatalogPostsModel {
    enum Load {
        struct Request: CatalogPostRequestProtocol {
            let typeList: [String]
            let itemUuid: String
        }
        
        struct Response {
            let posts: PostsSchema
        }
        
        struct ViewModel {
            struct Account: AccountProtocol {
                let avatar: String
                let acct: String
                var displayName: String?
            }
            
            struct SimplePost: PostProtocol, Identifiable {
                let id: String
                let sensitive: Bool
                let accountValue: (any AccountProtocol)
                let spoilerText: String
                var repostValue: (any PostProtocol)?
                var content: String?
                var applicationValue: (any ApplicationProtocol)?
                var favourited: Bool?
                var favouritesCount: Int
                var repostsCount: Int
                var repliesCount: Int
                var url: String?
            }
            
            let posts: [Post]
            
            init(posts: PostsSchema) {
                self.posts = posts.data.map { post in
                    let acct = Account(avatar: post.account.avatar, acct: post.account.acct, displayName: post.account.displayName)
                    return SimplePost(id: post.id,
                                sensitive: post.sensitive,
                                accountValue: acct,
                                spoilerText: post.spoilerText,
                                content: post.content,
                                favourited: post.favourited,
                                favouritesCount: post.favouritesCount ?? .zero,
                                repostsCount: post.repostsCount ?? .zero,
                                repliesCount: post.repliesCount ?? .zero,
                                      url: post.url).asClass()
                }
            }
        }
    }
}
