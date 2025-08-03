//
//  AppRegistrationNetworkingWorker.swift
//  Chihu
//
//  Created by Dennis Nunes on 06/04/25.
//

import Foundation

struct AppRegistrationRequest {
    struct Body: Encodable {
        let clientName = "Chihu"
        let redirectUris = "https://chihu.app/callback"
        let website = "https://chihu.app"
    }
    
    let body: AppRegistrationRequest.Body
    let instanceBaseURL: String
}

struct AppRegistrationResponse: Decodable {
    let id: String
    let name: String
    let website: String
    let clientId: String
    let clientSecret: String
    let redirectUri: String
    let vapidKey: String
}

protocol AppRegistrationNetworkingWorkerProtocol {
    func askForRegistration(request: AppRegistrationRequest, completion: @escaping (Result<AppRegistrationResponse, Error>) -> Void)
}

final class AppRegistrationNetworkingWorker: AppRegistrationNetworkingWorkerProtocol {
    // MARK: - Properties
    var apiClient: APIClientProtocol
    
    // MARK: - Initialization
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    func askForRegistration(request: AppRegistrationRequest, completion: @escaping (Result<AppRegistrationResponse, Error>) -> Void) {
        let endpoint = AppRegistrationEndpoint(request)
        
        apiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try decoder.decode(AppRegistrationResponse.self, from: data)
                    completion(.success(response))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
