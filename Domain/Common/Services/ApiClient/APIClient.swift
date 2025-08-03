//
//  APIClient.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 25/08/24.
//

import Foundation
import SwiftUI

enum ChihuError: Error {
    case api(error: Error)
    case noResponse
    case noData
    case noURL
    case unknown
    case decodeError
    case authCodeMissing
    case canNotOpenURL
    case canNotConvertURLtoItem
    case invalidURL
    case accessTokenMissing
    case didTapCardFailed
    case noResultsTryURL
    case fetchInProgress
    case tryAgainLater
    case appAccessKeysAreWrong
    case keychain
    case notFound
    case genericErrorFromServer
    case unauthorized
    case codeError
}

extension ChihuError: LocalizedError {
    var errorImage: Image {
        let imageName: String
        
        switch self {
        case .api, .notFound:
            imageName = "error1"
        case .noResponse:
            imageName = "error2"
        case .noData:
            imageName = "error3"
        case .noURL:
            imageName = "error7"
        case .decodeError:
            imageName = "error4"
        case .authCodeMissing:
            imageName = "error6"
        case .canNotOpenURL:
            imageName = "error13"
        case .invalidURL:
            imageName = "error14"
        case .accessTokenMissing,.appAccessKeysAreWrong, .keychain:
            imageName = "error8"
        case .didTapCardFailed:
            imageName = "error15"
        case .noResultsTryURL:
            imageName = "error12"
        case .genericErrorFromServer, .unauthorized:
            imageName = "error9"
        case .codeError:
            imageName = "error11"
        default:
            imageName = "error5"
        }
        
        return Image(imageName)
    }
    
    var errorTitle: String {
        let title: String
        
        switch self {
        case .api, .notFound, .genericErrorFromServer, .unauthorized:
            title = "Server error"
        case .noResponse, .noData:
            title = "Nothing came"
        case .noURL:
            title = "No URL"
        case .decodeError:
            title = "Something is not tasting well"
        case .authCodeMissing:
            title = "Something is missing"
        case .canNotOpenURL:
            title = "Can not open this"
        case .invalidURL:
            title = "Not a valid link"
        case .accessTokenMissing, .appAccessKeysAreWrong:
            title = "Something is missing"
        case .didTapCardFailed:
            title = "Not finding this card"
        case .noResultsTryURL:
            title = "Did not find anything"
        case .keychain:
            title = "Access keys problem"
        default:
            title = "¯\\_(ツ)_/¯"
        }
        
        return title.localized
    }
    
    var errorDescription: String? {
        let description: String
        
        switch self {
        case .api(error: let error):
            description = error.localizedDescription
        case .noResponse, .noData:
            description = "I did not receive the response I was expecting"
        case .noURL:
            description = "Seems like I don't have the url that I need here"
        case .decodeError:
            description = "Not sure what came, but I don't know how to deal with this"
        case .authCodeMissing:
            description = "I don't have the keys that I need here"
        case .canNotOpenURL:
            description = "I can not open this link, sorry"
        case .invalidURL:
            description = "This link is not valid, not sure why, sorry"
        case .accessTokenMissing, .keychain:
            description = "I don't have your keys that I need here"
        case .appAccessKeysAreWrong:
            description = "I don't have my keys that I need here"
        case .didTapCardFailed:
            description = "I could not find the card that you selected, try again maybe"
        case .noResultsTryURL:
            description = "No results, try to search with url"
        case .notFound:
            description = "Not found"
        case .unauthorized:
            description = "Unauthorized"
        case .codeError:
            description = "My bad, I have something to fix here"
        default:
            description = "Not sure what happened"
        }
        
        return description.localized
    }
}

protocol APIClientProtocol {
    func request(endpoint: EndpointProtocol, completion: @escaping (Result<Data, Error>) -> Void)
}

final class APIClient: APIClientProtocol {
    // MARK: - Properties
    
    let session: URLSession

    // MARK: - Initialization
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    // MARK: - Private Methods
    
    private func getHeaderUpdated(endpoint: EndpointProtocol) -> [String : String] {
        var header = endpoint.header
        if endpoint.isTokenNeeded {
            header["Authorization"] = "Bearer \(UserSettings.shared.accessToken ?? "")"
        }
        
        return header
    }
    
    private func makeRequest(_ endpoint: EndpointProtocol) -> URLRequest? {
        guard let url = endpoint.url else {
            return nil
        }
        var request = URLRequest(url: url,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 10.0)
        request.httpMethod = endpoint.method
        request.allHTTPHeaderFields = getHeaderUpdated(endpoint: endpoint)
        if let body = endpoint.body {
            request.httpBody = body
        }
        
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
                
                guard let urlResponse = (response as? HTTPURLResponse) else {
                    completion(.failure(ChihuError.noResponse))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(ChihuError.noData))
                    return
                }
                
                let code = urlResponse.statusCode
                if code != 200 && code != 201 && code != 302 {
                    if code == 404 {
                        completion(.failure(ChihuError.notFound))
                        return
                    } else if code == 500 {
                        completion(.failure(ChihuError.genericErrorFromServer))
                        return
                    } else if code == 401 {
                        completion(.failure(ChihuError.unauthorized))
                        return
                    }
                    
                    let error = APIClient.decodeError(from: data)
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
            print(String(decoding: data, as: UTF8.self))
            let instanceError = try decoder.decode(APIError.self, from: data)
            if (instanceError.localizedDescription.caseInsensitiveCompare("fetch in progress") == .orderedSame) {
                return ChihuError.fetchInProgress
            } else if (instanceError.localizedDescription.caseInsensitiveCompare("Try again later") == .orderedSame) {
                return ChihuError.tryAgainLater
            }
            
            return instanceError
        } catch {
            return ChihuError.decodeError
        }
    }
}
