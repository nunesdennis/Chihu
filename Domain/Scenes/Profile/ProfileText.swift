//
//  ProfileText.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 24/08/24.
//

import Foundation
import SwiftUI

struct ProfileText: View {
    let viewModel: Profile.Load.ViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(viewModel.displayName)
                .bold()
                .font(.headline)
                .foregroundColor(.profileDisplayNameColor)
            Text(viewModel.username)
                .font(.subheadline)
                .foregroundColor(.profileUsernameColor)
            if let externalAccount = viewModel.externalAccount {
                Text(externalAccount)
                    .font(.subheadline)
                    .foregroundColor(.profileUsernameColor)
            }
        }
    }
}

struct ProfileText_Previews: PreviewProvider {
    static var previews: some View {
        let user = User(url: "", externalAccount: "username@mastodon.social", displayName: "Display Name Preview", avatar: "", username: "@displayname@preview")
        let viewModel = Profile.Load.ViewModel(user: user)
        
        return ProfileText(viewModel: viewModel)
    }
}
