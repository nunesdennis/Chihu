//
//  CollectionItemList.swift
//  Chihu
//
//

import Foundation

struct CollectionItemList: Decodable {
    let pages: Int
    let count: Int
    let data: [CollectionItemData]
}

struct CollectionItemData: Decodable {
    let item: ItemSchema
    let note: String
}
