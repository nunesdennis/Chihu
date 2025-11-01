//
//  ReviewPresenter.swift
//  Chihu
//
//  Created by Dennis Nunes on 10/09/24.
//  
//
import Foundation

protocol ReviewPresentationLogic {
    func update(rateResponse: Review.Update.Response?,
                noteResponse: ProgressNoteList.Update.Response?)
    func open(response: Review.LoadSeason.Response)
    func present(rateResponse: Review.Delete.Response?,
                 reviewResponse: FullReview.Delete.Response?,
                 collectionItemResponse: Collections.DeleteItems.Response?)
    func present(rateResponse: Review.Load.Response?, reviewResponse: FullReview.Load.Response?)
    func present(rateResponse: Review.Send.Response?,
                 reviewResponse: FullReview.Send.Response?,
                 collectionItemResponse: Collections.SendItems.Response?,
                 progressNoteListResponse: ProgressNoteList.Send.Response?)
    func presentPosts(response: CatalogPostsModel.Load.Response)
    func present(error: Error)
    func presentDelete(error: Error)
    func presentLoading(error: Error)
    func presentSilentError(error: Error)
    func presentActionError(error: Error)
}

final class ReviewPresenter {
    var view: (ReviewDisplayLogic & PostInteractionsDisplayLogic)?
}

extension ReviewPresenter: PostInteractionsPresentationLogic {
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

extension ReviewPresenter: ReviewPresentationLogic {
    func update(rateResponse: Review.Update.Response?,
                noteResponse: ProgressNoteList.Update.Response?) {
        if let item = rateResponse?.item {
            let viewModel = Review.Update.ViewModel(item: item)
            view?.update(rateViewModel: viewModel, noteViewModel: nil)
        } else if let note = noteResponse?.note {
            let viewModel = ProgressNoteList.Update.ViewModel(note: note)
            view?.update(rateViewModel: nil, noteViewModel: viewModel)
        }
    }
    
    func presentActionError(error: any Error) {
        view?.displayActionError(error)
    }
    
    func presentDelete(error: any Error) {
        view?.displayDeleteError(error)
    }
    
    func present(rateResponse: Review.Delete.Response?, reviewResponse: FullReview.Delete.Response?, collectionItemResponse: Collections.DeleteItems.Response?) {
        if let rateResponse {
            let viewModel = Review.Delete.ViewModel(message: rateResponse.message)
            view?.display(rateViewModel: viewModel, reviewViewModel: nil, collectionsItemViewModel: nil)
        } else if let reviewResponse {
            let viewModel = FullReview.Delete.ViewModel(message: reviewResponse.message)
            view?.display(rateViewModel: nil, reviewViewModel: viewModel, collectionsItemViewModel: nil)
        } else if let collectionItemResponse {
            let viewModel = Collections.DeleteItems.ViewModel(message: collectionItemResponse.message)
            view?.display(rateViewModel: nil, reviewViewModel: nil, collectionsItemViewModel: viewModel)
        }
    }
    
    func presentSilentError(error: any Error) {
        view?.displaySilentError(error)
    }
    
    func presentLoading(error: any Error) {
        view?.displayLoadingError(error)
    }
    
    func open(response: Review.LoadSeason.Response) {
        let viewModel = Review.LoadSeason.ViewModel(item: response.item)
        view?.open(viewModel: viewModel)
    }
    
    func present(rateResponse: Review.Load.Response?, reviewResponse: FullReview.Load.Response?) {
        if let rateResponse {
            let viewModel = Review.Load.ViewModel(shelfItem: rateResponse.shelfItem)
            view?.display(rateViewModel: viewModel, reviewViewModel: nil)
        } else if let reviewResponse {
            let viewModel = FullReview.Load.ViewModel(shelfItem: reviewResponse.shelfItem)
            view?.display(rateViewModel: nil, reviewViewModel: viewModel)
        }
    }
    
    func present(error: any Error) {
        view?.displayError(error)
    }
    
    func presentPosts(response: CatalogPostsModel.Load.Response) {
        let viewModel = CatalogPostsModel.Load.ViewModel(posts: response.posts)
        view?.displayPosts(viewModel: viewModel)
    }
    
    func present(rateResponse: Review.Send.Response?,
                 reviewResponse: FullReview.Send.Response?,
                 collectionItemResponse: Collections.SendItems.Response?,
                 progressNoteListResponse: ProgressNoteList.Send.Response?) {
        if let rateResponse {
            let viewModel = Review.Send.ViewModel(message: rateResponse.message)
            view?.display(rateViewModel: viewModel,
                          reviewViewModel: nil,
                          collectionsItemViewModel: nil,
                          progressNoteListViewModel: nil)
        } else if let reviewResponse {
            let viewModel = FullReview.Send.ViewModel(message: reviewResponse.message)
            view?.display(rateViewModel: nil,
                          reviewViewModel: viewModel,
                          collectionsItemViewModel: nil,
                          progressNoteListViewModel: nil)
        } else if let collectionItemResponse {
            let viewModel = Collections.SendItems.ViewModel(message: collectionItemResponse.message)
            view?.display(rateViewModel: nil,
                          reviewViewModel: nil,
                          collectionsItemViewModel: viewModel,
                          progressNoteListViewModel: nil)
        } else if let progressNoteListResponse {
            let viewModel = ProgressNoteList.Send.ViewModel(note: progressNoteListResponse.note)
            view?.display(rateViewModel: nil,
                         reviewViewModel: nil,
                         collectionsItemViewModel: nil,
                         progressNoteListViewModel: viewModel)
        }
    }
}
