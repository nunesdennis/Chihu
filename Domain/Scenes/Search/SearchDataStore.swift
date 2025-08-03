//
//  SearchDataStore.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 01/09/24.
//  
//

import Foundation

enum SearchState {
    case firstLoad
    case canLoad
    case loading
    case noMorePages
    case tryByURL
    case error(Error?)
}

extension SearchState: Equatable {
    static func == (lhs: SearchState, rhs: SearchState) -> Bool {
        switch (lhs, rhs) {
        case (.firstLoad, .firstLoad),
             (.canLoad, .canLoad),
             (.loading, .loading),
             (.noMorePages, .noMorePages),
             (.tryByURL, .tryByURL),
             (.error, .error):
            return true
        default:
            return false
        }
    }
}

final class SearchDataStore: ObservableObject {
    @Published var state: SearchState = .firstLoad
    @Published var category: ItemCategory = .movie
    @Published var source: ItemSource = .tmdb
    @Published var shelfItemsViewModel: [ItemViewModel] = []
    @Published var showSelection: Bool = false
    @Published var showScanner: Bool = false
    @Published var isCategoryExpanded = false
    @Published var isSourceExpanded = false
    var tryAgainCounter: [String: Int] = [:]
    var lastURL: URL?
    var lastItemTapped: Card?
    var selectedItem: ItemViewModel?
    var pages: Int = 0
    var count: Int = 0
}
