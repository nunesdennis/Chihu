//
//  ReviewConfigurator.swift
//  Chihu
//
//  Created by Dennis Nunes on 10/09/24.
//  
//

import SwiftUI

extension ReviewView {
    func configureView() -> some View {
        var view = self
        let interactor = ReviewInteractor()
        let postInteractionInteractor = PostInteractionsInteractor()
        let presenter = ReviewPresenter()
        view.interactor = interactor
        view.postInteractionInteractor = postInteractionInteractor
        interactor.presenter = presenter
        postInteractionInteractor.presenter = presenter
        presenter.view = view
        return view
            .withToast()
    }
}
