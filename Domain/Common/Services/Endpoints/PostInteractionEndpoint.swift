//
//  PostInteractionEndpoint.swift
//  Chihu
//
//  Created by Angela Rosanne Santos de Oliveira on 18/10/25.
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
