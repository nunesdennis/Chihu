//
//  SearchModel.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 01/09/24.
//  
//

import Foundation

enum SearchByName {
    enum Load {
        struct Request: SearchByNameRequestProtocol {
            let query: String
            var page: Int = 1
            var category: String?
        }
        
        struct Response {
            let catalog: Catalog
        }
        
        struct ViewModel {
            let shelfItemsViewModel: [ItemViewModel]
            let pages: Int
            let count: Int
            
            init(catalog: Catalog) {
                self.shelfItemsViewModel = catalog.data.map {
                    ItemViewModelBuilder.create(from: $0)
                }
                self.pages = catalog.pages
                self.count = catalog.count
            }
        }
    }
}

enum SearchByURL {
    enum Load {
        struct Request: SearchByURLRequestProtocol {
            let url: URL
            let itemClass: any ItemProtocol.Type
        }
        
        struct Response {
            let shelfItemDetails: any ItemProtocol
        }
        
        struct ViewModel {
            let shelfItemsViewModel: ItemViewModel
            
            init(shelfItemDetails: any ItemProtocol) {
                self.shelfItemsViewModel = ItemViewModelBuilder.create(from: shelfItemDetails)
            }
        }
    }
}

enum SearchByNameTMDB {
    enum Load {
        struct Request: TMDBRequestProtocol {
            let query: String
            var page: Int = 1
            var includeAdult: Bool = false
            var language = UserSettings.shared.language
            var category: String
        }
        
        struct Response {
            let shelf: ShelfTMDB
            let category: String
        }
        
        struct ViewModel {
            let shelfItemsViewModel: [ItemViewModel]
            let pages: Int
            let count: Int
            
            init(shelf: ShelfTMDB, category: String) {
                self.shelfItemsViewModel = shelf.shelfItemsDetails.map {
                    ItemViewModelBuilder.create(from: $0, category: category)
                }
                self.pages = shelf.pages
                self.count = shelf.count
            }
        }
    }
}

enum SearchByNameGoogleBooks {
    enum Load {
        struct Request: GoogleBooksRequestProtocol {
            let query: String
            var category: String
        }
        
        struct Response {
            let shelf: ShelfGoogleBooks
            let category: String
        }
        
        struct ViewModel {
            let shelfItemsViewModel: [ItemViewModel]
            let pages: Int
            let count: Int
            
            init(shelf: ShelfGoogleBooks, category: String) {
                self.shelfItemsViewModel = shelf.shelfItemsDetails.map {
                    ItemViewModelBuilder.create(from: $0, category: category)
                }
                self.pages = 1
                self.count = shelf.count
            }
        }
    }
}

enum SearchByNamePI {
    enum Load {
        struct Request: PodcastIndexRequestProtocol {
            let query: String
        }
        
        struct Response {
            let shelf: ShelfPodcastIndexList
        }
        
        struct ViewModel {
            let shelfItemsViewModel: [ItemViewModel]
            let pages: Int
            let count: Int
            
            init(shelf: ShelfPodcastIndexList) {
                self.shelfItemsViewModel = shelf.shelfItemsDetails.map {
                    ItemViewModelBuilder.create(from: $0)
                }
                self.pages = 1
                self.count = shelf.count
            }
        }
    }
}
