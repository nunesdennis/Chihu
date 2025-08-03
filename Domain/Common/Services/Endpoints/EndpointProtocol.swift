//
//  EndpointProtocol.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 25/08/24.
//

import Foundation

enum APItype {
    case neoDB
    case tmdb
    case googleBooks
    case podcastIndex
}

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

protocol EndpointProtocol {
    var apiType: APItype { get }
    var baseURL: String { get }
    var endpoint: String { get }
    var body: Data? { get }
    var queryItems: [URLQueryItem] { get }
    var isTokenNeeded: Bool { get }
    var header: [String: String] { get }
    var method: String { get }
    var url: URL? { get }
}

extension EndpointProtocol {
    var apiType: APItype {
        .neoDB
    }
    
    var baseURL: String {
        switch apiType {
        case .neoDB:
            return UserSettings.shared.instanceURL ?? ""
        case .tmdb:
            return "https://api.themoviedb.org/3"
        case .googleBooks:
            return "https://www.googleapis.com/books/v1"
        case .podcastIndex:
            return "https://api.podcastindex.org/api/1.0"
        }
    }
    
    var isTokenNeeded: Bool {
        true
    }
    
    var method: String {
        "GET"
    }
    
    var body: Data? {
        nil
    }
    
    var header: [String: String] {
        [
            "Accept": "application/json",
            "Content-Type": " application/json"
        ]
    }
    
    var queryItems: [URLQueryItem] {
        []
    }
    
    var url: URL? {
        let urlString = (baseURL + endpoint).trimmingCharacters(in: .whitespacesAndNewlines)
        var components = URLComponents(string: urlString)
        components?.queryItems = queryItems
        
        return components?.url
    }
}
