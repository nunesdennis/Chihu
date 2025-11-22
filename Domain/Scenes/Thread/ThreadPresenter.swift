//
//  ThreadPresenter.swift
//  Chihu
//
//  Created by Angela Rosanne Santos de Oliveira on 17/11/25.
//

import Foundation

final class ThreadPresenter {
    var view: PostInteractionsDisplayLogic?
}

extension ThreadPresenter: PostInteractionsPresentationLogic {
    func present(error: any Error) {
        view?.displayError(error)
    }
    
    func present(response: PostInteraction.Repost.Response) {
        let viewModel = PostInteraction.Repost.ViewModel(post: response.post)
        Task {
            await view?.display(post: viewModel.post)
        }
    }
    
    func present(response: PostInteraction.LikeDislike.Response) {
        let viewModel = PostInteraction.LikeDislike.ViewModel(post: response.post)
        Task {
            await view?.display(post: viewModel.post)
        }
    }
}
