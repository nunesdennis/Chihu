//
//  Catalog.swift
//  Chihu
//
//  Created by Dennis Nunes on 23/11/24.
//

import Foundation

struct Catalog: Decodable {
    let pages: Int
    let count: Int
    let data: [ItemSchema]
}
