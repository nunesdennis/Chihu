//
//  SearchNetworkingWorker.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 01/09/24.
//

import Foundation

protocol SearchNetworkingProtocol {
    func fetchByNameTMDB(request: SearchByNameTMDB.Load.Request, completion: @escaping (Result<SearchByNameTMDB.Load.Response, Error>) -> Void)
    func fetchByNamePI(request: SearchByNamePI.Load.Request, completion: @escaping (Result<SearchByNamePI.Load.Response, Error>) -> Void)
    func fetchByNameGoogleBooks(request: SearchByNameGoogleBooks.Load.Request, completion: @escaping (Result<SearchByNameGoogleBooks.Load.Response, Error>) -> Void)
}

final class SearchNetworkingWorker: SearchNetworkingProtocol {
    // MARK: - Properties
    var tmdbApiClient: APIClientProtocol
    var googleBooksApiClient: APIClientProtocol
    var podcastIndexApiClient: APIClientProtocol
    
    // MARK: - Initialization
    init(tmdbApiClient: APIClientProtocol = TMDBAPIClient(),
         googleBooksApiClient: APIClientProtocol = GoogleBooksAPIClient(),
         podcastIndexApiClient: APIClientProtocol = PodcastIndexAPIClient()) {
        self.tmdbApiClient = tmdbApiClient
        self.googleBooksApiClient = googleBooksApiClient
        self.podcastIndexApiClient = podcastIndexApiClient
    }
    
    func fetchByNameTMDB(request: SearchByNameTMDB.Load.Request, completion: @escaping (Result<SearchByNameTMDB.Load.Response, Error>) -> Void) {
        let endpoint = SearchByNameTMDBendpoint(request)
        
        tmdbApiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let shelfResponse = try decoder.decode(ShelfTMDB.self, from: data)
//                    print(String(decoding: data, as: UTF8.self))
                    completion(.success(SearchByNameTMDB.Load.Response.init(shelf: shelfResponse, category: request.category)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchByNamePI(request: SearchByNamePI.Load.Request, completion: @escaping (Result<SearchByNamePI.Load.Response, Error>) -> Void) {
        let endpoint = SearchByNamePIendpoint(request)
        
        podcastIndexApiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
//                    print(String(decoding: data, as: UTF8.self))
                    let shelfResponse = try decoder.decode(ShelfPodcastIndexList.self, from: data)
                    completion(.success(SearchByNamePI.Load.Response.init(shelf: shelfResponse)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchByNameGoogleBooks(request: SearchByNameGoogleBooks.Load.Request, completion: @escaping (Result<SearchByNameGoogleBooks.Load.Response, Error>) -> Void) {
        let endpoint = SearchByNameGoogleBooksEndpoint(request)
        
        googleBooksApiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
//                    print(String(decoding: data, as: UTF8.self))
                    let shelfResponse = try decoder.decode(ShelfGoogleBooks.self, from: data)
                    completion(.success(SearchByNameGoogleBooks.Load.Response.init(shelf: shelfResponse, category: request.category)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
