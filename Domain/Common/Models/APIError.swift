//
//  APIError.swift
//  Chihu
//
//  Created by Dennis Nunes on 27/10/24.
//

import Foundation

struct APIError: LocalizedError, Decodable {
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case message
    }
    
    var errorDescription: String? {
        message
    }
}
