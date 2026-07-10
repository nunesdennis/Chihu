//
//  ShelfListDataStore.swift
//  Chihu
//
//  
//

import Foundation
import SwiftUI
import SwiftData

enum ShelfState {
    case firstLoad
    case canLoad
    case loading
    case noMorePages
    case error
}

final class ShelfListDataStore: ObservableObject {
    @Published var state: ShelfState = .firstLoad
    @Published var shelfItemsViewModel: [ItemViewModel] = []
    @Published var showSelection: Bool = false
    @Published var showCollectionsView: Bool = false
    @Published var selectedCategory: Int = 0
    @Published var selectedShelfType: Int = 0

    var collectionDataStore = CollectionsDataStore()

    var lastError: Error?
    var selectedItem: ItemViewModel?
    var pages: Int = 1
    var count: Int = 0
    var currentCacheKey: String = ""

    var modelContext: ModelContext?

    init() {
        let defaultType = ShelfType(rawValue: UserSettings.shared.defaultShelfType)?.rawValueInt() ?? 0
        self.selectedShelfType = defaultType
    }

    func loadFromCache(cacheKey: String) -> [ItemViewModel] {
        guard let context = modelContext else { return [] }
        let predicate = #Predicate<ShelfItemCache> { $0.cacheKey == cacheKey }
        let descriptor = FetchDescriptor<ShelfItemCache>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.sortIndex)]
        )
        let cached = (try? context.fetch(descriptor)) ?? []
        return cached.map { $0.toItemViewModel() }
    }

    func saveToCache(items: [ItemViewModel], cacheKey: String, replacing: Bool) {
        guard let context = modelContext else { return }
        let predicate = #Predicate<ShelfItemCache> { $0.cacheKey == cacheKey }
        if replacing {
            try? context.delete(model: ShelfItemCache.self, where: predicate)
            for (index, item) in items.enumerated() {
                context.insert(ShelfItemCache(cacheKey: cacheKey, sortIndex: index, viewModel: item))
            }
        } else {
            let currentCount = (try? context.fetchCount(FetchDescriptor<ShelfItemCache>(predicate: predicate))) ?? 0
            for (index, item) in items.enumerated() {
                context.insert(ShelfItemCache(cacheKey: cacheKey, sortIndex: currentCount + index, viewModel: item))
            }
        }
        try? context.save()
    }
}
