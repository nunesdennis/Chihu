//
//  CollectionsEndpoint.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 11/01/25.
//

import Foundation

protocol CollectionsRequestProtocol: CommonCollectionsRequestProtocol {
    var uuid: String { get }
}

protocol CollectionsItemRequestProtocol: CommonCollectionsRequestProtocol {
    var collectionUUID: String { get }
    var itemUUID: String { get }
}

protocol CommonCollectionsRequestProtocol {
    var method: HTTPMethod { get }
    var page: Int { get }
    var body: Encodable? { get }
}

extension CollectionsRequestProtocol {
    var uuid: String { "" }
}

extension CollectionsItemRequestProtocol {
    var collectionUUID: String { "" }
    var itemUUID: String { "" }
}

extension CommonCollectionsRequestProtocol {
    var page: Int { 1 }
    var body: Encodable? { nil }
}

struct CollectionsEndpoint: EndpointProtocol {
    // MARK: - Properties
    private var request: CommonCollectionsRequestProtocol
    
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
    
    func endpoint(request: CollectionsItemRequestProtocol) -> String {
        switch request.method {
        case .get:
            return "/api/me/collection/\(request.collectionUUID)/item/"
        case .put:
            fatalError("Endpoint missing in collection")
        case .post:
            return "/api/me/collection/\(request.collectionUUID)/item/"
        case .delete:
            return "/api/me/collection/\(request.collectionUUID)/item/\(request.itemUUID)"
        }
    }
    
    func endpoint(request: CollectionsRequestProtocol) -> String {
        switch request.method {
        case .get:
            return "/api/me/collection/"
        case .put:
            return "/api/me/collection/\(request.uuid)"
        case .post:
            return "/api/me/collection/"
        case .delete:
            return "/api/me/collection/\(request.uuid)"
        }
    }
    
    var endpoint: String {
        if let request = request as? CollectionsItemRequestProtocol {
            return endpoint(request: request)
        } else if let request = request as? CollectionsRequestProtocol {
            return endpoint(request: request)
        } else {
            fatalError("Endpoint missing in collection")
        }
    }
    
    var queryItems: [URLQueryItem] {
        if request.method == .get {
            return [URLQueryItem(name: "page", value: "\(request.page)")]
        }
        
        return []
    }
    
    // MARK: - Initialization
    init(request: CommonCollectionsRequestProtocol) {
        self.request = request
    }
}
