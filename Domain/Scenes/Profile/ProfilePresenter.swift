//
//  ProfilePresenter.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 24/08/24.
//  
//

import Foundation
import SwiftUI

protocol ProfilePresentationLogic {
    func present(response: Profile.Load.Response)
    func presentAvatarUpdate(response: Profile.UpdateAvatar.Response)
    func present(error: Error)
}

final class ProfilePresenter {
    typealias Response = Profile.Load.Response
    typealias ViewModel = Profile.Load.ViewModel
    typealias UpdateAvatarResponse = Profile.UpdateAvatar.Response
    typealias UpdateAvatarViewModel = Profile.Load.ViewModel
    var view: ProfileDisplayLogic?
}

extension ProfilePresenter: ProfilePresentationLogic {
    func present(error: any Error) {
        view?.displayError(error)
    }
    
    func present(response: Response) {
        let viewModel = Profile.Load.ViewModel(user: response.user)
        view?.display(viewModel: viewModel)
    }
    
    func presentAvatarUpdate(response: UpdateAvatarResponse) {
        let viewModel = Profile.Load.ViewModel(user: response.user)
        view?.displayAvatarUpdate(viewModel: viewModel)
    }
}
