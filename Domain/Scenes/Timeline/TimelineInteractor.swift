//
//  TimelineInteractor.swift
//  Chihu
//
//  Created by Dennis Nunes on 11/11/24.
//  
//
import Foundation

protocol TimelineBusinessLogic {
    func load(request: Timeline.Load.Request)
    func loadMore(request: Timeline.Load.Request)
}

final class TimelineInteractor {
    typealias Request = Timeline.Load.Request
    typealias Response = Timeline.Load.Response
    var presenter: (TimelinePresentationLogic & ReviewPresentationLogic)?
}

extension TimelineInteractor: TimelineBusinessLogic {
    func load(request: Request) {
        let worker = TimelineNetworkingWorker()
        Task(priority: .background) {
            await worker.fetchPosts(request: request) { [unowned self] result in
                switch result {
                case .success(let response):
                    presenter?.present(response:  response)
                case .failure(let error):
                    presenter?.present(error: error)
                }
            }
        }
    }
    
    func loadMore(request: Request) {
        let worker = TimelineNetworkingWorker()
        Task(priority: .background) {
            await worker.fetchPosts(request: request) { [unowned self] result in
                switch result {
                case .success(let response):
                    presenter?.presentMore(response:  response)
                case .failure(let error):
                    presenter?.present(error: error)
                }
            }
        }
    }
}

extension TimelineInteractor: ReviewBusinessLogic {
    func loadPosts(request: CatalogPostsModel.Load.Request) {
        // no-op
    }
    
    func update(request: Review.Update.Request) {
        // no-op
    }
    
    func updateNote(request: ProgressNoteList.Update.Request) {
        // no-op
    }
    
    func loadSeason(request: Review.LoadSeason.Request) {
        // no-op
    }
    
    func sendNoteToItem(request: ProgressNoteList.Send.Request) {
        // no-op
    }
    
    func deleteItemInCollection(request: Collections.DeleteItems.Request) {
        // no-op
    }
    
    func sendItemToCollection(request: Collections.SendItems.Request) {
        // no-op
    }
    
    func deleteReview(request: FullReview.Delete.Request) {
        // no-op
    }
    
    func sendReview(request: FullReview.Send.Request) {
        // no-op
    }
    
    func deleteRate(request: Review.Delete.Request) {
        // no-op
    }
    
    func loadRate(request: Review.Load.Request) {
        // no-op
    }
    
    func loadReview(request: FullReview.Load.Request) {
        // no-op
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
                presenter?.presentAlert(error: error)
            }
        }
    }
}
