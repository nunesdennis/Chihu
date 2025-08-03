//
//  LoginNetworkingWorker.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 17/09/24.
//

import Foundation

protocol LoginNetworkingWorkerProtocol {
    func fetchAccessToken(request: Login.Token.Request, completion: @escaping (Result<Void, Error>) -> Void)
}

final class LoginNetworkingWorker: LoginNetworkingWorkerProtocol {
    // MARK: - Properties
    var apiClient: APIClientProtocol
    
    // MARK: - Initialization
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    // MARK: - Public Methods
    func fetchAccessToken(request: Login.Token.Request, completion: @escaping (Result<Void, Error>) -> Void) {
        let endpoint = TokenEndpoint(request)
        
        apiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let tokenResponse = try decoder.decode(Login.Token.Response.self, from: data)
                    try UserSettings.shared.saveToken(tokenResponse.accessToken)
                    UserSettings.shared.saveBaseUrl(request.instanceBaseURL)
                    completion(.success(()))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
