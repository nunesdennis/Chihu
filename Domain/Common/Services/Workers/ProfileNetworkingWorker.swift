//
//  ProfileNetworkingWorker.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 25/08/24.
//

import Foundation

protocol ProfileNetworkingProtocol {
    func fetchUser(request: Profile.Load.Request,completion: @escaping (Result<Profile.Load.Response, Error>) -> Void)
}

final class ProfileNetworkingWorker: ProfileNetworkingProtocol {
    // MARK: - Properties
    var apiClient: APIClientProtocol
    
    // MARK: - Initialization
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    // MARK: - Public Methods
    func fetchUser(request: Profile.Load.Request, completion: @escaping (Result<Profile.Load.Response, Error>) -> Void) {
        let endpoint = ProfileEndpoint(request)
        
        apiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let userResponse = try decoder.decode(User.self, from: data)
                    completion(.success(Profile.Load.Response.init(user: userResponse)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
