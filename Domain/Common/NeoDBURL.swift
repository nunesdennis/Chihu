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
    enum knownServersUrl {
        static let eggplantUrl = "eggplant.place"
        static let neodbUrl = "neodb.social"
        static let reviewDB = "reviewdb.app"
        static let minreol = "minreol.dk"
        static let dbCasually = "db.casually.cat"
        static let neodbKevga = "neodb.kevga.de"
        static let fantastika = "fantastika.social"
        static let neodbDeadvey = "neodb.deadvey.com"
    }
    
    private static let neodbItemIdentifier = "~neodb~"
    private static let isDebugLoggingEnabled = false
    
    private static func log(_ message: String) {
        guard isDebugLoggingEnabled else { return }
    }
    
    static func hasNeoDBlink(_ content: String?) -> Bool {
        guard let content else {
            return false
        }
        
        if content.contains("~neodb~/") {
            return true
        }
        
        var searchBaseUrl = [
            knownServersUrl.eggplantUrl,
            knownServersUrl.neodbUrl,
            knownServersUrl.reviewDB,
            knownServersUrl.minreol,
            knownServersUrl.dbCasually,
            knownServersUrl.neodbKevga,
            knownServersUrl.fantastika,
            knownServersUrl.neodbDeadvey
        ]
        
        if let baseUrlString = UserSettings.shared.instanceURL?.trimmingCharacters(in:.whitespacesAndNewlines) {
            searchBaseUrl.append(baseUrlString)
        }
        
        let containsKnownServer = searchBaseUrl.contains(where: content.contains)
        
        return containsKnownServer
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
                    case .failure:
                        continuation.resume(throwing: ChihuError.canNotConvertURLtoItem)
                    }
                }
            }
        } catch {
            return nil
        }
    }
}


