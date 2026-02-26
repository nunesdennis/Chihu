//
//  ApiUrlEndpoint.swift
//  Chihu
//
//

import Foundation

struct ApiUrlEndpoint: EndpointProtocol {
    // MARK: - Properties
    let apiURL: String
    
    var endpoint: String {
        apiURL
    }
    
    var isTokenNeeded: Bool {
        false
    }

    // MARK: - Initialization
    init(apiURL: String) {
        self.apiURL = apiURL
    }
}
