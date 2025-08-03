//
//  Shelf.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 26/08/24.
//

import Foundation

struct Shelf: Decodable {
    let pages: Int
    let count: Int
    let data: [ShelfItem]
}

struct ShelfItem: Decodable {
    let shelfType: ShelfType
    let item: ItemSchema
    let ratingGrade: Int?
    let commentText: String?
    let title: String?
    let body: String?
}
