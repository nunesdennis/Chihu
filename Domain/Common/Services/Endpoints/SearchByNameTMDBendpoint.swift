//
//  SearchByNameTMDBendpoint.swift
//  Chihu
//
//  Created by Dennis Nunes on 09/09/24.
//

import Foundation

protocol TMDBRequestProtocol {
    var query: String { get }
    var page: Int { get }
    var includeAdult: Bool { get }
    var language: Language { get }
    var category: String { get }
}

struct SearchByNameTMDBendpoint: EndpointProtocol {
    // MARK: - Properties
    private var request: TMDBRequestProtocol
    
    var apiType: APItype {
        .tmdb
    }
    
    var endpoint: String {
        "/search/\(request.category)"
    }
    
    var queryItems: [URLQueryItem] {
        var query: [URLQueryItem] = []
        query.append(URLQueryItem(name: "query", value: request.query))
        query.append(URLQueryItem(name: "page", value: "\(request.page)"))
        query.append(URLQueryItem(name: "include_adult", value: "\(request.includeAdult)"))
        query.append(URLQueryItem(name: "language", value: "\(request.language.rawValue)"))
        
        return query
    }
    
    // MARK: - Initialization
    init(_ request: TMDBRequestProtocol) {
        self.request = request
    }
}
