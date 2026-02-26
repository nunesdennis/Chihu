//
//  SettingsConfigurator.swift
//  Chihu
//
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
        return view.withToast()
    }
}
