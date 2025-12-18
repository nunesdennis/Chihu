//
//  NotificationsNetworkingWorker.swift
//  Chihu
//
//

import Foundation
import TootSDK

protocol NotificationsNetworkingProtocol {
    func fetchNotifications(request: Notifications.Load.Request,completion: @escaping (Result<Notifications.Load.Response, Error>) -> Void) async
}

final class NotificationsNetworkingWorker: NotificationsNetworkingProtocol {
    
    // MARK: - Public Methods
    func fetchNotifications(request: Notifications.Load.Request, completion: @escaping (Result<Notifications.Load.Response, Error>) -> Void) async {
        let endpoint = NotificationsEndpoint(request)
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
            let items = try await client.getNotifications(request.pageInfo)
            
            let response = Notifications.Load.Response(notifications: items.result)
            completion(.success(response))
        } catch let error {
            completion(.failure(error))
        }
    }
}
