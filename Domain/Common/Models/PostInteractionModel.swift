//
//  PostInteractionModel.swift
//  Chihu
//
//  Created by Angela Rosanne Santos de Oliveira on 18/10/25.
//

import Foundation
import TootSDK

enum PostInteraction {
    enum Delete {
        struct Request: PostInteractionRequestProtocol {
            let method: HTTPMethod = .delete
            let postId: String
        }
        
        struct Response {
            let post: Post
        }
        
        struct ViewModel {
            let post: Post
        }
    }
    
    enum LikeDislike {
        struct Request: PostInteractionRequestProtocol {
            let method: HTTPMethod = .post
            let postId: String
            let favourited: Bool
        }
        
        struct Response {
            let post: Post
        }
        
        struct ViewModel {
            let post: Post
        }
    }
    
    enum Repost {
        struct Request: PostInteractionRequestProtocol {
            let method: HTTPMethod = .post
            let postId: String
            let reposted: Bool
        }
        
        struct Response {
            let post: Post
        }
        
        struct ViewModel {
            let post: Post
        }
    }
}
