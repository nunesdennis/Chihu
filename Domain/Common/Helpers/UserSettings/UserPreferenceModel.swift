//
//  UserPreferenceModel.swift
//  Chihu
//
//  Created by Dennis Nunes on 05/04/25.
//

import Foundation

struct UserPreferenceSchema: Decodable {
    let defaultCrosspost: Bool
    let defaultVisibility: Int
    let hiddenCategories: [String]
    let language: String
}

enum UserPreference {
    enum Load {
        struct Request: UserPreferenceRequestProtocol {}
        
        struct Response {
            var userPreference: UserPreferenceSchema
        }
        
        struct ViewModel {
            let defaultCrosspost: Bool
            let defaultVisibility: Visibility
            let hiddenCategories: [String]
            
            init(preference: UserPreferenceSchema) {
                defaultCrosspost = preference.defaultCrosspost
                defaultVisibility = Visibility(rawValue: preference.defaultVisibility) ?? .public
                hiddenCategories = preference.hiddenCategories
            }
            
            init(defaultCrosspost: Bool,
                 defaultVisibility: Visibility,
                 hiddenCategories: [String]) {
                self.defaultCrosspost = defaultCrosspost
                self.defaultVisibility = defaultVisibility
                self.hiddenCategories = hiddenCategories
            }
        }
    }
}
