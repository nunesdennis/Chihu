//
//  UserPreferenceEndpoint.swift
//  Chihu
//
//  Created by Dennis Nunes on 05/04/25.
//

import Foundation

protocol UserPreferenceRequestProtocol {}

struct UserPreferenceEndpoint: EndpointProtocol {
    // MARK: - Properties
    private var request: UserPreferenceRequestProtocol
    
    var endpoint: String {
        return "/api/me/preference"
    }
    
    // MARK: - Initialization
    init(request: UserPreferenceRequestProtocol) {
        self.request = request
    }
}
