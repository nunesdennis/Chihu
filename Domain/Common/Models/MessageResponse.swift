//
//  MessageResponse.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 16/09/24.
//

import Foundation

struct MessageResponse: Decodable {
    let message: String
    let url: String?
}
