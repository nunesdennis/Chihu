//
//  CollectionSection.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 16/01/25.
//

import Foundation

final class CollectionSection: Identifiable {
    var items: [CollectionItemData]
    var pages: Int = 0
    var currentPage: Int = 0
    var count: Int = 0
    var id: String {
        uuid
    }
    
    let uuid: String
    let title: String
    let description: String?
    
    init(isSelected: Bool, uuid: String, title: String, description: String?) {
        self.uuid = uuid
        self.title = title
        self.description = description
        self.items = []
    }
}

extension [CollectionItemData] {
    func asShelfItems() -> [ItemViewModel] {
        self.map {
            ItemViewModelBuilder.create(from: $0.item)
        }
    }
}
