//
//  SearchByNameGoogleBooksEndpoint.swift
//  Chihu
//
//

import Foundation

protocol GoogleBooksRequestProtocol {
    var query: String { get }
    var category: String { get }
}

struct SearchByNameGoogleBooksEndpoint: EndpointProtocol {
    // MARK: - Properties
    private var request: GoogleBooksRequestProtocol
    
    var apiType: APItype {
        .googleBooks
    }
    
    var isTokenNeeded: Bool {
        false
    }
    
    var endpoint: String {
        "/volumes"
    }
    
    var queryItems: [URLQueryItem] {
        var query: [URLQueryItem] = []
        query.append(URLQueryItem(name: "q", value: request.query))
        if let apiKey = EnvironmentKeys.getValueFor(.googleApiKey) {
            query.append(URLQueryItem(name: "key", value: apiKey))
        }
        return query
    }
    
    // MARK: - Initialization
    init(_ request: GoogleBooksRequestProtocol) {
        self.request = request
    }
}
