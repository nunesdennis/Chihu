//
//  Collection.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 11/01/25.
//

import Foundation

struct CollectionList: Decodable {
    let pages: Int
    let count: Int
    let data: [CollectionModel]
}

struct CollectionModel: Decodable, Identifiable, Hashable {
    var id: String {
        uuid
    }
    
    let uuid: String
    let url: String
    let visibility: Int
    let title: String
    let brief: String?
    let cover: String?
}
