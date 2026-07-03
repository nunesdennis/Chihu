//
//  ShelfIGDB.swift
//  Chihu
//

import Foundation

struct ShelfIGDB {
    let games: [IGDBGame]

    var count: Int { games.count }
    var shelfItemsDetails: [IGDBGame] { games }
}

struct IGDBGame: Decodable {
    let id: Int
    let name: String?
    let cover: IGDBCover?
    let summary: String?
    let slug: String?
}

struct IGDBCover: Decodable {
    let url: String?
}

struct IGDBTokenResponse: Decodable {
    let accessToken: String
    let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
    }
}
