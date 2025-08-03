//
//  CatalogPostEndpoint.swift
//  Chihu
//
//  Created by Dennis Nunes on 15/04/25.
//

import Foundation

protocol CatalogPostRequestProtocol {
    var typeList: [String] { get }
    var itemUuid: String { get }
}

struct CatalogPostEndpoint: EndpointProtocol {
    // MARK: - Properties
    private var request: CatalogPostRequestProtocol
    
    var endpoint: String {
        "/api/item/\(request.itemUuid)/posts/"
    }
    
    var isTokenNeeded: Bool {
        true
    }
    
    var queryItems: [URLQueryItem] {
        var typeQuery: String = ""
        for type in request.typeList {
            typeQuery += type
            typeQuery += ","
        }
        
        if !typeQuery.isEmpty {
            typeQuery.removeLast()
            return [URLQueryItem(name: "type", value: typeQuery)]
        } else {
            return []
        }
    }

    // MARK: - Initialization
    init(_ request: CatalogPostRequestProtocol) {
        self.request = request
    }
}
