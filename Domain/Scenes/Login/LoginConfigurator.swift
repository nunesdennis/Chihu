//
//  LoginConfigurator.swift
//  Chihu
//
//  
//

import SwiftUI

extension LoginView {
    func configureView() -> some View {
        var view = self
        let interactor = LoginInteractor()
        let presenter = LoginPresenter()
        view.interactor = interactor
        interactor.presenter = presenter
        presenter.view = view
        return view.colorScheme()
    }
}
