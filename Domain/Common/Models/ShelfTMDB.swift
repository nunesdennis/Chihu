//
//  ShelfTMDB.swift
//  Chihu
//
//  Created by Dennis Nunes on 09/09/24.
//

import Foundation

struct ShelfTMDB: Decodable {
    let pages: Int
    let count: Int
    let shelfItemsDetails: [ShelfItemsDetailsTMDB]
    
    enum CodingKeys: String, CodingKey {
        case pages = "page"
        case count = "total_results"
        case shelfItemsDetails = "results"
    }
}

struct ShelfItemsDetailsTMDB: Decodable {
    let id: Int
    let title: String?
    let name: String?
    let originalName: String?
    let description: String
    let poster: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case name
        case originalName = "original_name"
        case description = "overview"
        case poster = "poster_path"
    }
}
