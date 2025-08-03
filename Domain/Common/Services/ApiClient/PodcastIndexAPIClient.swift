//
//  PodcastIndexAPIClient.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 31/12/24.
//

import Foundation
import CryptoKit

final class PodcastIndexAPIClient: APIClientProtocol {
    // MARK: - Properties
    
    let session: URLSession
    
    // MARK: - Initialization
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    // MARK: - Private Methods
    
    private func getHeaderUpdated(endpoint: EndpointProtocol) -> [String : String] {
        
        var header = endpoint.header
        
        if endpoint.isTokenNeeded,
           let piAPIkey = EnvironmentKeys.getValueFor(.podcastIndexApiKey),
           let piAPIsecret = EnvironmentKeys.getValueFor(.podcastIndexApiClientSecret) {
            let timeInSeconds = Date().timeIntervalSince1970
            let apiHeaderTime = Int(timeInSeconds)
            let data4Hash = piAPIkey + piAPIsecret + "\(apiHeaderTime)"
            let inputData = Data(data4Hash.utf8)
            let hashed = Insecure.SHA1.hash(data: inputData)
            let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
            
            
            header["X-Auth-Date"] = "\(apiHeaderTime)"
            header["X-Auth-Key"] = piAPIkey
            header["Authorization"] = hashString
        }
        
        return header
    }
    
    private func makeRequest(_ endpoint: EndpointProtocol) -> URLRequest? {
        guard let url = endpoint.url else {
            return nil
        }
        var request = URLRequest(url: url,timeoutInterval: 10.0)
        request.httpMethod = endpoint.method
        request.allHTTPHeaderFields = getHeaderUpdated(endpoint: endpoint)
        
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
                    let error = PodcastIndexAPIClient.decodeError(from: data)
                    completion(.failure(error))
                    return
                }
                
                completion(.success(data))
            }
        }.resume()
    }
    
    static func decodeError(from data: Data) -> Error {
        let decoder = JSONDecoder()
        do {
            let piError = try decoder.decode(PIerror.self, from: data)
            return piError
        } catch {
            return ChihuError.decodeError
        }
    }
}
