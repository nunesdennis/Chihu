//
//  ShelfGoogleBooks.swift
//  Chihu
//
//  Created by Dennis Nunes on 04/11/24.
//

import Foundation

struct ShelfGoogleBooks: Decodable {
    let count: Int
    let shelfItemsDetails: [ShelfItemsDetailsGoogleBooks]
    
    enum CodingKeys: String, CodingKey {
        case count = "totalItems"
        case shelfItemsDetails = "items"
    }
}

struct ShelfItemsDetailsGoogleBooks: Decodable {
    struct ImageLinks: Decodable {
        let thumbnail: String?
        
        enum CodingKeys: String, CodingKey {
            case thumbnail
        }
    }
    
    struct VolumeInfo: Decodable {
        let title: String
        let description: String?
        let previewLink: String
        let imageLinks: ImageLinks?
        
        enum CodingKeys: String, CodingKey {
            case title
            case description
            case previewLink
            case imageLinks
        }
    }
    
    let id: String
    let volumeInfo: VolumeInfo
    
    enum CodingKeys: String, CodingKey {
        case id
        case volumeInfo
    }
}
