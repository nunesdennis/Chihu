//
//  ReviewNetworkingWorker.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 16/09/24.
//

import Foundation

protocol ReviewNetworkingWorkerProtocol {
    func rateItem(request: Review.Send.Request, completion: @escaping (Result<Review.Send.Response, Error>) -> Void)
}

final class ReviewNetworkingWorker: ReviewNetworkingWorkerProtocol {
    // MARK: - Properties
    var apiClient: APIClientProtocol
    
    // MARK: - Initialization
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    // MARK: - Rate
    func rateItem(request: Review.Send.Request, completion: @escaping (Result<Review.Send.Response, Error>) -> Void) {
        let endpoint = ReviewEndpoint(request: request)
        
        apiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let messageResponse = try decoder.decode(MessageResponse.self, from: data)
                    completion(.success(Review.Send.Response(message: messageResponse.message)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func deleteRateItem(request: Review.Delete.Request, completion: @escaping (Result<Review.Delete.Response, Error>) -> Void) {
        let endpoint = ReviewEndpoint(request: request)
        
        apiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let messageResponse = try decoder.decode(MessageResponse.self, from: data)
                    completion(.success(Review.Delete.Response(message: messageResponse.message)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchRateItem(request: Review.Load.Request, completion: @escaping (Result<Review.Load.Response, Error>) -> Void) {
        let endpoint = ReviewEndpoint(request: request)
        
        apiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
//                    print(String(decoding: data, as: UTF8.self))
                    let response = try decoder.decode(ShelfItem.self, from: data)
                    completion(.success(Review.Load.Response(shelfItem: response)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: Review
    func reviewItem(request: FullReview.Send.Request, completion: @escaping (Result<FullReview.Send.Response, Error>) -> Void) {
        let endpoint = FullReviewEndpoint(request: request)
        
        apiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let messageResponse = try decoder.decode(MessageResponse.self, from: data)
                    completion(.success(FullReview.Send.Response(message: messageResponse.message)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchReviewItem(request: FullReview.Load.Request, completion: @escaping (Result<FullReview.Load.Response, Error>) -> Void) {
        let endpoint = FullReviewEndpoint(request: request)
        
        apiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try decoder.decode(ShelfItem.self, from: data)
                    completion(.success(FullReview.Load.Response(shelfItem: response)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func deleteReviewItem(request: FullReview.Delete.Request, completion: @escaping (Result<FullReview.Delete.Response, Error>) -> Void) {
        let endpoint = FullReviewEndpoint(request: request)
        
        apiClient.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let messageResponse = try decoder.decode(MessageResponse.self, from: data)
                    completion(.success(FullReview.Delete.Response(message: messageResponse.message)))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
