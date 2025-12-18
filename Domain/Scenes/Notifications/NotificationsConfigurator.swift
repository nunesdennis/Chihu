//
//  NotificationsConfigurator.swift
//  Chihu
//
//  Created by Dennis Nunes on 11/11/24.
//  
//
import SwiftUI

extension NotificationsView {
    func configureView() -> some View {
        var view = self
        let interactor = NotificationsInteractor()
        let postInteractionInteractor = PostInteractionsInteractor()
        let presenter = NotificationsPresenter()
        view.interactor = interactor
        view.postInteractionInteractor = postInteractionInteractor
        interactor.presenter = presenter
        postInteractionInteractor.presenter = presenter
        presenter.view = view
        return view
            .withToast()
    }
}
