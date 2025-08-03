//
//  CollectionsDataStore.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 11/01/25.
//  
//
import Foundation
import SwiftUI

enum CollectionsState {
    case loading
    case loaded
    case error(Error)
}

extension CollectionsState: Equatable {
    static func == (lhs: CollectionsState, rhs: CollectionsState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading),
             (.loaded, .loaded),
             (.error, .error):
            return true
        default:
            return false
        }
    }
}

final class CollectionsDataStore: ObservableObject {
    // Collection
    @Published var selectedCollection: CollectionSection?
    // Simple collection
    @Published var selectedCollectionModel: CollectionModel?
    // Common
    @Published var state: CollectionsState = .loading
    @Published var collectionSectionList: [CollectionSection] = []
    @Published var showNewCollection: Bool = false
    @Published var shouldShowAlert = false
    var alertType: CollectionAlertType?
    var alertMessage: LocalizedStringKey?
    var editCollection: CollectionSection?
    var pages: Int = 0
    var count: Int = 0
}
