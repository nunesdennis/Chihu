//
//  ShelfItunes.swift
//  Chihu
//

import Foundation

struct ShelfItunes: Decodable {
    let resultCount: Int
    let results: [ItunesResult]

    var count: Int { resultCount }
    var shelfItemsDetails: [ItunesResult] { results }
}

struct ItunesResult: Decodable {
    let collectionId: Int?
    let collectionName: String?
    let collectionViewUrl: String?
    let artistName: String?
    let artworkUrl100: String?
}
