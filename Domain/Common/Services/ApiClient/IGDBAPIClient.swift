//
//  IGDBAPIClient.swift
//  Chihu
//

import Foundation

final class IGDBAPIClient: APIClientProtocol {
    // MARK: - Properties

    let session: URLSession
    private static var cachedToken: String?
    private static var tokenExpiry: Date?

    // MARK: - Initialization

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    // MARK: - Public Methods

    func request(endpoint: EndpointProtocol, completion: @escaping (Result<Data, Error>) -> Void) {
        let now = Date()
        if let token = Self.cachedToken, let expiry = Self.tokenExpiry, now < expiry {
            perform(endpoint: endpoint, token: token, completion: completion)
        } else {
            fetchToken { result in
                switch result {
                case .success(let token):
                    self.perform(endpoint: endpoint, token: token, completion: completion)
                case .failure(let error):
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
        }
    }

    // MARK: - Private Methods

    private func fetchToken(completion: @escaping (Result<String, Error>) -> Void) {
        guard let clientId = EnvironmentKeys.getValueFor(.igdbApiKey),
              let clientSecret = EnvironmentKeys.getValueFor(.igdbApiSecret) else {
            completion(.failure(ChihuError.appAccessKeysAreWrong))
            return
        }

        let tokenURLString = "https://id.twitch.tv/oauth2/token?client_id=\(clientId)&client_secret=\(clientSecret)&grant_type=client_credentials"
        guard let url = URL(string: tokenURLString) else {
            completion(.failure(ChihuError.noURL))
            return
        }

        var request = URLRequest(url: url, timeoutInterval: 10.0)
        request.httpMethod = "POST"

#if DEBUG
        print("//////////////////")
        print(request.cURL())
        print("//////////////////")
#else
        // No debugging information in release build
#endif

        session.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(ChihuError.api(error: error)))
                return
            }
            guard let data = data else {
                completion(.failure(ChihuError.noData))
                return
            }
            do {
                let tokenResponse = try JSONDecoder().decode(IGDBTokenResponse.self, from: data)
                Self.cachedToken = tokenResponse.accessToken
                Self.tokenExpiry = Date().addingTimeInterval(TimeInterval(tokenResponse.expiresIn - 60))
                completion(.success(tokenResponse.accessToken))
            } catch {
                completion(.failure(ChihuError.decodeError))
            }
        }.resume()
    }

    private func perform(endpoint: EndpointProtocol, token: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = endpoint.url,
              let clientId = EnvironmentKeys.getValueFor(.igdbApiKey) else {
            DispatchQueue.main.async { completion(.failure(ChihuError.noURL)) }
            return
        }

        var request = URLRequest(url: url, timeoutInterval: 10.0)
        request.httpMethod = endpoint.method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue(clientId, forHTTPHeaderField: "Client-ID")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
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

        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(ChihuError.api(error: error)))
                    return
                }
                guard let urlResponse = response as? HTTPURLResponse else {
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
