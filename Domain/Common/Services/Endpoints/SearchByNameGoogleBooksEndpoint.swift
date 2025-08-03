//
//  SearchByNameGoogleBooksEndpoint.swift
//  Chihu
//
//  Created by Dennis Nunes on 04/11/24.
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
        
        return query
    }
    
    // MARK: - Initialization
    init(_ request: GoogleBooksRequestProtocol) {
        self.request = request
    }
}
