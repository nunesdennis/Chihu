//
//  UserNetworkingWorker.swift
//  Chihu
//
//  Created by Dennis Nunes on 05/04/25.
//

import Foundation

protocol UserNetworkingWorkerProtocol {
    func fetchUserPreference(request: UserPreference.Load.Request, completion: @escaping (Result<UserPreference.Load.Response, Error>) -> Void)
}

final class UserNetworkingWorker: UserNetworkingWorkerProtocol {
    // MARK: - Properties
    var apiClient: APIClientProtocol
    
    // MARK: - Initialization
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    func fetchUserPreference(request: UserPreference.Load.Request, completion: @escaping (Result<UserPreference.Load.Response, Error>) -> Void) {
        let endpoint = UserPreferenceEndpoint(request: request)
        
        apiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
//                    print(String(decoding: data, as: UTF8.self))
                    let response = try decoder.decode(UserPreferenceSchema.self, from: data)
                    completion(.success(UserPreference.Load.Response.init(userPreference: response)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
