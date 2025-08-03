//
//  ProfileInteractor.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 24/08/24.
//  
//

import Foundation

protocol ProfileBusinessLogic {
    func load(request: Profile.Load.Request)
}

final class ProfileInteractor {
    typealias Request = Profile.Load.Request
    typealias Response = Profile.Load.Response
    var presenter: ProfilePresentationLogic?
}

extension ProfileInteractor: ProfileBusinessLogic {
    func load(request: Request) {
        let worker = ProfileNetworkingWorker()
        worker.fetchUser(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                presenter?.present(response:  response)
            case .failure(let error):
                presenter?.present(error: error)
            }
        }
    }
}
