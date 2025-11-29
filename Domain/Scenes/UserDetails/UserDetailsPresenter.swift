//
//  UserDetailsPresenter.swift
//  Chihu
//

import Foundation

final class UserDetailsPresenter {
    var view: PostInteractionsDisplayLogic?
}

extension UserDetailsPresenter: PostInteractionsPresentationLogic {
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
