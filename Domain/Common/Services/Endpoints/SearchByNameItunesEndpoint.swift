//
//  SearchByNameItunesEndpoint.swift
//  Chihu
//

import Foundation

protocol ItunesRequestProtocol {
    var query: String { get }
}

struct SearchByNameItunesEndpoint: EndpointProtocol {
    // MARK: - Properties

    private var request: ItunesRequestProtocol

    var apiType: APItype {
        .itunes
    }

    var endpoint: String {
        "/search"
    }

    var isTokenNeeded: Bool {
        false
    }

    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "term", value: request.query),
            URLQueryItem(name: "media", value: "music"),
            URLQueryItem(name: "entity", value: "album")
        ]
    }

    // MARK: - Initialization

    init(_ request: ItunesRequestProtocol) {
        self.request = request
    }
}
