//
//  TimelineModel.swift
//  Chihu
//
//  Created by Dennis Nunes on 11/11/24.
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
