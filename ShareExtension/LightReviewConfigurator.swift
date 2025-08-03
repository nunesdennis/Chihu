//
//  LightReviewConfigurator.swift
//  Chihu
//
//  Created by Dennis Nunes on 27/12/24.
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
    }
}
