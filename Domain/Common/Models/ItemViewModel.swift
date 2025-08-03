//
//  ShelfItemViewModel.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 01/09/24.
//

import Foundation

enum posterSizeIMDB: String {
    case w92
    case w154
    case w185
    case w342
    case w500
    case w780
    case original
}

struct ItemViewModel: Equatable, Hashable {
    var index: Int?
    var id: String
    var uuid: String
    var source: ItemSource {
        ItemSource.from(string: sourceRawValue)
    }
    var sourceRawValue: String
    
    var category: ItemCategory {
        ItemCategory(rawValue: categoryRawValue) ?? .unknown
    }
    var categoryRawValue: String
    
    var localizedTitle: String
    var localizedDescription: String?
    var neoDBrating: Double?
    var rating: Int?
    var reviewTitle: String?
    var reviewBody: String?
    var comment: String = String()
    
    var poster: URL? {
        if let posterString {
            return URL(string: posterString)
        }
        
        return nil
    }
    var posterString: String?
    
    var apiUrl: String?
    var shelfType: ShelfType? {
        if let shelfTypeRawValue {
            return ShelfType(rawValue: shelfTypeRawValue)
        }
        
        return nil
    }
    var shelfTypeRawValue: String?
    
    var instanceFetchId: URL? {
        if let instanceFetchIdString {
            return URL(string: instanceFetchIdString)
        }
        
        return nil
    }
    var instanceFetchIdString: String?
    
    var externalResources: [ItemExternalResourceSchema]?
    
    // Additional properties specific to TV Show
    var seasonCount: Int?
    var seasonNumber: Int?
    var seasonUuids: [String]?
    
    var episodeCount: Int?
    var episodeNumber: Int?
    var episodeUuids: [String]?
    
    init(id: String,
         uuid: String,
         source: String,
         category: String,
         localizedTitle: String,
         localizedDescription: String? = nil,
         neoDBrating: Double? = nil,
         rating: Int? = nil,
         reviewTitle: String? = nil,
         reviewBody: String? = nil,
         comment: String = String(),
         poster: String? = nil,
         apiUrl: String? = nil,
         shelfType: String? = nil,
         instanceFetchId: String? = nil,
         seasonCount: Int? = nil,
         seasonNumber: Int? = nil,
         seasonUuids: [String]? = nil,
         episodeCount: Int? = nil,
         episodeNumber: Int? = nil,
         episodeUuids: [String]? = nil,
         externalResources: [ItemExternalResourceSchema]? = nil) {
        self.id = id
        self.uuid = uuid
        self.sourceRawValue = source
        self.categoryRawValue = category
        self.localizedTitle = localizedTitle
        self.localizedDescription = localizedDescription
        self.neoDBrating = neoDBrating
        self.rating = rating
        self.reviewTitle = reviewTitle
        self.reviewBody = reviewBody
        self.comment = comment
        self.posterString = poster
        self.apiUrl = apiUrl
        self.shelfTypeRawValue = shelfType
        self.instanceFetchIdString = instanceFetchId
        self.seasonCount = seasonCount
        self.seasonNumber = seasonNumber
        self.seasonUuids = seasonUuids
        self.episodeCount = episodeCount
        self.episodeNumber = episodeNumber
        self.episodeUuids = episodeUuids
        self.externalResources = externalResources
    }
}

class ItemViewModelBuilder {
    static func create(from item: any ItemProtocol) -> ItemViewModel {
        let localizedTitle = getPreferredLanguage(itemsText: item.localizedTitle ?? []) ??
        item.localizedTitle?.first?.text ?? "Name not available"
        
        let localizedDescription = getPreferredLanguage(itemsText: item.localizedDescription ?? []) ??
        item.localizedDescription?.first?.text
        
        var externalResources = item.externalResources ?? []
        if let baseUrlString = UserSettings.shared.instanceURL?.trimmingCharacters(in:.whitespacesAndNewlines),
           let serverUrl = URL(string: baseUrlString + item.url) {
            
            let baseUrlName = UrlCleaner.keepSiteName(from: serverUrl)
            
            for (index, externalResource) in (item.externalResources ?? []).enumerated() {
                let urlname = UrlCleaner.keepSiteName(from: externalResource.url)
                if urlname == baseUrlName {
                    externalResources.remove(at: index)
                }
            }
        
            externalResources.insert(ItemExternalResourceSchema(url: serverUrl), at: 0)
        }
        
        // Additional properties specific to TV Show
        let tvItem = item as? TVShowSchema
        
        return .init(id: item.id,
                     uuid: item.uuid,
                     source: "Server",
                     category: item.category.rawValue,
                     localizedTitle: localizedTitle,
                     localizedDescription: localizedDescription,
                     neoDBrating: item.rating,
                     poster: item.coverImageUrl?.absoluteString,
                     apiUrl: item.apiUrl,
                     seasonCount: tvItem?.seasonCount,
                     seasonNumber: tvItem?.seasonNumber,
                     seasonUuids: tvItem?.seasonUuids ?? [],
                     episodeCount: tvItem?.episodeCount,
                     episodeNumber: tvItem?.episodeNumber,
                     episodeUuids: tvItem?.episodeUuids,
                     externalResources: externalResources)
    }
    
    static func create(from shelfItem: ShelfItem) -> ItemViewModel {
        var item = create(from: shelfItem.item)
        item.shelfTypeRawValue = shelfItem.shelfType.rawValue
        item.rating = shelfItem.ratingGrade
        item.comment = shelfItem.commentText ?? ""
        item.reviewTitle = shelfItem.title
        item.reviewBody = shelfItem.body
        
        return item
    }
    
    static func create(from shelfItemDetailsGoogleBooks: ShelfItemsDetailsGoogleBooks, category: String) -> ItemViewModel {
        let localizedTitle = shelfItemDetailsGoogleBooks.volumeInfo.title
        let localizedDescription = shelfItemDetailsGoogleBooks.volumeInfo.description
        let posterLink = shelfItemDetailsGoogleBooks.volumeInfo.imageLinks?.thumbnail?.replacingOccurrences(of: "http://", with: "https://") ?? String()
        let previewLink = shelfItemDetailsGoogleBooks.volumeInfo.previewLink.replacingOccurrences(of: "http://", with: "https://")
        
        return .init(id: shelfItemDetailsGoogleBooks.id,
                     uuid: shelfItemDetailsGoogleBooks.id,
                     source: "Google Books",
                     category: (ItemCategory(rawValue: category) ?? .book).rawValue,
                     localizedTitle: localizedTitle,
                     localizedDescription: localizedDescription,
                     poster: posterLink,
                     shelfType: ShelfType.none.rawValue,
                     instanceFetchId: previewLink)
    }
    
    static func create(from shelfItemDetailsTMDB: ShelfItemsDetailsTMDB, category: String) -> ItemViewModel {
        let localizedTitle = shelfItemDetailsTMDB.title ?? shelfItemDetailsTMDB.name ?? shelfItemDetailsTMDB.originalName ?? "Name not available"
        let localizedDescription = shelfItemDetailsTMDB.description
        let poster = "https://image.tmdb.org/t/p/\(posterSizeIMDB.w342.rawValue)" + (shelfItemDetailsTMDB.poster ?? "")
        let instanceFetchId = "https://www.themoviedb.org/\(category)/\(shelfItemDetailsTMDB.id)"
        
        return .init(id: "\(shelfItemDetailsTMDB.id)",
                     uuid: "\(shelfItemDetailsTMDB.id)",
                     source: "TMDB",
                     category: (ItemCategory(rawValue: category) ?? .unknown).rawValue,
                     localizedTitle: localizedTitle,
                     localizedDescription: localizedDescription,
                     poster: poster,
                     shelfType: ShelfType.none.rawValue,
                     instanceFetchId: instanceFetchId)
    }
    
    static func create(from shelfItemsDetailsPI: ShelfItemsDetailsPodcastIndex) -> ItemViewModel {
        let localizedTitle = shelfItemsDetailsPI.title
        let localizedDescription = shelfItemsDetailsPI.description
        
        var poster: String?
        if let image = shelfItemsDetailsPI.image {
            poster = image
        } else if let artwork = shelfItemsDetailsPI.artwork {
            poster = artwork
        }
        let instanceFetchId = shelfItemsDetailsPI.rssUrl
        
        return .init(id: "\(shelfItemsDetailsPI.id)",
                     uuid: "\(shelfItemsDetailsPI.id)",
                     source: "Podcast Index",
                     category: ItemCategory.podcast.rawValue,
                     localizedTitle: localizedTitle,
                     localizedDescription: localizedDescription,
                     poster: poster,
                     shelfType: ShelfType.none.rawValue,
                     instanceFetchId: instanceFetchId)
    }
    
    private static func getPreferredLanguage(itemsText: [LocalizedTitleSchema]) -> String? {
        let language = UserSettings.shared.language
        var languageShort: String?
        var english: String?
        let englishDefaultLanguage: String = Language.en(region: .standard(code: "US")).rawValueShort
        
        return itemsText.compactMap { itemText in
            if let receivedLang = Language.from(itemText.lang), receivedLang == language {
                return itemText.text
            } else if (itemText.lang.caseInsensitiveCompare(language.rawValue) == .orderedSame) &&
                !itemText.text.isEmpty {
                return itemText.text
            } else if (itemText.lang.caseInsensitiveCompare(language.rawValueShort) == .orderedSame) &&
                        !itemText.text.isEmpty {
                languageShort = itemText.text
            } else if (itemText.lang.caseInsensitiveCompare(englishDefaultLanguage) == .orderedSame) && !itemText.text.isEmpty {
                english = itemText.text
            }
            return nil
        }.first ?? languageShort ?? english
    }
    
    static func update(oldItem: ItemViewModel, withItem item: ItemViewModel) -> ItemViewModel {
        var newItem = oldItem
        
        newItem.localizedTitle = item.localizedTitle
        newItem.localizedDescription = item.localizedDescription ?? newItem.localizedDescription
        newItem.rating = item.rating ?? newItem.rating
        newItem.reviewTitle = item.reviewTitle ?? newItem.reviewTitle
        newItem.reviewBody = item.reviewBody ?? newItem.reviewBody
        if newItem.comment.isEmpty {
            newItem.comment = item.comment
        }
        newItem.posterString = item.posterString ?? newItem.posterString
        newItem.apiUrl = item.apiUrl ?? newItem.apiUrl
        newItem.shelfTypeRawValue = item.shelfTypeRawValue ?? newItem.shelfTypeRawValue
        newItem.instanceFetchIdString = item.instanceFetchIdString ?? newItem.instanceFetchIdString
        newItem.seasonCount = item.seasonCount ?? newItem.seasonCount
        newItem.seasonNumber = item.seasonNumber ?? newItem.seasonNumber
        newItem.seasonUuids = item.seasonUuids ?? newItem.seasonUuids
        newItem.episodeCount = item.episodeCount ?? newItem.episodeCount
        newItem.episodeNumber = item.episodeNumber ?? newItem.episodeNumber
        newItem.episodeUuids = item.episodeUuids ?? newItem.episodeUuids
        
        return newItem
    }
}
