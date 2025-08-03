//
//  NeoDBURL.swift
//  Chihu
//
//  Created by citron on 1/19/25.
//  Edited by Dennis Nunes on 24/01/25.
//

import Foundation
import SwiftSoup
import SwiftUI

class URLHandler {
    static func handleItemURL(
        _ url: URL, completion: @escaping (ItemSchema?) -> Void
    ) {
        Task {
            completion(await NeoDBURL.parseItemURL(url))
        }
    }
}

class NeoDBURL {
    private static let neodbItemIdentifier = "~neodb~"
    private static let isDebugLoggingEnabled = false
    
    private static func log(_ message: String) {
        guard isDebugLoggingEnabled else { return }
    }
    
    static func parseItemURL(_ url: URL) async -> ItemSchema? {
        guard
            let components = URLComponents(
                url: url, resolvingAgainstBaseURL: true)
        else {
            return nil
        }

        // Remove leading slash and split path
        let path = components.path.dropFirst()
        let pathComponents = path.split(separator: "/").map(String.init)

        var type: String
        var id: String
        
        // Verify we have ~neodb~/type/id format
        if components.path.contains(neodbItemIdentifier),
           pathComponents.count >= 3,
           pathComponents[0] == neodbItemIdentifier {
            type = pathComponents[1]
            id = pathComponents[2]
        } else if pathComponents.count >= 2 {
            type = pathComponents[0]
            id = pathComponents[1]
        } else {
            return nil
        }

        // Handle special cases for tv seasons and episodes
        let category: ItemCategory
        if type == "podcast" {
            category = .podcast
        } else if type == "tv" && pathComponents.count >= 4 {
            switch pathComponents[2] {
            case "season":
                category = .tvSeason
            case "episode":
                category = .tvEpisode
            default:
                category = .tv
            }
            id = pathComponents[3]
        } else if type == "album" {
            category = .music
        } else if type == "performance" && pathComponents[2] == "production" {
            category = .performanceProduction
            id = pathComponents[3]
        } else if let itemCategory = ItemCategory(rawValue: type) {
            category = itemCategory
        } else {
            log("Unknown item type: \(type), defaulting to book")
            category = .book
        }

        log("Processing NeoDB URL - type: \(type), id: \(id)")
        
        return await fetchCatalog(uuid: id, category: category)
    }
    
    static func fetchCatalog(uuid: String, category: ItemCategory) async -> ItemSchema? {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                let request = CatalogTypeModel.Load.Request(category: category, uuid: uuid)
                let worker = CatalogNetworkingWorker()

                worker.fetchByUUID(request: request) { result in
                    switch result {
                    case .success(let response):
                        continuation.resume(returning: response.catalogItem)
                    case .failure(let error):
                        continuation.resume(throwing: ChihuError.canNotConvertURLtoItem)
                    }
                }
            }
        } catch {
            return nil
        }
    }
}


