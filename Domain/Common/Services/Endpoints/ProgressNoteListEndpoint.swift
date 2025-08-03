//
//  ProgressNoteListEndpoint.swift
//  Chihu
//
//  Created by Dennis Nunes on 14/02/25.
//

import Foundation

protocol ProgressNoteRequestProtocol {
    var method: HTTPMethod { get }
    var body: Encodable? { get }
    var noteUuid: String { get }
    var itemUuid: String { get }
    var page: Int { get }
}

extension ProgressNoteRequestProtocol {
    var body: Encodable? { nil }
    var noteUuid: String { "" }
    var itemUuid: String { "" }
    var page: Int { 1 }
}

struct ProgressNoteListEndpoint: EndpointProtocol {
    // MARK: - Properties
    private var request: ProgressNoteRequestProtocol
    
    var method: String {
        request.method.rawValue
    }
    
    var body: Data? {
        if let body = request.body {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(body)
        } else {
            return nil
        }
    }
    
    var endpoint: String {
        switch request.method {
        case .get:
            return "/api/me/note/item/\(request.itemUuid)/"
        case .put:
            return "/api/me/note/\(request.noteUuid)"
        case .post:
            return "/api/me/note/item/\(request.itemUuid)/"
        case .delete:
            return "/api/me/note/\(request.noteUuid)"
        }
    }
    
    var queryItems: [URLQueryItem] {
        if request.method == .get {
            return [URLQueryItem(name: "page", value: "\(request.page)")]
        } else {
            return []
        }
    }
    
    // MARK: - Initialization
    init(request: ProgressNoteRequestProtocol) {
        self.request = request
    }
}
