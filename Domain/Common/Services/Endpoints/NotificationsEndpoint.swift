//
//  NotificationsEndpoint.swift
//  Chihu
//

import Foundation
import TootSDK

protocol NotificationsRequestProtocol {
    var pageInfo: PagedInfo? { get }
}

struct NotificationsEndpoint: EndpointProtocol {
    // MARK: - Properties
    private var request: NotificationsRequestProtocol
    
    var endpoint: String {
        String()
    }
    
    // MARK: - Initialization
    init(_ request: NotificationsRequestProtocol) {
        self.request = request
    }
}
