//
//  Shelf.swift
//  Chihu
//
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
