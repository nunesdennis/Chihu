//
//  RepostCellNotification.swift
//  Chihu
//

import SwiftUI
import UIKit
import TootSDK
import HTML2Markdown
import MarkdownUI
import Translation

protocol RepostCellNotificationDelegate {
    func didClick(on post: Post)
    func didClick(on account: Account)
    func handleURL(_ url: URL)
}

@MainActor
struct RepostCellNotification: View {
    @Environment(\.colorScheme) private var colorScheme
    
    private let notification: TootNotification
    private let delegate: RepostCellNotificationDelegate
    
    // MARK: - Init
    init(notification: TootNotification,
         delegate: RepostCellNotificationDelegate) {
        self.delegate = delegate
        self.notification = notification
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            HStack {
                cell(from: notification)
                Spacer()
                VStack(alignment: .center) {
                    Image(systemName: "chevron.up")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                        .foregroundColor(buttonColor(isHighlighted: false))
                        .padding(8)
                }
                .frame(width: 30)
                .onTapGesture {
                    if let post = notification.post {
                        delegate.didClick(on: post)
                    } else {
                        // error
                    }
                }
            }
        }
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
                Image(systemName: "repeat")
                    .resizable()
                    .foregroundStyle(Color.timelineCellRepostIconColor)
                    .frame(width: 15, height: 15)
                    .background(Color.chihuClear)
                Text("Reposted your post:")
                    .font(.body)
                    .foregroundColor(.chihuBlack)
            }
            
            if let post = notificatin.post {
                cellContent(from: post)
            }
        }
    }
    
    private func buttonColor(isHighlighted: Bool) -> Color {
        isHighlighted ? .timelineButtonCellHighlightedColor : .timelineButtonCellNormalColor
    }
    
    func cellContent(from post: Post) -> some View {
        parseHTML(from: post)
            .environment(
                \.openURL,
                 OpenURLAction { url in
                     delegate.handleURL(url)
                     return .handled
                 }
            )
    }
    
    func parseHTML(from post: Post) -> some View {
        guard let content = post.content,
              let html = try? HTMLParser().parse(html: content) else {
            return Markdown("").markdownTextStyle(\.text) {
                ForegroundColor(.chihuGray)
                BackgroundColor(.chihuClear)
            }
        }
        
        let markdown = html.toMarkdown(options: .unorderedListBullets)
        
        return Markdown(markdown)
            .markdownTextStyle(\.text) {
                ForegroundColor(.chihuGray)
                BackgroundColor(.chihuClear)
        }
    }
}
