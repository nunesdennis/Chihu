//
//  ProgressNoteListConfigurator.swift
//  Chihu
//
//  Created by Dennis Nunes on 14/02/25.
//  
//
import SwiftUI

extension SimpleProgressNoteListView {
    func configureView() -> some View {
        var view = self
        let interactor = ProgressNoteListInteractor()
        let presenter = ProgressNoteListPresenter()
        view.interactor = interactor
        interactor.presenter = presenter
        presenter.view = view
        return view.colorScheme()
    }
}
