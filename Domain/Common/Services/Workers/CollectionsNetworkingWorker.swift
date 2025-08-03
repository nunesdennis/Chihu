//
//  CollectionsNetworkingWorker.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 11/01/25.
//

import Foundation

protocol CollectionsNetworkingWorkerProtocol {
    func fetchCollections(request: Collections.Load.Request, completion: @escaping (Result<Collections.Load.Response, Error>) -> Void)
}

final class CollectionsNetworkingWorker: CollectionsNetworkingWorkerProtocol {
    // MARK: - Properties
    var apiClient: APIClientProtocol
    
    // MARK: - Initialization
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    // MARK: - Public Methods
    func deleteCollection(request: Collections.Delete.Request, completion: @escaping (Result<Collections.Delete.Response, Error>) -> Void) {
        let endpoint = CollectionsEndpoint(request: request)
        
        apiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
//                    print(String(decoding: data, as: UTF8.self))
                    let messageResponse = try decoder.decode(MessageResponse.self, from: data)
                    completion(.success(Collections.Delete.Response(message: messageResponse.message)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchCollections(request: Collections.Load.Request, completion: @escaping (Result<Collections.Load.Response, Error>) -> Void) {
        let endpoint = CollectionsEndpoint(request: request)
        
        apiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
//                    print(String(decoding: data, as: UTF8.self))
                    let collectionsResponse = try decoder.decode(CollectionList.self, from: data)
                    completion(.success(Collections.Load.Response.init(collection: collectionsResponse)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchCollectionsItems(request: Collections.LoadItems.Request, completion: @escaping (Result<Collections.LoadItems.Response, Error>) -> Void) {
        let endpoint = CollectionsEndpoint(request: request)
        
        apiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
//                    print(String(decoding: data, as: UTF8.self))
                    let collectionItemsResponse = try decoder.decode(CollectionItemList.self, from: data)
                    completion(.success(Collections.LoadItems.Response(collectionUUID: request.collectionUUID, collectionItemList: collectionItemsResponse)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateCollection(request: NewCollection.UpdateCollection.Request, completion: @escaping (Result<NewCollection.UpdateCollection.Response, Error>) -> Void) {
        let endpoint = CollectionsEndpoint(request: request)
        
        apiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
//                    print(String(decoding: data, as: UTF8.self))
                    let collectionResponse = try decoder.decode(CollectionModel.self, from: data)
                    completion(.success(NewCollection.UpdateCollection.Response(collectionModel: collectionResponse)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func createCollection(request: NewCollection.SendCollection.Request, completion: @escaping (Result<NewCollection.SendCollection.Response, Error>) -> Void) {
        let endpoint = CollectionsEndpoint(request: request)
        
        apiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
//                    print(String(decoding: data, as: UTF8.self))
                    let collectionResponse = try decoder.decode(CollectionModel.self, from: data)
                    completion(.success(NewCollection.SendCollection.Response(collectionModel: collectionResponse)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func sendItemToCollection(request: Collections.SendItems.Request, completion: @escaping (Result<Collections.SendItems.Response, Error>) -> Void) {
        let endpoint = CollectionsEndpoint(request: request)
        
        apiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
//                    print(String(decoding: data, as: UTF8.self))
                    let messageResponse = try decoder.decode(MessageResponse.self, from: data)
                    completion(.success(Collections.SendItems.Response(message: messageResponse.message)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func deleteItemInCollection(request: Collections.DeleteItems.Request, completion: @escaping (Result<Collections.DeleteItems.Response, Error>) -> Void) {
        let endpoint = CollectionsEndpoint(request: request)
        
        apiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
//                    print(String(decoding: data, as: UTF8.self))
                    let messageResponse = try decoder.decode(MessageResponse.self, from: data)
                    completion(.success(Collections.DeleteItems.Response(message: messageResponse.message)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
