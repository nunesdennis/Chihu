//
//  NeoDBURL.swift
//  Chihu
//
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
        static let neoDBbridge = "bridge.neodb.net"
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
            knownServersUrl.neodbDeadvey,
            knownServersUrl.neoDBbridge
        ]
        
        if let baseUrlString = UserSettings.shared.instanceURL?.trimmingCharacters(in:.whitespacesAndNewlines) {
            searchBaseUrl.append(baseUrlString)
        }
        
        let containsKnownServer = searchBaseUrl.contains(where: content.contains)
        
        return containsKnownServer
    }
    
    static func getItemURL(from post: Post) -> URL? {
        let postPreviews = PostPreviewSingleton.shared
        if let url = postPreviews.imagesDictionary[post.id] {
            return url
        }

        guard let content = post.content, NeoDBURL.hasNeoDBlink(content) else {
            return nil
        }

        let username = post.account.username

        // Primary: extract hrefs from anchor tags via SwiftSoup.
        // Mastodon clients often split URLs across invisible/ellipsis spans, so
        // NSDataDetector on raw HTML text misses them. Parsing <a href> is reliable.
        var candidates: [String] = []
        if let doc = try? SwiftSoup.parse(content),
           let anchors = try? doc.select("a[href]") {
            for anchor in anchors {
                if let href = try? anchor.attr("href"), !href.isEmpty {
                    candidates.append(href)
                }
            }
        }

        // Fallback: NSDataDetector on raw HTML when no anchors are found.
        if candidates.isEmpty,
           let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
            let matches = detector.matches(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count))
            for match in matches {
                guard let range = Range(match.range, in: content) else { continue }
                candidates.append(String(content[range]))
            }
        }

        for candidate in candidates {
            guard let url = NeoDBURL.cleanItemUrl(candidate, username) else { continue }
            guard NeoDBURL.isNeoDBURL(url.absoluteString) else { continue }
            postPreviews.imagesDictionary[post.id] = url
            return url
        }

        return nil
    }

    private static func isNeoDBURL(_ urlString: String) -> Bool {
        var knownHosts = [
            knownServersUrl.eggplantUrl,
            knownServersUrl.neodbUrl,
            knownServersUrl.reviewDB,
            knownServersUrl.minreol,
            knownServersUrl.dbCasually,
            knownServersUrl.neodbKevga,
            knownServersUrl.fantastika,
            knownServersUrl.neodbDeadvey,
            knownServersUrl.neoDBbridge
        ]
        if let instanceHost = UserSettings.shared.instanceURL?.trimmingCharacters(in: .whitespacesAndNewlines) {
            knownHosts.append(instanceHost)
        }
        return knownHosts.contains(where: urlString.contains)
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

        // Remove leading slash and split path, then strip ~neodb~ prefix so
        // indices are consistent regardless of URL format.
        let path = components.path.dropFirst()
        var pathComponents = path.split(separator: "/").map(String.init)
        if pathComponents.first == neodbItemIdentifier {
            pathComponents = Array(pathComponents.dropFirst())
        }

        guard pathComponents.count >= 2 else { return nil }

        let type = pathComponents[0]
        var id = pathComponents[1]

        // Handle compound path types where the id is at index 2.
        let category: ItemCategory
        if type == "tv" && pathComponents.count >= 3 {
            switch pathComponents[1] {
            case "season":
                category = .tvSeason
                id = pathComponents[2]
            case "episode":
                category = .tvEpisode
                id = pathComponents[2]
            default:
                category = .tv
            }
        } else if type == "podcast" && pathComponents.count >= 3 && pathComponents[1] == "episode" {
            category = .podcast
            id = pathComponents[2]
        } else if type == "album" {
            category = .music
        } else if type == "performance" && pathComponents.count >= 3 && pathComponents[1] == "production" {
            category = .performanceProduction
            id = pathComponents[2]
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


