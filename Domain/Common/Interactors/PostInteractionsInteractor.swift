//
//  PostInteractionsInteractor.swift
//  Chihu
//
//  Created by Angela Rosanne Santos de Oliveira on 18/10/25.
//

import Foundation

protocol PostInteractionsBusinessLogic {
    func likeDislike(request: PostInteraction.LikeDislike.Request)
}

final class PostInteractionsInteractor {
    var presenter: PostInteractionsPresentationLogic?
}

extension PostInteractionsInteractor: PostInteractionsBusinessLogic {
    func likeDislike(request: PostInteraction.LikeDislike.Request) {
        let worker = PostInteractionsNetworkingWorker()
        Task(priority: .background) {
            await worker.likeDislikePost(request: request) { [unowned self] result in
                switch result {
                case .success(let response):
                    presenter?.present(response:  response)
                case .failure(let error):
                    presenter?.present(error: error)
                }
            }
        }
    }
}
