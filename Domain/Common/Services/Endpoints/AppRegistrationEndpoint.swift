//
//  AppRegistrationEndpoint.swift
//  Chihu
//
//  Created by Dennis Nunes on 06/04/25.
//

import Foundation

struct AppRegistrationEndpoint: EndpointProtocol {
    // MARK: - Properties
    private let request: AppRegistrationRequest
    
    var baseURL: String {
        request.instanceBaseURL.trimmingCharacters(in:.whitespacesAndNewlines)
    }
    
    var method: String {
        "POST"
    }
    
    var isTokenNeeded: Bool {
        false
    }
    
    var endpoint: String {
        "/api/v1/apps"
    }
    
    var body: Data? {
        let body = request.body
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        return try? encoder.encode(body)
    }
    
    // MARK: - Initialization
    init(_ request: AppRegistrationRequest) {
        self.request = request
    }
}
