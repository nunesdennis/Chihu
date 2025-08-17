//
//  ProfileInteractor.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 24/08/24.
//  
//

import Foundation
import TootSDK

protocol ProfileBusinessLogic {
    func load(request: Profile.Load.Request)
    func updateAvatar(request: Profile.UpdateAvatar.Request)
}

final class ProfileInteractor {
    typealias Request = Profile.Load.Request
    typealias Response = Profile.Load.Response
    typealias UpdateAvatarRequest = Profile.UpdateAvatar.Request
    typealias UpdateAvatarResponse = Profile.UpdateAvatar.Response
    var presenter: ProfilePresentationLogic?
}

extension ProfileInteractor: ProfileBusinessLogic {
    func load(request: Request) {
        let worker = ProfileNetworkingWorker()
        worker.fetchUser(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                presenter?.present(response: response)
            case .failure(let error):
                presenter?.present(error: error)
            }
        }
    }
    
    func updateAvatar(request: UpdateAvatarRequest) {
        let worker = UpdateAvatarNetworkingWorker()
        worker.updateAvatar(request: request) { [unowned self] result in
            switch result {
            case .success(let response):
                presenter?.presentAvatarUpdate(response: response)
            case .failure(let error):
                presenter?.present(error: error)
            }
        }
    }
}
