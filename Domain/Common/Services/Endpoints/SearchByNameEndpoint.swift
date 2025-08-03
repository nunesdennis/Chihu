//
//  SearchByNameEndpoint.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 01/09/24.
//

import Foundation

protocol SearchByNameRequestProtocol {
    var query: String { get }
    var page: Int { get }
    var category: String? { get }
}

struct SearchByNameEndpoint: EndpointProtocol {
    // MARK: - Properties
    private var request: SearchByNameRequestProtocol
    
    var endpoint: String {
        "/api/catalog/search"
    }
    
    var isTokenNeeded: Bool {
        false
    }
    
    var queryItems: [URLQueryItem] {
        var query: [URLQueryItem] = []
        query.append(URLQueryItem(name: "query", value: request.query))
        query.append(URLQueryItem(name: "page", value: "\(request.page)"))
        if let category = categoryQuery() { query.append(category) }
        
        return query
    }
    
    // MARK: - Initialization
    init(_ request: SearchByNameRequestProtocol) {
        self.request = request
    }
    
    // MARK: - Private Methods
    private func categoryQuery() -> URLQueryItem? {
        guard let category = request.category else {
            return nil
        }
        
        return URLQueryItem(name: "category", value: category)
    }
}
