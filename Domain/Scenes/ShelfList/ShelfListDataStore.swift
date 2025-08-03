//
//  ShelfListDataStore.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 31/08/24.
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
    @Published var selectedCategory: Int = 0
    @Published var selectedShelfType: Int = 0
    var lastError: Error?
    var selectedItem: ItemViewModel?
    var pages: Int = 1
    var count: Int = 0
}
