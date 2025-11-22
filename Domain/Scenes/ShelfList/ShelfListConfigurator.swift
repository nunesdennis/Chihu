//
//  ShelfListConfigurator.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 31/08/24.
//  
//

import SwiftUI

extension ShelfListFilterView {
    func configureView() -> some View {
        var view = self
        let interactor = ShelfListInteractor()
        let presenter = ShelfListPresenter()
        view.interactor = interactor
        interactor.presenter = presenter
        presenter.view = view
        return view
    }
}
