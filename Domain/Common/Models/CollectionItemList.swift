//
//  CollectionItemList.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 14/01/25.
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
