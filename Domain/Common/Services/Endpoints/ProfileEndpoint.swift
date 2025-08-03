//
//  ProfileEndpoint.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 25/08/24.
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
