//
//  NotificationsPresenter.swift
//  Chihu
//
//  Created by Dennis Nunes on 11/11/24.
//  
//

import Foundation

protocol NotificationsPresentationLogic {
    func present(response: Notifications.Load.Response)
    func presentMore(response: Notifications.Load.Response)
    func present(error: Error)
    func presentAlert(error: any Error)
}

final class NotificationsPresenter {
    typealias Response = Notifications.Load.Response
    typealias ViewModel = Notifications.Load.ViewModel
    var view: (NotificationsDisplayLogic & PostInteractionsDisplayLogic)?
}

extension NotificationsPresenter: NotificationsPresentationLogic {
    func present(error: any Error) {
        view?.displayError(error)
    }
    
    func present(response: Response) {
        let viewModel = Notifications.Load.ViewModel(response: response)
        Task {
            await view?.display(viewModel: viewModel)
        }
    }
    
    func presentMore(response: Response) {
        let viewModel = Notifications.Load.ViewModel(response: response)
        Task {
            await view?.displayMore(viewModel: viewModel)
        }
    }
    
    func presentAlert(error: any Error) {
        view?.displayAlertError(error)
    }
}

extension NotificationsPresenter: PostInteractionsPresentationLogic {
    func present(response: PostInteraction.Delete.Response) {
        let viewModel = PostInteraction.Delete.ViewModel(post: response.post)
        Task {
            await view?.remove(post: viewModel.post)
        }
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
