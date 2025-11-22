//
//  ThreadConfigurator.swift
//  Chihu
//

import SwiftUI

extension ThreadView {
    func configureView() -> some View {
        var view = self
        let postInteractionInteractor = PostInteractionsInteractor()
        let presenter = ThreadPresenter()
        view.postInteractionInteractor = postInteractionInteractor
        postInteractionInteractor.presenter = presenter
        presenter.view = view
        return view
            .withToast()
            .colorScheme()
    }
}
