//
//  CellTimeline.swift
//  Chihu
//
//  Created by Dennis Nunes on 12/11/24.
//

import SwiftUI
import UIKit
import TootSDK
import HTML2Markdown
import MarkdownUI
import Translation

protocol CellTimelineDelegate {
    func handleURL(_ url: URL)
    func didClick(on account: Account)
    func didClick(on post: Post)
    func didPressLike(on post: Post)
    func didPressDelete(on post: Post)
    func didPressReply(on post: Post)
    func didPressRepost(on post: Post)
    func didPressUpdate(on post: Post)
    func editError()
}

@MainActor
struct CellTimeline: View {
    @State var sensitive: Bool
    @State var showSpoilerEffect: Bool
    @State var showTranslation: Bool = false
    @State var neoDBurlReady: Bool = false
    
    @State var image: Image?
    
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) private var colorScheme
    
    private var sourceText: String {
        if let content = post.content {
            return TootHTML.extractAsPlainText(html: content) ?? String()
        }
        
        return String()
    }
    
    private var itemUrl: URL?
    private var postPreviews = PostPreviewSingleton.shared
    private var avatarImage: Image?
    private var shouldShowPreview: Bool
    private var showUserInfo: Bool
    private var showThreadButton: Bool
    private var isMyPost: Bool {
        isMyUsername(postUsername: post.account.acct)
    }
    
    private let post: Post
    private let delegate: CellTimelineDelegate
    
    // MARK: - Init
    init(post: Post,
         image: ImageState?,
         avatarImage: ImageState?,
         itemURL: String? = nil,
         showThreadButton: Bool = false,
         showUserInfo: Bool = true,
         delegate: CellTimelineDelegate) {
        self._sensitive = State(initialValue: post.sensitive)
        self._showSpoilerEffect = State(initialValue: post.sensitive)
        
        self.showUserInfo = showUserInfo
        self.shouldShowPreview = (image ?? .needsLoading) != .none
        self.delegate = delegate
        self.post = post
        self.showThreadButton = showThreadButton
        self.image = get(image, of: .poster)
        self.avatarImage = get(avatarImage ?? ImageState.none, of: .avatar)
    }
    
    // MARK: - Body
    var body: some View {
        if #available(iOS 18.0, *) {
            cellView
                .translationPresentation(isPresented: $showTranslation, text: sourceText)
        } else {
            cellView
        }
    }
    
    var cellView: some View {
        VStack {
            HStack {
                if post.repost != nil {
                    repost(from: post)
                } else {
                    account(from: post)
                }
                if neoDBurlReady {
                    Spacer()
                    loadablePostImage
                } else {
                    Spacer()
                }
                if showThreadButton {
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
                        delegate.didClick(on: post.repost ?? post)
                    }
                }
            }
            menu
        }
        .listRowBackground(Color.timelineCellBackgroundColor)
        .task {
            if let itemUrl = NeoDBURL.getItemURL(from: post), shouldShowPreview {
                neoDBurlReady = true
                if let cachedImage = ImageCache[itemUrl] {
                    self.image = cachedImage
                } else {
                    do {
                        let uiimage = try await LPLoader.createPoster(from: post.id, for: itemUrl)
                        self.image = Image(uiImage: uiimage)
                    } catch {
                        print("error loading image")
                        self.image = .none
                    }
                }
            }
        }
    }
    
    var menu: some View {
        HStack(alignment: .center) {
            likeButton
            replyButton
            repostButton
            if isMyPost {
                editButton
            }
            if isMyPost {
                deleteButton
            }
            if #available(iOS 18.0, *) {
                translateButton
            }
            if post.url != nil {
                externalLinkButton
            }
            //            Menu {
            //
            //            } label: {
            //              Label("", systemImage: "ellipsis")
            //                .padding(.vertical, 6)
            //            }
            //            .menuStyle(.button)
            //            .buttonStyle(.borderless)
            //            .foregroundStyle(.secondary)
            //            .contentShape(Rectangle())
        }
        .frame(height: 30)
    }
    
    var deleteButton: some View {
        HStack {
            Image(systemName: "trash")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .foregroundColor(buttonColor(isHighlighted: false))
        .onTapGesture {
            delegate.didPressDelete(on: post)
        }
    }
    
    var likeButton: some View {
        HStack {
            Image(systemName: heartEmoji(isHighlighted: post.favourited ?? false))
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if post.favouritesCount > 0 {
                Spacer().frame(width: 1)
                Text("\(post.favouritesCount)")
                Spacer()
            }
        }
        .foregroundColor(buttonColor(isHighlighted: post.favourited ?? false))
        .onTapGesture {
            delegate.didPressLike(on: post)
        }
    }
    
    var repostButton: some View {
        HStack {
            Image(systemName: "arrow.2.squarepath")
                .resizable()
                .scaledToFit()
                .frame(width: 23, height: 23)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if post.repostsCount > 0 {
                Spacer().frame(width: 1)
                Text("\(post.repostsCount)")
                Spacer()
            }
        }
        .foregroundColor(buttonColor(isHighlighted: post.reposted ?? false))
        .onTapGesture {
            delegate.didPressRepost(on: post)
        }
    }
    
    var replyButton: some View {
        HStack {
            Image(systemName: "bubble.left")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if post.repliesCount > 0 {
                Spacer().frame(width: 1)
                Text("\(post.repliesCount)")
                Spacer()
            }
        }
        .foregroundColor(buttonColor(isHighlighted: false))
        .onTapGesture {
            delegate.didPressReply(on: post)
        }
    }
    
    var externalLinkButton: some View {
        Image(systemName: "arrow.up.right.square")
            .resizable()
            .scaledToFit()
            .foregroundColor(buttonColor(isHighlighted: false))
            .frame(width: 20, height: 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture {
                if let urlString = post.url,
                   let url = URL(string: urlString) {
                    openURL(url)
                }
            }
    }
    
    var editButton: some View {
        Image(systemName: "pencil.circle")
            .resizable()
            .scaledToFit()
            .foregroundColor(buttonColor(isHighlighted: false))
            .frame(width: 20, height: 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture {
                if let url = itemUrl {
                    delegate.handleURL(url)
                } else {
                    delegate.didPressUpdate(on: post)
                }
            }
    }
    
    @available(iOS 18.0, *)
    var translateButton: some View {
        Image(systemName: "t.bubble")
            .resizable()
            .scaledToFit()
            .foregroundColor(buttonColor(isHighlighted: false))
            .frame(width: 22, height: 22)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture {
                showTranslation.toggle()
            }
    }
    
    var loadablePostImage: some View {
        CachedAsyncImage(url: getPostPreviewUrl(from: post)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
            default:
                if let image {
                    image
                        .resizable()
                } else {
                    Image("ImagePlaceHolder").resizable()
                }
            }
        }
        .aspectRatio(contentMode: .fit)
        .frame(width: 75, height: 150)
        .cornerRadius(2)
    }
    
    var loadableAvatarImage: some View {
        CachedAsyncImage(url: getAvatarUrl(from: post.repost ?? post)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
            default:
                if let avatarImage {
                    avatarImage
                        .resizable()
                } else {
                    Image("ProfileAvatar").resizable()
                }
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
            delegate.didClick(on: post.account)
        }
    }
    
    func heartEmoji(isHighlighted: Bool) -> String {
        isHighlighted ? "heart.fill" : "heart"
    }
    
    func isMyUsername(postUsername: String) -> Bool {
        guard let fullUsername = UserSettings.shared.fullUsername else {
            return false
        }
        
        return postUsername == fullUsername
    }
    
    func buttonColor(isHighlighted: Bool) -> Color {
        isHighlighted ? .timelineButtonCellHighlightedColor : .timelineButtonCellNormalColor
    }
    
    func repost(from post: Post) -> some View {
        VStack(alignment: .leading) {
            HStack {
                if let displayName = post.account.displayName {
                    Text(displayName)
                        .font(.headline)
                        .padding(5)
                }
                Image(systemName: "repeat")
                    .resizable()
                    .foregroundStyle(Color.timelineCellRepostIconColor)
                    .frame(width: 15, height: 15)
                    .background(Color.chihuClear)
            }
            account(from: post.repost!)
        }
    }
    
    func account(from post: Post) -> some View {
        VStack(alignment: .leading) {
            if showUserInfo {
                HStack {
                    loadableAvatarImage
                    VStack(alignment: .leading) {
                        if let displayName = post.account.displayName {
                            Text(displayName)
                                .font(.headline)
                        }
                        Text(post.account.acct + " " + (post.application?.name ?? ""))
                            .font(.body)
                            .foregroundColor(.chihuGray)
                    }
                    .padding(5)
                }
            }
            if !post.spoilerText.isEmpty {
                Text(post.spoilerText)
                    .padding(EdgeInsets(top: .zero, leading: .zero, bottom: 5, trailing: .zero))
            }
            cellContent(from: post)
                .spoiler(isOn: $sensitive)
        }
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
    
    func getPostPreviewUrl(from post: Post) -> URL? {
        if let url = postPreviews.imagesDictionary[post.id] {
            return url
        }
        
        return nil
    }
    
    func getAvatarUrl(from post: Post) -> URL? {
        if let _ = post.repost {
            return URL(string: post.account.avatar)
        } else {
            return URL(string: post.account.avatar)
        }
    }
    
    func get(_ imageState: ImageState?, of type: ImageType) -> Image? {
        guard let imageState else { return nil }
        
        switch imageState {
        case .loaded(let image):
            return image
        case .placeHolder, .needsLoading:
            if type == .avatar {
                if let uiImage = UIImage(named: "ProfileAvatar") {
                    return Image(uiImage: uiImage)
                } else {
                    return Image("ProfileAvatar")
                }
            } else {
                if let uiImage = UIImage(named: "ImagePlaceHolder") {
                    return Image(uiImage: uiImage)
                } else {
                    return Image("ImagePlaceHolder")
                }
            }
        case .none:
            return nil
        }
    }
    
    func parseHTML(from post: Post) -> some View {
        guard let content = post.content,
              let html = try? HTMLParser().parse(html: content) else {
            return Markdown("")
        }
        
        let markdown = html.toMarkdown(options: .unorderedListBullets)
        
        return Markdown(markdown)
    }
}
