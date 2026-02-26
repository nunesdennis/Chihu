//
//  ReviewEndpoint.swift
//  Chihu
//
//

import Foundation

protocol ReviewRequestProtocol {
    var method: HTTPMethod { get }
    var body: Encodable? { get }
    var itemUUID: String { get }
}

extension ReviewRequestProtocol {
    var body: Encodable? { nil }
}

struct ReviewEndpoint: EndpointProtocol {
    // MARK: - Properties
    private var request: ReviewRequestProtocol
    
    var method: String {
        request.method.rawValue
    }
    
    var body: Data? {
        if let body = request.body {
            return try? JSONEncoder().encode(body)
        } else {
            return nil
        }
    }
    
    var endpoint: String {
        return "/api/me/shelf/item/\(request.itemUUID)"
    }
    
    // MARK: - Initialization
    init(request: ReviewRequestProtocol) {
        self.request = request
    }
}
