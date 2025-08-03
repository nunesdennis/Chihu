//
//  ProfileCell.swift
//  Chihu
//
//  Created by Dennis da Silva Nunes on 14/06/25.
//

import SwiftUI

struct ProfileCell: View {
    
    let viewModel: Profile.Load.ViewModel
    
    var body: some View {
        HStack {
            CachedAsyncImage(url: viewModel.avatar) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                default:
                    Image("ProfileAvatar")
                        .resizable()
                }
            }
            .clipShape(Circle())
            .frame(width: 60, height: 60)
            ProfileText(viewModel: viewModel)
        }
        .padding(5)
    }
}

struct ProfileCell_Previews: PreviewProvider {
    static var previews: some View {
        let user = User(url: "", externalAccount: "username@mastodon.social", displayName: "Display Name Preview", avatar: "", username: "@displayname@preview")
        let viewModel = Profile.Load.ViewModel(user: user)
        
        return ProfileCell(viewModel: viewModel)
    }
}
