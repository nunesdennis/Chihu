//
//  TimelineNetworkingWorker.swift
//  Chihu
//
//  Created by Dennis Nunes on 13/11/24.
//

import Foundation
import TootSDK

protocol TimelineNetworkingProtocol {
    func fetchPosts(request: Timeline.Load.Request,completion: @escaping (Result<Timeline.Load.Response, Error>) -> Void) async
}

final class TimelineNetworkingWorker: TimelineNetworkingProtocol {
    
    // MARK: - Properties
    var apiClient: APIClientProtocol
    
    // MARK: - Initialization
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    // MARK: - Public Methods
    func fetchPosts(request: Timeline.Load.Request, completion: @escaping (Result<Timeline.Load.Response, Error>) -> Void) async {
        let endpoint = TimelineEndpoint(request)
        guard let url = endpoint.url else {
            completion(.failure(ChihuError.invalidURL))
            return
        }
        
        guard let accessToken = UserSettings.shared.accessToken else {
            completion(.failure(ChihuError.accessTokenMissing))
            return
        }
        
        do {
            let client = try await TootClient(connect: url, accessToken: accessToken)
            let items = try await client.getTimeline(request.timelineType, pageInfo: request.pageInfo)
            let response = Timeline.Load.Response(posts: items.result)
            completion(.success(response))
        } catch let error {
            completion(.failure(error))
        }
    }
}
