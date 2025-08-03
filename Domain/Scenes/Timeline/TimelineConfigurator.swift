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
        let presenter = TimelinePresenter()
        view.interactor = interactor
        interactor.presenter = presenter
        presenter.view = view
        return view.colorScheme()
    }
}
