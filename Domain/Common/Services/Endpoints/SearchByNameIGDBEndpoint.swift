//
//  SearchByNameIGDBEndpoint.swift
//  Chihu
//

import Foundation

protocol IGDBRequestProtocol {
    var query: String { get }
}

struct SearchByNameIGDBEndpoint: EndpointProtocol {
    // MARK: - Properties

    private var request: IGDBRequestProtocol

    var apiType: APItype {
        .igdb
    }

    var endpoint: String {
        "/v4/games"
    }

    var method: String {
        "POST"
    }

    var isTokenNeeded: Bool {
        false
    }

    var body: Data? {
        let query = "search \"\(request.query)\"; fields id,name,cover.url,summary,slug; limit 20;"
        return query.data(using: .utf8)
    }

    // MARK: - Initialization

    init(_ request: IGDBRequestProtocol) {
        self.request = request
    }
}
