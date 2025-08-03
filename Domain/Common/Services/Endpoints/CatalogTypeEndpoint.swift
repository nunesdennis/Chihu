//
//  CatalogTypeEndpoint.swift
//  Chihu
//
//  Created by Dennis Nunes on 24/01/25.
//

import Foundation

protocol CatalogTypeRequestProtocol {
    var category: ItemCategory { get }
    var uuid: String { get }
}

struct CatalogTypeEndpoint: EndpointProtocol {
    // MARK: - Properties
    private var request: CatalogTypeRequestProtocol
    
    var endpoint: String {
        "/api/\(getCategoryPath())/\(request.uuid)"
    }
    
    var isTokenNeeded: Bool {
        false
    }

    // MARK: - Initialization
    init(_ request: CatalogTypeRequestProtocol) {
        self.request = request
    }
    
    // MARK: - Private Methods
    private func getCategoryPath() -> String {
        switch request.category {
        case .book:
            return "book"
        case .movie:
            return "movie"
        case .tv:
            return "tv"
        case .tvSeason:
            return "tv/season"
        case .tvEpisode:
            return "tv/episode"
        case .music:
            return "album"
        case .game:
            return "game"
        case .podcast:
            return "podcast"
        case .performance:
            return "performance"
        case .performanceProduction:
            return "performance/production"
        // the List bellow is not available at the moment
        case .fanfic:
            return "fanfic"
        case .exhibition:
            return "exhibition"
        case .collection:
            return "collection"
        case .unknown, .allItems:
            return ""
        }
    }
}
