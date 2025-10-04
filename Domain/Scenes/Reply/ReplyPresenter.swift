//
//  NewCollectionPresenter.swift
//  Chihu
//
//  Created by Dennis Nunes on 31/01/25.
//  
//
import Foundation

protocol ReplyPresentationLogic {
    func present(response: Reply.Update.Response)
    func present(response: Reply.Send.Response)
    func present(error: Error)
}

final class ReplyPresenter {
    var view: ReplyDisplayLogic?
}

extension ReplyPresenter: ReplyPresentationLogic {
    func present(response: Reply.Update.Response) {
        let viewModel = Reply.Update.ViewModel(replyModel: response.replyModel)
        Task {
            await view?.display(viewModel: viewModel)
        }
    }
    
    func present(response: Reply.Send.Response) {
        let viewModel = Reply.Send.ViewModel(replyModel: response.replyModel)
        Task {
            await view?.display(viewModel: viewModel)
        }
    }
    
    func present(error: any Error) {
        view?.displayError(error)
    }
}
