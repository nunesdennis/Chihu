//
//  ShelfListDataStore.swift
//  Chihu
//
//
//

import Foundation
import SwiftUI

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
    
    var orderDescending: Bool = true
    var shouldOrderByDate: Bool = true
    var shouldOrderByRate: Bool = false
    var shouldOrderByName: Bool = false

    var sortedShelfItemsViewModel: [ItemViewModel] {
        var list = shelfItemsViewModel
        if shouldOrderByDate && !orderDescending { list.reverse() }
        if shouldOrderByRate {
            list.sort {
                if orderDescending {
                    ($0.rating ?? 0) > ($1.rating ?? 0)
                } else {
                    ($0.rating ?? 0) < ($1.rating ?? 0)
                }
            }
        }
        if shouldOrderByName {
            list.sort {
                if orderDescending {
                    $0.localizedTitle > $1.localizedTitle
                } else {
                    $0.localizedTitle < $1.localizedTitle
                }
            }
        }
        return list
    }
    
    init() {
        let defaultType = ShelfType(rawValue: UserSettings.shared.defaultShelfType)?.rawValueInt() ?? 0
        self.selectedShelfType = defaultType
    }
}
