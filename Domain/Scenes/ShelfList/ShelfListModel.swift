//
//  ShelfListModel.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 31/08/24.
//  
//

import Foundation
import SwiftUI

enum ShelfType: String, Codable, CaseIterable {
    case complete
    case wishlist
    case progress
    case dropped
    case none
    
    func shelfTypeButtonName() -> LocalizedStringKey {
        switch self {
        case .complete: return "Completed"
        case .wishlist: return "Wishlist"
        case .progress: return "Progress"
        case .dropped: return "Dropped"
        case .none: return "None"
        }
    }
    
    func rawValueInt() -> Int {
        switch self {
        case .complete, .none:
            return .zero
        case .wishlist:
            return 1
        case .progress:
            return 2
        case .dropped:
            return 3
        }
    }
}

enum ShelfList {
    enum Load {
        struct Request: ShelfListRequestProtocol {
            var type: ShelfType
            var page: Int
            var category: ItemCategory.shelfAvailable?
        }
        
        struct Response: Decodable {
            let shelf: Shelf
        }
        
        struct ViewModel {
            let shelfItemsViewModel: [ItemViewModel]
            let pages: Int
            let count: Int
            
            init(shelf: Shelf) {
                self.shelfItemsViewModel = shelf.data.map {
                    ItemViewModelBuilder.create(from: $0)
                }
                self.pages = shelf.pages
                self.count = shelf.count
            }
        }
    }
}
