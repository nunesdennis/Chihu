//
//  AuthorizeEndpoint.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 17/09/24.
//

import Foundation

struct AuthorizeEndpoint: EndpointProtocol {
    // MARK: - Properties
    private let instanceBaseURL: String
    
    var baseURL: String {
        instanceBaseURL
    }
    
    var isTokenNeeded: Bool {
        false
    }
    
    var header: [String: String] {
        [:]
    }
    
    var queryItems: [URLQueryItem] {
        let apiClientIDEnum = EnvironmentKeys.getApiClientId(from: instanceBaseURL)
        guard let apiClientID = EnvironmentKeys.getCustomClientId() ?? EnvironmentKeys.getValueFor(apiClientIDEnum) else {
            return []
        }
        var query: [URLQueryItem] = []
        query.append(URLQueryItem(name: "response_type", value: "code"))
        query.append(URLQueryItem(name: "client_id", value: apiClientID))
        query.append(URLQueryItem(name: "redirect_uri", value: "https://chihu.app/callback"))
        query.append(URLQueryItem(name: "scope", value: "read+write"))
        
        return query
    }
    
    var endpoint: String {
        "/oauth/authorize"
    }
    
    // MARK: - Initialization
    init(_ instanceBaseURL: String) {
        self.instanceBaseURL = instanceBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
