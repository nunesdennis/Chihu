//
//  Card.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 24/08/24.
//

import Foundation

struct Card: Identifiable {
    let id: String
    let uuid: String
    let poster: URL?
    let title: String
    var neoDBrating: Double?
    var userRating: Int?
    
    init(uuid: String, poster: URL? = nil, title: String, neoDBrating: Double? = nil, userRating: Int? = nil) {
        self.id = uuid
        self.uuid = uuid
        self.poster = poster
        self.title = title
        self.neoDBrating = neoDBrating
        self.userRating = userRating
    }
    
    init(item: ItemViewModel) {
        id = item.id
        uuid = item.uuid
        poster = item.poster
        title = item.localizedTitle
        neoDBrating = item.neoDBrating
        userRating = item.rating
    }
}

extension [Card] {
    func onlyOdds() -> [Card] {
        self.enumerated().filter { index, element in
            index % 2 == 1
        }.map( \.1 )
    }
    
    func onlyEvens() -> [Card] {
        self.enumerated().filter { index, element in
            index % 2 == 0
        }.map( \.1 )
    }
}

extension [ItemViewModel] {
    func asCards() -> [Card] {
        self.map {
            .init(uuid: $0.uuid, poster: $0.poster, title: $0.localizedTitle, neoDBrating: $0.neoDBrating, userRating: $0.rating)
        }
    }
}
