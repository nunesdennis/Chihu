//
//  PostInteractionEndpoint.swift
//  Chihu
//
//

import Foundation
import TootSDK

protocol PostInteractionRequestProtocol {
    var postId: String { get }
}

struct PostInteractionEndpoint: EndpointProtocol {
    // MARK: - Properties
    private var request: PostInteractionRequestProtocol
    
    var endpoint: String {
        String()
    }
    
    // MARK: - Initialization
    init(_ request: PostInteractionRequestProtocol) {
        self.request = request
    }
}
