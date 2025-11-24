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
import TootSDK

class URLHandler {
    static func handleItemURL(
        _ url: URL, completion: @escaping ((any ItemProtocol)?) -> Void
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
    
    static func getItemURL(from post: Post) -> URL? {
        do {
            let postPreviews = PostPreviewSingleton.shared
            if let url = postPreviews.imagesDictionary[post.id] {
                return url
            }
            
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            
            guard let content = post.content, NeoDBURL.hasNeoDBlink(content) else {
                return nil
            }
            
            let input = content.replacingOccurrences(of: "~neodb~/", with: String())
            let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
            
            for match in matches {
                guard let range = Range(match.range, in: input) else {
                    return nil
                }
                var urlString = String(input[range])
                guard let url = NeoDBURL.cleanItemUrl(urlString, post.account.username) else {
                    continue
                }
                
                postPreviews.imagesDictionary[post.id] = url
                return url
            }
        } catch let error {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    private static func cleanItemUrl(_ urlString: String, _ username: String? = nil) -> URL? {
        var urlString = urlString.replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
        
        if let url = URL(string: urlString),
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            
            if let qParam = queryItems.first(where: { $0.name == "q" }),
               let qValue = qParam.value,
               (qValue.hasPrefix("http://") || qValue.hasPrefix("https://")) {
                urlString = qValue
            } else {
                for item in queryItems {
                    if let value = item.value,
                       (value.hasPrefix("http://") || value.hasPrefix("https://")) {
                        urlString = value
                        break
                    }
                }
            }
        }
        
        if let username,
           urlString.contains(username) {
            return nil
        }
        
        if urlString.contains("/tags/") {
            return nil
        }
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        return url
    }
    
    static func parseItemURL(_ url: URL) async -> (any ItemProtocol)? {
        guard let url = NeoDBURL.cleanItemUrl(url.absoluteString),
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
        
        if let baseUrlString = UserSettings.shared.instanceURL?.trimmingCharacters(in:.whitespacesAndNewlines),
           url.absoluteString.contains(baseUrlString) {
            return await fetchCatalog(uuid: id, category: category)
        } else {
            return await fetchByURL(url: url, category: category)
        }
    }
    
    static func fetchCatalog(uuid: String, category: ItemCategory) async -> (any ItemProtocol)? {
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
    
    static func fetchByURL(url: URL, category: ItemCategory) async -> (any ItemProtocol)? {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                let request = SearchByURL.Load.Request(url: url, itemClass: category.itemClass)
                let worker = CatalogNetworkingWorker()

                worker.fetchByURL(request: request) { result in
                    switch result {
                    case .success(let response):
                        continuation.resume(returning: response.shelfItemDetails)
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


