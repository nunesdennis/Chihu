//
//  CatalogPostsModel.swift
//  Chihu
//
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
            let posts: [Post]
            
            init(posts: PostsSchema) {
                self.posts = posts.data.map { post in
                    post.asClass()
                }
            }
        }
    }
}
