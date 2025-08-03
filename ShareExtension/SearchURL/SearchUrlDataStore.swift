//
//  SearchUrlDataStore.swift
//  Chihu
//
//  Created by Dennis Nunes on 24/12/24.
//  
//
import Foundation

enum SearchUrlState {
    case loading
    case openReview
    case error(Error?)
}

final class SearchUrlDataStore: ObservableObject {
    @Published var state: SearchUrlState = .loading
    @Published var shelfItemsViewModel: ItemViewModel?
    var tryAgainCounter: [String: Int] = [:]
}
