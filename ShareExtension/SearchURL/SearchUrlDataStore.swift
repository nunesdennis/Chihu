//
//  SearchUrlDataStore.swift
//  Chihu
//
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
