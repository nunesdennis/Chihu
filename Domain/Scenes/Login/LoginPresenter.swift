//
//  LoginPresenter.swift
//  Chihu
//
//  
//
import Foundation

protocol LoginPresentationLogic {
    func presentRegisterSuccess(model: AppRegistrationResponse)
    func presentSuccess()
    func present(error: Error)
}

final class LoginPresenter {
    typealias Response = Login.Token.Response
    typealias ViewModel = Login.Token.ViewModel
    var view: LoginDisplayLogic?
}

extension LoginPresenter: LoginPresentationLogic {
    func presentRegisterSuccess(model: AppRegistrationResponse) {
        view?.displayRegisterSuccess(model: model)
    }
    
    func presentSuccess() {
        view?.displaySuccess()
    }
    
    func present(error: Error) {
        view?.display(error: error)
    }
}
