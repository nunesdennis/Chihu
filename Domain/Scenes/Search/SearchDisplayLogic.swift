//
//  SearchDisplayLogic.swift
//  Chihu
//
//  Created by Dennis Nunes on 24/12/24.
//

protocol SearchDisplayLogic {
    func displayResultFromGoogleBooksName(viewModel: SearchByNameGoogleBooks.Load.ViewModel)
    func displayResultFromPIname(viewModel: SearchByNamePI.Load.ViewModel)
    func displayResultFromTMDBname(viewModel: SearchByNameTMDB.Load.ViewModel)
    func displayResultFromName(viewModel: SearchByName.Load.ViewModel)
    func displayResultFromURL(viewModel: SearchByURL.Load.ViewModel)
    func openResultFromURL(viewModel: SearchByURL.Load.ViewModel)
    func displayError(_ error: Error)
}
