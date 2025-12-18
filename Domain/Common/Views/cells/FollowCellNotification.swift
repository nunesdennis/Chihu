//
//  FollowCellNotification.swift
//  Chihu
//
//  Created by Angela Rosanne Santos de Oliveira on 17/12/25.
//

import SwiftUI
import UIKit
import TootSDK
import HTML2Markdown
import MarkdownUI
import Translation

protocol FollowCellNotificationDelegate {
    func didClick(on account: Account)
}

@MainActor
struct FollowCellNotification: View {
    @Environment(\.colorScheme) private var colorScheme
    
    private let notification: TootNotification
    private let delegate: FollowCellNotificationDelegate
    
    // MARK: - Init
    init(notification: TootNotification,
         delegate: FollowCellNotificationDelegate) {
        self.delegate = delegate
        self.notification = notification
    }
    
    // MARK: - Body
    var body: some View {
        cell(from: notification)
        .listRowBackground(Color.timelineCellBackgroundColor)
    }
        
    var loadableAvatarImage: some View {
        CachedAsyncImage(url: URL(string: notification.account.avatar)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
            default:
                Image("ProfileAvatar").resizable()
            }
        }
        .scaledToFit()
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.primary.opacity(0.25), lineWidth: 1)
        )
        .frame(width: 40, height: 40)
        .onTapGesture {
            delegate.didClick(on: notification.account)
        }
    }
        
    func cell(from notificatin: TootNotification) -> some View {
        VStack(alignment: .leading) {
            HStack {
                loadableAvatarImage
                VStack(alignment: .leading) {
                    if let displayName = notification.account.displayName {
                        Text(displayName)
                            .font(.headline)
                            .foregroundColor(.chihuBlack)
                    }
                    Text(notificatin.account.acct)
                        .font(.body)
                        .foregroundColor(.chihuGray)
                }
                .padding(5)
            }
            HStack {
                Image(systemName: "person.crop.circle.fill.badge.checkmark")
                    .resizable()
                    .foregroundStyle(Color.timelineButtonCellHighlightedColor)
                    .frame(width: 25, height: 20)
                    .background(Color.chihuClear)
                Text("Followed you")
                    .font(.body)
                    .foregroundColor(.chihuBlack)
            }
        }
    }
}
