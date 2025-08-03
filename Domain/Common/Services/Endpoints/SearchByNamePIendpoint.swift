//
//  SearchByNamePIendpoint.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 31/12/24.
//

import Foundation

protocol PodcastIndexRequestProtocol {
    var query: String { get }
}

struct SearchByNamePIendpoint: EndpointProtocol {
    // MARK: - Properties
    private var request: PodcastIndexRequestProtocol
    
    var apiType: APItype {
        .podcastIndex
    }
    
    var endpoint: String {
        "/search/byterm"
    }
    
    var header: [String : String] {
        [
            "SuperPodcastPlayer/1.8" : "User-Agent"
        ]
    }
    
    var queryItems: [URLQueryItem] {
        var query: [URLQueryItem] = []
        query.append(URLQueryItem(name: "q", value: request.query))
        
        return query
    }
    
    // MARK: - Initialization
    init(_ request: PodcastIndexRequestProtocol) {
        self.request = request
    }
}
