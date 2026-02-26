//
//  APIError.swift
//  Chihu
//
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
