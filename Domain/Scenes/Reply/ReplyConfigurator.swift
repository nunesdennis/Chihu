//
//  ReplyConfigurator.swift
//  Chihu
//
//  Created by Dennis Nunes on 31/01/25.
//  
//

import SwiftUI

extension ReplyView {
    func configureView() -> some View {
        var view = self
        let interactor = ReplyInteractor()
        let presenter = ReplyPresenter()
        view.interactor = interactor
        interactor.presenter = presenter
        presenter.view = view
        return view.colorScheme()
    }
}
