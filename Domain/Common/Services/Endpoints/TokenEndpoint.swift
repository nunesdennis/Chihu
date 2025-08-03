//
//  TokenEndpoint.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 17/09/24.
//

import Foundation

protocol TokenRequestProtocol {
    var instanceBaseURL: String { get }
    var body: TokenRequestBodyProtocol { get }
}

struct TokenEndpoint: EndpointProtocol {
    // MARK: - Properties
    private let request: TokenRequestProtocol
    
    var baseURL: String {
        request.instanceBaseURL
    }
    
    var isTokenNeeded: Bool {
        false
    }
    
    var header: [String: String] {
        [:]
    }
    
    var method: String {
        "POST"
    }

    var body: Data? {
        var query: [URLQueryItem] = []
        query.append(URLQueryItem(name: "redirect_uri", value: request.body.redirectURI))
        query.append(URLQueryItem(name: "grant_type", value: request.body.grantType))
        query.append(URLQueryItem(name: "code", value: request.body.authCode))
        query.append(URLQueryItem(name: "client_secret", value: request.body.clientSecret))
        query.append(URLQueryItem(name: "client_id", value: request.body.clientId))
        
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = query
        
        return requestBodyComponents.query?.data(using: .utf8)
    }
    
    var endpoint: String {
        "/oauth/token"
    }
    
    // MARK: - Initialization
    init(_ request: TokenRequestProtocol) {
        self.request = request
    }
}
