//
//  LoginInteractor.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 17/09/24.
//  
//
import Foundation

enum LoginError: Error {
    case didNotSaveAccessToken
}

protocol LoginBusinessLogic {
    func load(request: Login.Token.Request)
    func register(request: AppRegistrationRequest)
}

final class LoginInteractor {
    typealias Request = Login.Token.Request
    typealias Response = Login.Token.Response
    var presenter: LoginPresentationLogic?
}

extension LoginInteractor: LoginBusinessLogic {
    func register(request: AppRegistrationRequest) {
        let worker = AppRegistrationNetworkingWorker()
        worker.askForRegistration(request: request) { [unowned self] result in
            switch result {
            case .success(let model):
                presenter?.presentRegisterSuccess(model: model)
            case .failure(let error):
                presenter?.present(error: error)
            }
        }
    }
    
    func load(request: Request) {
        let worker = LoginNetworkingWorker()
        worker.fetchAccessToken(request: request) { [unowned self] result in
            switch result {
            case .success:
                presenter?.presentSuccess()
            case .failure(let error):
                presenter?.present(error: error)
            }
        }
    }
}
