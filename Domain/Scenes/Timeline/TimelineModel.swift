//
//  TimelineModel.swift
//  Chihu
//
//  
//
import Foundation
import TootSDK
import SwiftUI

enum Timeline {
    enum Load {
        struct Request: TimelineRequestProtocol {
            let timelineType: TootSDK.Timeline
            let pageInfo: PagedInfo?
        }
        
        struct Response {
            let posts: [Post]
        }
        
        struct ViewModel {
            let posts: [Post]
            
            init(response: Response) {
                self.posts = response.posts
            }
        }
    }
}
