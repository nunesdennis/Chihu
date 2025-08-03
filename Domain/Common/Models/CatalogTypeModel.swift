//
//  CatalogTypeModel.swift
//  Chihu
//
//  Created by Dennis Nunes on 24/01/25.
//

import Foundation

enum CatalogTypeModel {
    enum Load {
        struct Request: CatalogTypeRequestProtocol {
            let category: ItemCategory
            let uuid: String
        }
        
        struct Response {
            let catalogItem: ItemSchema
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
