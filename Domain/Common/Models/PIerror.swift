//
//  PIerror.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 31/12/24.
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
