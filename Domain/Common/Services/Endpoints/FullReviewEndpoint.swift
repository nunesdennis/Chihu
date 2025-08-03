//
//  FullReviewEndpoint.swift
//  Chihu
//
//  Created by Dennis Nunes on 15/12/24.
//

import Foundation

protocol FullReviewRequestProtocol {
    var method: HTTPMethod { get }
    var body: Encodable? { get }
    var itemUUID: String { get }
}

extension FullReviewRequestProtocol {
    var body: Encodable? { nil }
}

struct FullReviewEndpoint: EndpointProtocol {
    // MARK: - Properties
    private var request: FullReviewRequestProtocol
    
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
        return "/api/me/review/item/\(request.itemUUID)"
    }
    
    // MARK: - Initialization
    init(request: FullReviewRequestProtocol) {
        self.request = request
    }
}
