//
//  ShelfListNetworkingWorker.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 31/08/24.
//

import Foundation

protocol ShelfListNetworkingProtocol {
    func fetchShelf(request: ShelfList.Load.Request, completion: @escaping (Result<ShelfList.Load.Response, Error>) -> Void)
}

final class ShelfListNetworkingWorker: ShelfListNetworkingProtocol {
    // MARK: - Properties
    var apiClient: APIClientProtocol
    
    // MARK: - Initialization
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    // MARK: - Public Methods
    func fetchShelf(request: ShelfList.Load.Request, completion: @escaping (Result<ShelfList.Load.Response, Error>) -> Void) {
        let endpoint = ShelfListEndpoint(request)
        
        apiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
//                    print(String(decoding: data, as: UTF8.self))
                    let shelfResponse = try decoder.decode(Shelf.self, from: data)
                    completion(.success(ShelfList.Load.Response.init(shelf: shelfResponse)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
