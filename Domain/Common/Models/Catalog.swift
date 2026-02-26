//
//  Catalog.swift
//  Chihu
//
//

import Foundation

struct Catalog: Decodable {
    let pages: Int
    let count: Int
    let data: [ItemSchema]
}
