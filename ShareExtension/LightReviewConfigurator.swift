//
//  LightReviewConfigurator.swift
//  Chihu
//
//

import SwiftUI

extension LightReviewView {
    func configureView() -> some View {
        var view = self
        let interactor = ReviewInteractor()
        let presenter = ReviewPresenter()
        view.interactor = interactor
        interactor.presenter = presenter
        presenter.view = view
        return view
            .colorScheme()
    }
}
