//
//  SettingsConfigurator.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 14/06/25.
//

import SwiftUI

extension SettingsView {
    func configureView() -> some View {
        var view = self
        let interactor = ProfileInteractor()
        let presenter = ProfilePresenter()
        view.interactor = interactor
        interactor.presenter = presenter
        presenter.view = view
        return view.colorScheme().withToast()
    }
}
