//
//  ShelfItemCache.swift
//  Chihu
//

import Foundation
import SwiftData

@Model
final class ShelfItemCache {
    var cacheKey: String
    var sortIndex: Int

    var id: String
    var itemUUID: String
    var sourceRawValue: String
    var categoryRawValue: String
    var localizedTitle: String
    var localizedDescription: String?
    var neoDBrating: Double?
    var rating: Int?
    var reviewTitle: String?
    var reviewBody: String?
    var comment: String
    var posterString: String?
    var apiUrl: String?
    var shelfTypeRawValue: String?
    var instanceFetchIdString: String?
    var seasonCount: Int?
    var seasonNumber: Int?
    var seasonUuids: [String]?
    var parentUuid: String?
    var episodeCount: Int?
    var episodeNumber: Int?
    var episodeUuids: [String]?
    var externalResourceURLs: [String]?

    init(cacheKey: String, sortIndex: Int, viewModel: ItemViewModel) {
        self.cacheKey = cacheKey
        self.sortIndex = sortIndex
        self.id = viewModel.id
        self.itemUUID = viewModel.uuid
        self.sourceRawValue = viewModel.sourceRawValue
        self.categoryRawValue = viewModel.categoryRawValue
        self.localizedTitle = viewModel.localizedTitle
        self.localizedDescription = viewModel.localizedDescription
        self.neoDBrating = viewModel.neoDBrating
        self.rating = viewModel.rating
        self.reviewTitle = viewModel.reviewTitle
        self.reviewBody = viewModel.reviewBody
        self.comment = viewModel.comment
        self.posterString = viewModel.posterString
        self.apiUrl = viewModel.apiUrl
        self.shelfTypeRawValue = viewModel.shelfTypeRawValue
        self.instanceFetchIdString = viewModel.instanceFetchIdString
        self.seasonCount = viewModel.seasonCount
        self.seasonNumber = viewModel.seasonNumber
        self.seasonUuids = viewModel.seasonUuids
        self.parentUuid = viewModel.parentUuid
        self.episodeCount = viewModel.episodeCount
        self.episodeNumber = viewModel.episodeNumber
        self.episodeUuids = viewModel.episodeUuids
        self.externalResourceURLs = viewModel.externalResources?.map { $0.url.absoluteString }
    }

    func toItemViewModel() -> ItemViewModel {
        let externalResources = externalResourceURLs?
            .compactMap { URL(string: $0) }
            .map { ItemExternalResourceSchema(url: $0) }

        return ItemViewModel(
            id: id,
            uuid: itemUUID,
            source: sourceRawValue,
            category: categoryRawValue,
            localizedTitle: localizedTitle,
            localizedDescription: localizedDescription,
            neoDBrating: neoDBrating,
            rating: rating,
            reviewTitle: reviewTitle,
            reviewBody: reviewBody,
            comment: comment,
            poster: posterString,
            apiUrl: apiUrl,
            shelfType: shelfTypeRawValue,
            instanceFetchId: instanceFetchIdString,
            seasonCount: seasonCount,
            seasonNumber: seasonNumber,
            seasonUuids: seasonUuids,
            parentUuid: parentUuid,
            episodeCount: episodeCount,
            episodeNumber: episodeNumber,
            episodeUuids: episodeUuids,
            externalResources: externalResources
        )
    }
}
