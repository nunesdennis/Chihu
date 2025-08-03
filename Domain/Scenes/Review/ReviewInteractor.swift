//
//  ReviewInteractor.swift
//  Chihu
//
//  Created by Dennis Nunes on 10/09/24.
//
//

import Foundation

protocol ReviewBusinessLogic {
    // rate
    func sendRate(request: Review.Send.Request)
    func deleteRate(request: Review.Delete.Request)
    func loadRate(request: Review.Load.Request)
    func loadSeason(request: Review.LoadSeason.Request)
    func update(request: Review.Update.Request)
    // review
    func loadReview(request: FullReview.Load.Request)
    func deleteReview(request: FullReview.Delete.Request)
    func sendReview(request: FullReview.Send.Request)
    // collection
    func sendItemToCollection(request: Collections.SendItems.Request)
    func deleteItemInCollection(request: Collections.DeleteItems.Request)
    // Note
    func sendNoteToItem(request: ProgressNoteList.Send.Request)
    func updateNote(request: ProgressNoteList.Update.Request)
    // Catalog Posts
    func loadPosts(request: CatalogPostsModel.Load.Request)
}

final class ReviewInteractor {
    var presenter: ReviewPresentationLogic?
}

extension ReviewInteractor: ReviewBusinessLogic {
    func updateNote(request: ProgressNoteList.Update.Request) {
        let worker = ProgressNoteListNetworkingWorker()
        worker.updateNote(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                presenter?.update(rateResponse: nil,
                                  noteResponse: response)
            case .failure(let error):
                presenter?.presentActionError(error: error)
            }
        }
    }
    
    func sendNoteToItem(request: ProgressNoteList.Send.Request) {
        let worker = ProgressNoteListNetworkingWorker()
        worker.sendNoteToItem(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                presenter?.present(rateResponse: nil,
                                   reviewResponse: nil,
                                   collectionItemResponse: nil,
                                   progressNoteListResponse: response)
            case .failure(let error):
                presenter?.presentActionError(error: error)
            }
        }
    }
    
    // Rate
    func deleteRate(request: Review.Delete.Request) {
        let worker = ReviewNetworkingWorker()
        worker.deleteRateItem(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                presenter?.present(rateResponse:  response, reviewResponse: nil, collectionItemResponse: nil)
            case .failure(let error):
                presenter?.presentDelete(error: error)
            }
        }
    }
    
    func loadRate(request: Review.Load.Request) {
        let worker = ReviewNetworkingWorker()
        worker.fetchRateItem(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                presenter?.present(rateResponse:  response, reviewResponse: nil)
            case .failure(let error):
                presenter?.presentLoading(error: error)
            }
        }
    }
    
    func loadSeason(request: Review.LoadSeason.Request) {
        let worker = CatalogNetworkingWorker()
        worker.fetchWithApiURL(request.apiURL, itemClass: TVShowSchema.self) { [unowned self] result in
            switch result {
            case .success(let item):
                let response = Review.LoadSeason.Response(item: item)
                presenter?.open(response: response)
            case .failure(let error):
                presenter?.presentLoading(error: error)
            }
        }
    }
    
    func update(request: Review.Update.Request) {
        let worker = CatalogNetworkingWorker()
        worker.fetchWithApiURL(request.apiURL, itemClass: request.itemClass) { [unowned self] result in
            switch result {
            case .success(let item):
                let response = Review.Update.Response(item: item)
                presenter?.update(rateResponse: response,
                                  noteResponse: nil)
            case .failure(let error):
                presenter?.presentLoading(error: error)
            }
        }
    }
    
    func sendRate(request: Review.Send.Request) {
        let worker = ReviewNetworkingWorker()
        worker.rateItem(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                presenter?.present(rateResponse: response,
                                   reviewResponse: nil,
                                   collectionItemResponse: nil,
                                   progressNoteListResponse: nil)
            case .failure(let error):
                presenter?.present(error: error)
            }
        }
    }
    
    // Review
    func deleteReview(request: FullReview.Delete.Request) {
        let worker = ReviewNetworkingWorker()
        worker.deleteReviewItem(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                presenter?.present(rateResponse:  nil, reviewResponse: response, collectionItemResponse: nil)
            case .failure(let error):
                presenter?.presentDelete(error: error)
            }
        }
    }
    
    func loadReview(request: FullReview.Load.Request) {
        let worker = ReviewNetworkingWorker()
        worker.fetchReviewItem(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                presenter?.present(rateResponse: nil, reviewResponse:  response)
            case .failure(let error):
                presenter?.presentLoading(error: error)
            }
        }
    }
    
    func sendReview(request: FullReview.Send.Request) {
        let worker = ReviewNetworkingWorker()
        worker.reviewItem(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                presenter?.present(rateResponse:  nil,
                                   reviewResponse: response,
                                   collectionItemResponse: nil,
                                   progressNoteListResponse: nil)
            case .failure(let error):
                presenter?.present(error: error)
            }
        }
    }
    
    // Collections
    func sendItemToCollection(request: Collections.SendItems.Request) {
        let worker = CollectionsNetworkingWorker()
        worker.sendItemToCollection(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                presenter?.present(rateResponse:  nil,
                                   reviewResponse: nil,
                                   collectionItemResponse: response,
                                   progressNoteListResponse: nil)
            case .failure(let error):
                presenter?.present(error: error)
            }
        }
    }
    
    func deleteItemInCollection(request: Collections.DeleteItems.Request) {
        let worker = CollectionsNetworkingWorker()
        worker.deleteItemInCollection(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                presenter?.present(rateResponse:  nil, reviewResponse: nil, collectionItemResponse: response)
            case .failure(let error):
                presenter?.present(error: error)
            }
        }
    }
    
    // Catalog posts
    func loadPosts(request: CatalogPostsModel.Load.Request) {
        let worker = CatalogNetworkingWorker()
        worker.fetchPosts(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                presenter?.presentPosts(response: response)
            case .failure(let error):
                presenter?.presentLoading(error: error)
            }
        }
    }
}
