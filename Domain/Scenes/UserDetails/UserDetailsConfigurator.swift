//
//  UserDetailsConfigurator.swift
//  Chihu
//

import SwiftUI

extension UserDetailsView {
    func configureView() -> some View {
        var view = self
        let postInteractionInteractor = PostInteractionsInteractor()
        let presenter = UserDetailsPresenter()
        view.postInteractionInteractor = postInteractionInteractor
        postInteractionInteractor.presenter = presenter
        presenter.view = view
        return view
            .withToast()
            .colorScheme()
    }
}
