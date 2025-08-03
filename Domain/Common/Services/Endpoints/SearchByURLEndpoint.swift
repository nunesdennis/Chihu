//
//  SearchByURLEndpoint.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 01/09/24.
//

import Foundation

protocol SearchByURLRequestProtocol {
    var url: URL { get }
    var itemClass: any ItemProtocol.Type { get }
}

struct SearchByURLEndpoint: EndpointProtocol {
    // MARK: - Properties
    private var request: SearchByURLRequestProtocol
    
    var endpoint: String {
        "/api/catalog/fetch"
    }
    
    var isTokenNeeded: Bool {
        false
    }
    
    var queryItems: [URLQueryItem] {
        let percentEncodeURL = request.url.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return [URLQueryItem(name: "url", value: percentEncodeURL)]
    }
    
    var url: URL? {
        let urlString = (baseURL + endpoint).trimmingCharacters(in: .whitespacesAndNewlines)
        var components = URLComponents(string: urlString)
        components?.percentEncodedQueryItems = queryItems
        
        return components?.url
    }
    
    // MARK: - Initialization
    init(_ request: SearchByURLRequestProtocol) {
        self.request = request
    }
}
