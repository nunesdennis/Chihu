//
//  UpdateAvatarNetworkingWorker.swift
//  Chihu
//
//  Created by Assistant on 2024.
//

import Foundation
import TootSDK

protocol UpdateAvatarNetworkingProtocol {
    func updateAvatar(request: Profile.UpdateAvatar.Request, completion: @escaping (Result<Profile.UpdateAvatar.Response, Error>) -> Void)
}

final class UpdateAvatarNetworkingWorker: UpdateAvatarNetworkingProtocol {
    // MARK: - Properties
    var apiClient: APIClientProtocol
    
    // MARK: - Initialization
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    // MARK: - Public Methods
    func updateAvatar(request: Profile.UpdateAvatar.Request, completion: @escaping (Result<Profile.UpdateAvatar.Response, Error>) -> Void) {
        guard let instanceURLString = UserSettings.shared.instanceURL,
              let instanceURL = URL(string: instanceURLString),
              let accessToken = UserSettings.shared.accessToken else {
            completion(.failure(NSError(domain: "UpdateAvatarNetworkingWorker", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing instance URL or access token"])))
            return
        }
        
        Task {
            do {
                let client = try await TootClient(connect: instanceURL, accessToken: accessToken)
                let oldUser = UserSettings.shared.profileInfo
                var params = UpdateCredentialsParams()
                params.avatar = request.imageData
                params.avatarMimeType = "image/jpeg"
                
                let updatedAccount = try await client.updateCredentials(params: params)
                
                // Convert TootSDK Account to our User model
                let user = User(
                    url: oldUser?.url?.absoluteString ?? updatedAccount.url,
                    externalAccount: oldUser?.externalAccount ?? updatedAccount.acct,
                    displayName: oldUser?.displayName ?? updatedAccount.displayName ?? "",
                    avatar: updatedAccount.avatar,
                    username: oldUser?.username ?? updatedAccount.username ?? ""
                )
                
                let response = Profile.UpdateAvatar.Response(user: user)
                
                await MainActor.run {
                    completion(.success(response))
                }
                
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }
}
