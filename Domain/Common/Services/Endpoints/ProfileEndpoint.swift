//
//  ProfileEndpoint.swift
//  Chihu
//
//

import Foundation

protocol ProfileRequestProtocol {}

struct ProfileEndpoint: EndpointProtocol {
    // MARK: - Properties
    private var request: ProfileRequestProtocol
    
    var endpoint: String {
        "/api/me"
    }
    
    // MARK: - Initialization
    init(_ request: ProfileRequestProtocol) {
        self.request = request
    }
}
