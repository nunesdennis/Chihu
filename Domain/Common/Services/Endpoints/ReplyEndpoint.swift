//
//  ReplyEndpoint.swift
//  Chihu
//
//  Created by Angela Rosanne Santos de Oliveira on 28/09/25.
//

import Foundation
import TootSDK

protocol ReplyRequestProtocol {
    var body: Encodable { get }
}

struct ReplyEndpoint: EndpointProtocol {
    // MARK: - Properties
    private var request: ReplyRequestProtocol
    
    var endpoint: String {
        String()
    }
    
    // MARK: - Initialization
    init(_ request: ReplyRequestProtocol) {
        self.request = request
    }
}
