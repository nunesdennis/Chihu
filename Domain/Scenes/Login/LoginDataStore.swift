//
//  LoginDataStore.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 17/09/24.
//  
//
import Foundation

enum LoginState {
    case firstScreen
    case useAnotherServer
    case success
    case error(Error?)
    case loading
    case registerLocally
}

extension LoginState: Equatable {
    static func == (lhs: LoginState, rhs: LoginState) -> Bool {
        switch (lhs, rhs) {
        case (.firstScreen, .firstScreen),
             (.useAnotherServer, .useAnotherServer),
             (.success, .success),
             (.loading, .loading),
             (.error, .error):
            return true
        default:
            return false
        }
    }
}

final class LoginDataStore: ObservableObject {
    @Published var state: LoginState = .firstScreen
    @Published var openWebView: Bool = false
    @Published var inputText: String = String()
    var authenticationUrl: URL!
    var receivedFromURLauthCode: String = String()
    
    @Published var registeredServerList = [
        RegisteredServer(name: "DB.Casually.cat",
                         urlString: LoginConstants.dbCasually,
                         language: "English"),
        RegisteredServer(name: "Eggplant.place",
                         urlString: LoginConstants.eggplantUrl,
                         language: "Global"),
        RegisteredServer(name: "Fantastika",
                         urlString: LoginConstants.fantastika,
                         language: nil),
        RegisteredServer(name: "Minreol.dk",
                         urlString: LoginConstants.minreol,
                         language: "Danish"),
        RegisteredServer(name: "NeoDB.social",
                         urlString: LoginConstants.neodbUrl,
                         language: "Chinese"),
        RegisteredServer(name: "Neodb.deadvey",
                         urlString: LoginConstants.neodbDeadvey,
                         language: nil),
        RegisteredServer(name: "Neodb.kevga.de",
                         urlString: LoginConstants.neodbKevga,
                         language: "German"),
        RegisteredServer(name: "ReviewDB.app",
                         urlString: LoginConstants.reviewDB,
                         language: "English")
    ]
}
