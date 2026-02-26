//
//  NotificationsConfigurator.swift
//  Chihu
//
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
