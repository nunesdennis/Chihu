//
//  ReviewDisplayLogic.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 11/01/25.
//

import Foundation

protocol ReviewDisplayLogic {
    func open(viewModel: Review.LoadSeason.ViewModel)
    func update(rateViewModel: Review.Update.ViewModel?,
                noteViewModel: ProgressNoteList.Update.ViewModel?)
    func display(rateViewModel: Review.Delete.ViewModel?, reviewViewModel: FullReview.Delete.ViewModel?, collectionsItemViewModel: Collections.DeleteItems.ViewModel?)
    func display(rateViewModel: Review.Load.ViewModel?, reviewViewModel: FullReview.Load.ViewModel?)
    func display(rateViewModel: Review.Send.ViewModel?,
                 reviewViewModel: FullReview.Send.ViewModel?,
                 collectionsItemViewModel: Collections.SendItems.ViewModel?,
                 progressNoteListViewModel: ProgressNoteList.Send.ViewModel?)
    func displayPosts(viewModel: CatalogPostsModel.Load.ViewModel)
    func displayError(_ error: Error)
    func displayLoadingError(_ error: Error)
    func displayDeleteError(_ error: Error)
    func displayActionError(_ error: any Error)
}
