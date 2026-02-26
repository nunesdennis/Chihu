//
//  ItemViewModelBuilderTests.swift
//  ChihuTests
//
//

import XCTest
@testable import Chihu

final class ItemViewModelBuilderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Make language deterministic for tests
        UserSettings.shared.language = .en(region: .standard(code: "US"))
    }
    
    override func tearDown() {
        super.tearDown()
        // Reset potentially mutated shared state
        UserSettings.shared.instanceURL = nil
    }
    
    // MARK: - create(from: any ItemProtocol)
    
    func testCreateFromItemUsesPreferredLocalizedTitleAndDescription() {
        let item: ItemSchema = loadJSON("Item_movie_localized")
        
        let viewModel = ItemViewModelBuilder.create(from: item)
        
        XCTAssertEqual(viewModel.id, item.id)
        XCTAssertEqual(viewModel.uuid, item.uuid)
        XCTAssertEqual(viewModel.category, item.category)
        XCTAssertEqual(viewModel.localizedTitle, "English Title")
        XCTAssertEqual(viewModel.localizedDescription, "English Description")
        XCTAssertEqual(viewModel.neoDBrating, item.rating)
        XCTAssertEqual(viewModel.apiUrl, item.apiUrl)
        XCTAssertEqual(viewModel.posterString, item.coverImageUrl?.absoluteString)
        XCTAssertEqual(viewModel.source, .instance)
    }
    
    func testCreateFromItemBuildsServerExternalResourceAndRemovesDuplicateDomain() {
        let baseInstance = "https://myinstance.example.com"
        UserSettings.shared.instanceURL = baseInstance
        
        let item: ItemSchema = loadJSON("Item_with_external_resources")
        
        let viewModel = ItemViewModelBuilder.create(from: item)
        let resources = viewModel.externalResources
        
        XCTAssertNotNil(resources)
        XCTAssertEqual(resources?.count, 2)
        
        let expectedServerURL = URL(string: baseInstance + item.url)
        XCTAssertEqual(resources?.first?.url, expectedServerURL)
        
        // Ensure the resource with same base domain as instance was removed
        XCTAssertEqual(resources?.last?.url.host, "another.com")
    }
    
    func testCreateFromItemKeepsExternalResourcesWhenInstanceURLIsNil() {
        UserSettings.shared.instanceURL = nil
        
        let item: ItemSchema = loadJSON("Item_with_external_resources")
        let external = item.externalResources

        let viewModel = ItemViewModelBuilder.create(from: item)
        
        XCTAssertEqual(viewModel.externalResources, external)
    }
    
    func testCreateFromTVShowItemPopulatesTVSpecificFields() {
        let tvItem: TVShowSchema = loadJSON("TVShow_item")
        
        let viewModel = ItemViewModelBuilder.create(from: tvItem)
        
        XCTAssertEqual(viewModel.seasonCount, tvItem.seasonCount)
        XCTAssertEqual(viewModel.seasonNumber, tvItem.seasonNumber)
        XCTAssertEqual(viewModel.seasonUuids, tvItem.seasonUuids)
        XCTAssertEqual(viewModel.parentUuid, tvItem.parentUuid)
        XCTAssertEqual(viewModel.episodeCount, tvItem.episodeCount)
        XCTAssertEqual(viewModel.episodeNumber, tvItem.episodeNumber)
        XCTAssertEqual(viewModel.episodeUuids, tvItem.episodeUuids)
    }
    
    // MARK: - create(from: ShelfItem)
    
    func testCreateFromShelfItemOverridesShelfSpecificFields() {
        let shelfItem: ShelfItem = loadJSON("ShelfItem_book")
        
        let viewModel = ItemViewModelBuilder.create(from: shelfItem)
        
        XCTAssertEqual(viewModel.shelfType, .complete)
        XCTAssertEqual(viewModel.rating, shelfItem.ratingGrade)
        XCTAssertEqual(viewModel.comment, shelfItem.commentText)
        XCTAssertEqual(viewModel.reviewTitle, shelfItem.title)
        XCTAssertEqual(viewModel.reviewBody, shelfItem.body)
    }
    
    // MARK: - create(from: Google Books)
    
    func testCreateFromGoogleBooksBuildsExpectedViewModel() {
        let details: ShelfItemsDetailsGoogleBooks = loadJSON("ShelfItemsDetailsGoogleBooks")
        let volumeInfo = details.volumeInfo
        
        let viewModel = ItemViewModelBuilder.create(from: details, category: "book")
        
        XCTAssertEqual(viewModel.id, details.id)
        XCTAssertEqual(viewModel.uuid, details.id)
        XCTAssertEqual(viewModel.source, .googleBooks)
        XCTAssertEqual(viewModel.category, .book)
        XCTAssertEqual(viewModel.localizedTitle, volumeInfo.title)
        XCTAssertEqual(viewModel.localizedDescription, volumeInfo.description)
        XCTAssertEqual(viewModel.posterString, "https://image.link/thumb.jpg")
        XCTAssertEqual(viewModel.shelfType, ShelfType.none)
        XCTAssertEqual(viewModel.instanceFetchIdString, "https://preview.link")
    }
    
    // MARK: - create(from: TMDB)
    
    func testCreateFromTMDBBuildsExpectedViewModel() {
        let details: ShelfItemsDetailsTMDB = loadJSON("ShelfItemsDetailsTMDB")
        
        let viewModel = ItemViewModelBuilder.create(from: details, category: "movie")
        
        XCTAssertEqual(viewModel.id, "\(details.id)")
        XCTAssertEqual(viewModel.uuid, "\(details.id)")
        XCTAssertEqual(viewModel.source, .tmdb)
        XCTAssertEqual(viewModel.category, .movie)
        XCTAssertEqual(viewModel.localizedTitle, "TMDB Name")
        XCTAssertEqual(viewModel.localizedDescription, details.description)
        XCTAssertEqual(viewModel.posterString, "https://image.tmdb.org/t/p/w342/poster.jpg")
        XCTAssertEqual(viewModel.shelfType, ShelfType.none)
        XCTAssertEqual(viewModel.instanceFetchIdString, "https://www.themoviedb.org/movie/42")
    }
    
    // MARK: - create(from: Podcast Index)
    
    func testCreateFromPodcastIndexPrefersImageOverArtwork() {
        let details: ShelfItemsDetailsPodcastIndex = loadJSON("ShelfItemsDetailsPodcastIndex_image")
        
        let viewModel = ItemViewModelBuilder.create(from: details)
        
        XCTAssertEqual(viewModel.id, "\(details.id)")
        XCTAssertEqual(viewModel.uuid, "\(details.id)")
        XCTAssertEqual(viewModel.source, .podcastIndex)
        XCTAssertEqual(viewModel.category, .podcast)
        XCTAssertEqual(viewModel.localizedTitle, details.title)
        XCTAssertEqual(viewModel.localizedDescription, details.description)
        XCTAssertEqual(viewModel.posterString, details.image)
        XCTAssertEqual(viewModel.shelfType, ShelfType.none)
        XCTAssertEqual(viewModel.instanceFetchIdString, details.rssUrl)
    }
    
    func testCreateFromPodcastIndexUsesArtworkWhenImageIsNil() {
        let details: ShelfItemsDetailsPodcastIndex = loadJSON("ShelfItemsDetailsPodcastIndex_artwork")
        
        let viewModel = ItemViewModelBuilder.create(from: details)
        
        XCTAssertEqual(viewModel.posterString, details.artwork)
    }
    
    // MARK: - update(oldItem:withItem:)
    
    func testUpdateMergesNonNilFieldsAndPreservesExistingCommentWhenNotEmpty() {
        var oldItem = ItemViewModel(
            id: "1",
            uuid: "uuid-1",
            source: "Server",
            category: ItemCategory.movie.rawValue,
            localizedTitle: "Old Title"
        )
        oldItem.localizedDescription = "Old Description"
        oldItem.rating = 3
        oldItem.reviewTitle = "Old Review Title"
        oldItem.reviewBody = "Old Review Body"
        oldItem.comment = "Existing Comment"
        oldItem.posterString = "https://old.poster"
        oldItem.apiUrl = "https://old.api"
        oldItem.shelfTypeRawValue = ShelfType.progress.rawValue
        oldItem.instanceFetchIdString = "https://old.instance"
        oldItem.seasonCount = 1
        oldItem.seasonNumber = 1
        oldItem.seasonUuids = ["old-season"]
        oldItem.parentUuid = "old-parent"
        oldItem.episodeCount = 10
        oldItem.episodeNumber = 1
        oldItem.episodeUuids = ["old-episode"]
        
        var newItem = ItemViewModel(
            id: "1",
            uuid: "uuid-1",
            source: "Server",
            category: ItemCategory.movie.rawValue,
            localizedTitle: "New Title"
        )
        newItem.localizedDescription = "New Description"
        newItem.rating = 5
        newItem.reviewTitle = "New Review Title"
        newItem.reviewBody = "New Review Body"
        newItem.comment = "New Comment"
        newItem.posterString = "https://new.poster"
        newItem.apiUrl = "https://new.api"
        newItem.shelfTypeRawValue = ShelfType.complete.rawValue
        newItem.instanceFetchIdString = "https://new.instance"
        newItem.seasonCount = 2
        newItem.seasonNumber = 2
        newItem.seasonUuids = ["new-season"]
        newItem.parentUuid = "new-parent"
        newItem.episodeCount = 20
        newItem.episodeNumber = 2
        newItem.episodeUuids = ["new-episode"]
        
        let updated = ItemViewModelBuilder.update(oldItem: oldItem, withItem: newItem)
        
        XCTAssertEqual(updated.localizedTitle, "New Title")
        XCTAssertEqual(updated.localizedDescription, "New Description")
        XCTAssertEqual(updated.rating, 5)
        XCTAssertEqual(updated.reviewTitle, "New Review Title")
        XCTAssertEqual(updated.reviewBody, "New Review Body")
        // Comment should remain the old non-empty value
        XCTAssertEqual(updated.comment, "Existing Comment")
        XCTAssertEqual(updated.posterString, "https://new.poster")
        XCTAssertEqual(updated.apiUrl, "https://new.api")
        XCTAssertEqual(updated.shelfTypeRawValue, ShelfType.complete.rawValue)
        XCTAssertEqual(updated.instanceFetchIdString, "https://new.instance")
        XCTAssertEqual(updated.seasonCount, 2)
        XCTAssertEqual(updated.seasonNumber, 2)
        XCTAssertEqual(updated.seasonUuids, ["new-season"])
        XCTAssertEqual(updated.parentUuid, "new-parent")
        XCTAssertEqual(updated.episodeCount, 20)
        XCTAssertEqual(updated.episodeNumber, 2)
        XCTAssertEqual(updated.episodeUuids, ["new-episode"])
    }
    
    func testUpdateUsesNewCommentWhenOldCommentIsEmpty() {
        var oldItem = ItemViewModel(
            id: "1",
            uuid: "uuid-1",
            source: "Server",
            category: ItemCategory.movie.rawValue,
            localizedTitle: "Old Title"
        )
        oldItem.comment = ""
        
        var newItem = ItemViewModel(
            id: "1",
            uuid: "uuid-1",
            source: "Server",
            category: ItemCategory.movie.rawValue,
            localizedTitle: "New Title"
        )
        newItem.comment = "New Comment"
        
        let updated = ItemViewModelBuilder.update(oldItem: oldItem, withItem: newItem)
        
        XCTAssertEqual(updated.comment, "New Comment")
    }

    // MARK: - Helpers
    
    private func loadJSON<T: Decodable>(_ filename: String, as type: T.Type = T.self) -> T {
        let bundle = Bundle(for: ItemViewModelBuilderTests.self)
        let url =
        bundle.url(forResource: filename, withExtension: "json", subdirectory: "Mocks") ??
        bundle.url(forResource: filename, withExtension: "json")

        guard let url else {
            fatalError("Missing file: Mocks/\(filename).json (or \(filename).json at bundle root)")
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Failed to decode \(filename).json: \(error)")
        }
    }
}

