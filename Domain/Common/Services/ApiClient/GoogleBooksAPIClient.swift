//
//  GoogleBooksAPIClient.swift
//  Chihu
//
//  Created by Dennis Nunes on 04/11/24.
//

import Foundation

final class GoogleBooksAPIClient: APIClientProtocol {
    // MARK: - Properties
    
    let session: URLSession

    // MARK: - Initialization
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    // MARK: - Private Methods
    
    private func makeRequest(_ endpoint: EndpointProtocol) -> URLRequest? {
        guard let url = endpoint.url else {
            return nil
        }
        var request = URLRequest(url: url,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 10.0)
        request.httpMethod = endpoint.method
        request.timeoutInterval = 10
        
        #if DEBUG
                print("//////////////////")
                print(request.cURL())
                print("//////////////////")
        #else
         // No debugging information in release build
        #endif
        
        return request as URLRequest
    }
    
    // MARK: - Public Methods
    
    func request(endpoint: EndpointProtocol, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let request = makeRequest(endpoint) else {
            DispatchQueue.main.async {
                completion(.failure(ChihuError.noURL))
            }
            return
        }

        session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(ChihuError.api(error: error)))
                    return
                }
                
                guard   let urlResponse = (response as? HTTPURLResponse) else {
                    completion(.failure(ChihuError.noResponse))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(ChihuError.noData))
                    return
                }
                
                let code = urlResponse.statusCode
                if code != 200 && code != 201 {
                    completion(.failure(ChihuError.unknown))
                    return
                }
                
                completion(.success(data))
            }
        }.resume()
    }
}
