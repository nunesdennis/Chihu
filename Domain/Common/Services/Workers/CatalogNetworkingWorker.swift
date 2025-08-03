//
//  CatalogNetworkingWorker.swift
//  Chihu
//
//  Created by Dennis Nunes on 24/01/25.
//

import Foundation

protocol CatalogNetworkingProtocol {
    func fetchByUUID(request: CatalogTypeModel.Load.Request, completion: @escaping (Result<CatalogTypeModel.Load.Response, Error>) -> Void)
    func fetchByURL(request: SearchByURL.Load.Request, completion: @escaping (Result<SearchByURL.Load.Response, Error>) -> Void)
    func fetchByName(request: SearchByName.Load.Request, completion: @escaping (Result<SearchByName.Load.Response, Error>) -> Void)
}

final class CatalogNetworkingWorker: CatalogNetworkingProtocol {
    // MARK: - Properties
    var apiClient: APIClientProtocol
    
    // MARK: - Initialization
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    // MARK: - Public Methods
    
    func fetchByUUID(request: CatalogTypeModel.Load.Request, completion: @escaping (Result<CatalogTypeModel.Load.Response, Error>) -> Void) {
        let endpoint = CatalogTypeEndpoint(request)
        
        apiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
//                    print(String(decoding: data, as: UTF8.self))
                    let catalogResponse = try decoder.decode(ItemSchema.self, from: data)
                    completion(.success(CatalogTypeModel.Load.Response.init(catalogItem: catalogResponse)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchByURL(request: SearchByURL.Load.Request, completion: @escaping (Result<SearchByURL.Load.Response, Error>) -> Void) {
        let endpoint = SearchByURLEndpoint(request)
        
        apiClient.request(endpoint: endpoint) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    // TODO: Needs to be updated when API updates
                    if let messageResponse = try? decoder.decode(MessageResponse.self, from: data),
                       let apiUrl = messageResponse.url {
                        self?.fetchWithApiURL(apiUrl, itemClass: request.itemClass) { result in
                            switch result {
                            case .success(let item):
                                completion(.success(SearchByURL.Load.Response.init(shelfItemDetails: item)))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    } else {
                        let item = try decoder.decode(ItemSchema.self, from: data)
                        completion(.success(SearchByURL.Load.Response.init(shelfItemDetails: item)))
                    }
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchWithApiURL(_ apiURL: String, itemClass: any ItemProtocol.Type, completion: @escaping (Result<any ItemProtocol, Error>) -> Void) {
        let endpoint = ApiUrlEndpoint(apiURL: apiURL)
        
        apiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
//                    print(String(decoding: data, as: UTF8.self))
                    let item = try decoder.decode(itemClass.self, from: data)
                    completion(.success(item))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchByName(request: SearchByName.Load.Request, completion: @escaping (Result<SearchByName.Load.Response, Error>) -> Void) {
        let endpoint = SearchByNameEndpoint(request)
        
        apiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
//                    print(String(decoding: data, as: UTF8.self))
                    let catalogResponse = try decoder.decode(Catalog.self, from: data)
                    completion(.success(SearchByName.Load.Response.init(catalog: catalogResponse)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchPosts(request: CatalogPostsModel.Load.Request, completion: @escaping (Result<CatalogPostsModel.Load.Response, Error>) -> Void) {
        let endpoint = CatalogPostEndpoint(request)
        
        apiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
//                    print(String(decoding: data, as: UTF8.self))
                    let catalogResponse = try decoder.decode(PostsSchema.self, from: data)
                    completion(.success(CatalogPostsModel.Load.Response(posts: catalogResponse)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
