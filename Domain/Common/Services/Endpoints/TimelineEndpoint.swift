//
//  TimelineEndpoint.swift
//  Chihu
//
//  Created by Dennis Nunes on 13/11/24.
//

import Foundation
import TootSDK

protocol TimelineRequestProtocol {
    var timelineType: TootSDK.Timeline { get }
    var pageInfo: PagedInfo? { get }
}

struct TimelineEndpoint: EndpointProtocol {
    // MARK: - Properties
    private var request: TimelineRequestProtocol
    
    var endpoint: String {
        String()
    }
    
    // MARK: - Initialization
    init(_ request: TimelineRequestProtocol) {
        self.request = request
    }
}
