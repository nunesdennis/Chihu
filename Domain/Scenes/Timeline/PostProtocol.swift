//
//  PostProtocol.swift
//  Chihu
//
//  Created by Dennis Nunes on 15/04/25.
//

import Foundation

protocol AccountProtocol {
    var displayName: String? { get }
    var acct: String { get }
    var avatar: String { get }
}

protocol PostProtocol {
    var id: String { get }
    var sensitive: Bool { get }
    var repostValue: (any PostProtocol)? { get }
    var accountValue: (any AccountProtocol) { get }
    var spoilerText: String { get }
    var content: String? { get }
    var applicationValue: ApplicationProtocol? { get }
}

protocol ApplicationProtocol {
    /// The name of your application.
    var name: String { get }
}
