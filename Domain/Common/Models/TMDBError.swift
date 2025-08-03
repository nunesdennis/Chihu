//
//  TMDBError.swift
//  Chihu
//
//  Created by Dennis Nunes on 23/10/24.
//

import Foundation

struct TMDBError: LocalizedError, Decodable {
    let success: Bool
    let statusCode: Int
    let statusMessage: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case statusMessage = "status_message"
    }
    
    var errorDescription: String? {
        statusMessage
    }
}
