//
//  ProfileModel.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 24/08/24.
//  
//

import Foundation
import SwiftUI

enum Profile {
    enum Load {
        struct Request: ProfileRequestProtocol {}
        
        struct Response: Decodable {
            let user: User
        }
        
        struct ViewModel {
            let url: URL?
            let externalAccount: String?
            let displayName: String
            let avatar: URL?
            let username: String
            
            init(user: User) {
                url = URL(string: user.url)
                externalAccount = user.externalAccount
                displayName = user.displayName
                avatar = URL(string: user.avatar)
                username = user.username
            }
            
            init(url: URL?, externalAccount: String?, displayName: String, avatar: URL?, username: String) {
                self.url = url
                self.externalAccount = externalAccount
                self.displayName = displayName
                self.avatar = avatar
                self.username = username
            }
        }
    }
    
    enum UpdateAvatar {
        struct Request {
            let imageData: Data
        }
        
        struct Response: Decodable {
            let user: User
        }
    }
}
