//
//  PIerror.swift
//  Chihu
//
//

import Foundation

struct PIerror: LocalizedError, Decodable {
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case description
    }
    
    var errorDescription: String? {
        description
    }
}
