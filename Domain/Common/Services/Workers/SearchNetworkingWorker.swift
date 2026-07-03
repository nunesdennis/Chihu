//
//  SearchNetworkingWorker.swift
//  Chihu
//
//

import Foundation

protocol SearchNetworkingProtocol {
    func fetchByNameTMDB(request: SearchByNameTMDB.Load.Request, completion: @escaping (Result<SearchByNameTMDB.Load.Response, Error>) -> Void)
    func fetchByNamePI(request: SearchByNamePI.Load.Request, completion: @escaping (Result<SearchByNamePI.Load.Response, Error>) -> Void)
    func fetchByNameGoogleBooks(request: SearchByNameGoogleBooks.Load.Request, completion: @escaping (Result<SearchByNameGoogleBooks.Load.Response, Error>) -> Void)
    func fetchByNameItunes(request: SearchByNameItunes.Load.Request, completion: @escaping (Result<SearchByNameItunes.Load.Response, Error>) -> Void)
    func fetchByNameIGDB(request: SearchByNameIGDB.Load.Request, completion: @escaping (Result<SearchByNameIGDB.Load.Response, Error>) -> Void)
}

final class SearchNetworkingWorker: SearchNetworkingProtocol {
    // MARK: - Properties
    var tmdbApiClient: APIClientProtocol
    var googleBooksApiClient: APIClientProtocol
    var podcastIndexApiClient: APIClientProtocol
    var itunesApiClient: APIClientProtocol
    var igdbApiClient: APIClientProtocol

    // MARK: - Initialization
    init(tmdbApiClient: APIClientProtocol = TMDBAPIClient(),
         googleBooksApiClient: APIClientProtocol = GoogleBooksAPIClient(),
         podcastIndexApiClient: APIClientProtocol = PodcastIndexAPIClient(),
         itunesApiClient: APIClientProtocol = ItunesAPIClient(),
         igdbApiClient: APIClientProtocol = IGDBAPIClient()) {
        self.tmdbApiClient = tmdbApiClient
        self.googleBooksApiClient = googleBooksApiClient
        self.podcastIndexApiClient = podcastIndexApiClient
        self.itunesApiClient = itunesApiClient
        self.igdbApiClient = igdbApiClient
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

    func fetchByNameItunes(request: SearchByNameItunes.Load.Request, completion: @escaping (Result<SearchByNameItunes.Load.Response, Error>) -> Void) {
        let endpoint = SearchByNameItunesEndpoint(request)

        itunesApiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
//                    print(String(decoding: data, as: UTF8.self))
                    let shelfResponse = try decoder.decode(ShelfItunes.self, from: data)
                    completion(.success(SearchByNameItunes.Load.Response.init(shelf: shelfResponse)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchByNameIGDB(request: SearchByNameIGDB.Load.Request, completion: @escaping (Result<SearchByNameIGDB.Load.Response, Error>) -> Void) {
        let endpoint = SearchByNameIGDBEndpoint(request)

        igdbApiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
//                    print(String(decoding: data, as: UTF8.self))
                    let games = try decoder.decode([IGDBGame].self, from: data)
                    let shelf = ShelfIGDB(games: games)
                    completion(.success(SearchByNameIGDB.Load.Response(shelf: shelf)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
