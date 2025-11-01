//
//  NewCollectionModel.swift
//  Chihu
//
//  Created by Dennis Nunes on 31/01/25.
//  
//

import TootSDK
import Foundation

enum Reply {
    enum Send {
        struct Request: ReplyRequestProtocol {
            struct ReplyRequestBody: Encodable {
                let postId: String
                let comment: String
                let visibility: Post.Visibility
                let language: String
            }
            
            var body: Encodable
        }
        
        struct Response {
            let replyModel: Post
        }
        
        struct ViewModel {
            let replyModel: Post
        }
    }
    
    enum Update {
        struct Request: ReplyRequestProtocol {
            struct ReplyRequestBody: Encodable {
                let replyPostId: String
                let comment: String
            }
            
            var body: Encodable
        }
        
        struct Response {
            let replyModel: Post
        }
        
        struct ViewModel {
            let replyModel: Post
        }
    }
}
