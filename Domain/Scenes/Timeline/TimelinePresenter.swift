//
//  TimelinePresenter.swift
//  Chihu
//
//  Created by Dennis Nunes on 11/11/24.
//  
//

import Foundation

protocol TimelinePresentationLogic {
    func present(response: Timeline.Load.Response)
    func presentMore(response: Timeline.Load.Response)
    func present(error: Error)
    func presentAlert(error: any Error)
}

final class TimelinePresenter {
    typealias Response = Timeline.Load.Response
    typealias ViewModel = Timeline.Load.ViewModel
    var view: (TimelineDisplayLogic & PostInteractionsDisplayLogic)?
}

extension TimelinePresenter: TimelinePresentationLogic {
    func present(error: any Error) {
        view?.displayError(error)
    }
    
    func present(response: Response) {
        let viewModel = Timeline.Load.ViewModel(response: response)
        Task {
            await view?.display(viewModel: viewModel)
        }
    }
    
    func presentMore(response: Response) {
        let viewModel = Timeline.Load.ViewModel(response: response)
        Task {
            await view?.displayMore(viewModel: viewModel)
        }
    }
    
    func presentAlert(error: any Error) {
        view?.displayAlertError(error)
    }
}

extension TimelinePresenter: PostInteractionsPresentationLogic {
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

extension TimelinePresenter: ReviewPresentationLogic {
    func presentSilentError(error: any Error) {
        // no-op
    }
    
    func presentPosts(response: CatalogPostsModel.Load.Response) {
        // no-op
    }
    
    func update(rateResponse: Review.Update.Response?, noteResponse: ProgressNoteList.Update.Response?) {
        // no-op
    }
    
    func open(response: Review.LoadSeason.Response) {
        // no-op
    }
    
    func presentActionError(error: any Error) {
        // no-op
    }
    
    func present(rateResponse: Review.Delete.Response?,
                 reviewResponse: FullReview.Delete.Response?,
                 collectionItemResponse: Collections.DeleteItems.Response?) {
        // no-op
    }
    
    func present(rateResponse: Review.Delete.Response?, reviewResponse: FullReview.Delete.Response?) {
        // no-op
    }
    
    func present(rateResponse: Review.Load.Response?, reviewResponse: FullReview.Load.Response?) {
        // no-op
    }
    
    func presentDelete(error: any Error) {
        // no-op
    }
    
    func presentLoading(error: any Error) {
        // no-op
    }
    
    func present(rateResponse: Review.Send.Response?,
                 reviewResponse: FullReview.Send.Response?,
                 collectionItemResponse: Collections.SendItems.Response?,
                 progressNoteListResponse: ProgressNoteList.Send.Response?) {
        guard let rateResponse else {
            view?.displayError(ChihuError.unknown)
            return
        }
        let viewModel = Review.Send.ViewModel(message: rateResponse.message)
        view?.display(viewModel: viewModel)
    }
}
