//
//  UserPreferenceEndpoint.swift
//  Chihu
//
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
