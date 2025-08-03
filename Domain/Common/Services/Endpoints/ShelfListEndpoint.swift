//
//  ShelfListEndpoint.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 26/08/24.
//

import Foundation

protocol ShelfListRequestProtocol {
    var type: ShelfType { get }
    var page: Int { get }
    var category: ItemCategory.shelfAvailable? { get }
}

struct ShelfListEndpoint: EndpointProtocol {
    // MARK: - Properties
    private var request: ShelfListRequestProtocol
    
    var endpoint: String {
        "/api/me/shelf/\(request.type)"
    }
    
    var queryItems: [URLQueryItem] {
        var items = [URLQueryItem(name: "page", value: "\(request.page)")]
        
        if let category = request.category?.itemCategory?.rawValue {
            items.append(URLQueryItem(name: "category", value: category))
        }
        
        return items
    }
    
    // MARK: - Initialization
    init(_ request: ShelfListRequestProtocol) {
        self.request = request
    }
}
