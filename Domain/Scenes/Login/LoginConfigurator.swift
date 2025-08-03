//
//  LoginConfigurator.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 17/09/24.
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
