//
//  LoginModel.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 17/09/24.
//  
//
import Foundation

protocol TokenRequestBodyProtocol {
    var clientId: String { get }
    var clientSecret: String { get }
    var authCode: String { get }
    var redirectURI: String { get }
    var grantType: String { get }
}

enum Login {
    enum Token {
        struct Request: TokenRequestProtocol {
            struct TokenRequestBody: TokenRequestBodyProtocol {
                let clientId: String
                let clientSecret: String
                let authCode: String
                let redirectURI: String
                let grantType: String
                
                init?(authCode: String, instanceBaseURL: String) {
                    let apiClientIDEnum = EnvironmentKeys.getApiClientId(from: instanceBaseURL)
                    let apiClientSecretEnum = EnvironmentKeys.getApiClientSecret(from: instanceBaseURL)
                    
                    if let apiClientID = EnvironmentKeys.getCustomClientId() ?? EnvironmentKeys.getValueFor(apiClientIDEnum),
                       let apiClientSecret = EnvironmentKeys.getCustomClientSecret() ?? EnvironmentKeys.getValueFor(apiClientSecretEnum) {
                        self.clientId = apiClientID
                        self.clientSecret = apiClientSecret
                        self.authCode = authCode
                        self.redirectURI = "https://chihu.app/callback"
                        self.grantType = "authorization_code"
                    } else {
                        return nil
                    }
                }
            }
            
            let instanceBaseURL: String
            let body: TokenRequestBodyProtocol
        }
        
        struct Response: Decodable {
            let accessToken: String
            
            enum CodingKeys: String, CodingKey {
                case accessToken = "access_token"
            }
        }
        
        struct ViewModel {}
    }
}
