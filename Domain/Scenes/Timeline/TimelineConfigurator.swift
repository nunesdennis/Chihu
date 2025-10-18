//
//  TimelineConfigurator.swift
//  Chihu
//
//  Created by Dennis Nunes on 11/11/24.
//  
//
import SwiftUI

extension TimelineView {
    func configureView() -> some View {
        var view = self
        let interactor = TimelineInteractor()
        let postInteractionInteractor = PostInteractionsInteractor()
        let presenter = TimelinePresenter()
        view.interactor = interactor
        view.postInteractionInteractor = postInteractionInteractor
        interactor.presenter = presenter
        postInteractionInteractor.presenter = presenter
        presenter.view = view
        return view
            .withToast()
            .colorScheme()
    }
}
