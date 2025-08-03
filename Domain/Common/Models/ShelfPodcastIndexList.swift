//
//  ShelfPodcastIndexList.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 31/12/24.
//

import Foundation

struct ShelfPodcastIndexList: Decodable {
    let count: Int
    let shelfItemsDetails: [ShelfItemsDetailsPodcastIndex]
    
    enum CodingKeys: String, CodingKey {
        case count
        case shelfItemsDetails = "feeds"
    }
}

struct ShelfItemsDetailsPodcastIndex: Decodable {
    let id: Int
    let rssUrl: String
    let title: String
    let description: String?
    let image: String?
    let artwork: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case image
        case artwork
        case rssUrl = "url"
    }
}
