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
    func didPressLike(on post: PostProtocol)
    func didPressReply(on post: PostProtocol)
    func didPressUpdate(on post: PostProtocol)
    func editError()
}

extension TootSDK.TootApplication: ApplicationProtocol {}
extension TootSDK.Account: AccountProtocol {}
extension TootSDK.Post: PostProtocol {
    var applicationValue: (any ApplicationProtocol)? {
        application
    }
    
    var repostValue: (any PostProtocol)? {
        repost
    }
    
    var accountValue: (any AccountProtocol) {
        account
    }
}

@MainActor
struct CellTimeline: View {
    @State var sensitive: Bool
    @State var showSpoilerEffect: Bool
    @State var showTranslation: Bool = false
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var sourceText: String {
        if let content = post.content {
            return TootHTML.extractAsPlainText(html: content) ?? String()
        }
        
        return String()
    }
    
    private var image: Image?
    private var avatarImage: Image?
    private var shouldLoadOnCell: Bool = false
    private var isMyPost: Bool {
        isMyUsername(postUsername: post.accountValue.acct)
    }
    
    private let post: PostProtocol
    private let delegate: CellTimelineDelegate

    // MARK: - Init
    init(post: PostProtocol, image: ImageState?, avatarImage: ImageState?, itemURL: String? = nil, delegate: CellTimelineDelegate) {
        self._sensitive = State(initialValue: post.sensitive)
        self._showSpoilerEffect = State(initialValue: post.sensitive)
        
        self.delegate = delegate
        self.post = post
        self.image = get(image, of: .poster)
        
        shouldLoadOnCell = avatarImage == .needsLoading
        
        if let avatarImage = get(avatarImage ?? ImageState.none, of: .avatar) {
            self.avatarImage = avatarImage
        } else if let uiImage = UIImage(named: "ProfileAvatar") {
            self.avatarImage = Image(uiImage: uiImage)
        } else {
            self.avatarImage = Image("ProfileAvatar")
        }
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
                if post.repostValue != nil {
                    repost(from: post)
                } else {
                    account(from: post)
                }
                if let image = image {
                    Spacer()
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 75, height: 150)
                        .cornerRadius(2)
                }
                Spacer()
            }
            HStack(alignment: .center) {
                likeButton
                replyButton
                if isMyPost {
                    editButton
                }
                if #available(iOS 18.0, *) {
                    translateButton
                }
            }
            .frame(height: 30)
        }
        .listRowBackground(Color.timelineCellBackgroundColor)
    }
    
    var likeButton: some View {
        Image(systemName: heartEmoji(isHighlighted: post.favourited ?? false))
            .resizable()
            .scaledToFit()
            .foregroundColor(buttonColor(isHighlighted: post.favourited ?? false))
            .frame(width: 20, height: 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            delegate.didPressLike(on: post)
        }
    }
    
    var replyButton: some View {
        Image(systemName: "bubble.left")
            .resizable()
            .scaledToFit()
            .foregroundColor(buttonColor(isHighlighted: false))
            .frame(width: 20, height: 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            delegate.didPressReply(on: post)
        }
    }
    
    var editButton: some View {
        Image(systemName: "pencil")
            .resizable()
            .scaledToFit()
            .foregroundColor(buttonColor(isHighlighted: false))
            .frame(width: 20, height: 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            if let itemURLString = getItemURL(),
               let url = URL(string: itemURLString) {
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
            .frame(width: 20, height: 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            showTranslation.toggle()
        }
    }
    
    var loadableAvatarImage: some View {
        Group {
            if shouldLoadOnCell {
                CachedAsyncImage(url: getAvatarUrl(from: post)) { phase in
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
            } else {
                avatarImage?
                    .resizable()
            }
        }
        .scaledToFit()
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.primary.opacity(0.25), lineWidth: 1)
        )
        .frame(width: 40, height: 40)
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
    
    func repost(from post: PostProtocol) -> some View {
        VStack(alignment: .leading) {
            HStack {
                if let displayName = post.accountValue.displayName {
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
            account(from: post.repostValue!)
        }
    }
    
    func account(from post: PostProtocol) -> some View {
        VStack(alignment: .leading) {
            HStack {
                loadableAvatarImage
                VStack(alignment: .leading) {
                    if let displayName = post.accountValue.displayName {
                        Text(displayName)
                            .font(.headline)
                    }
                    Text(post.accountValue.acct + " " + (post.applicationValue?.name ?? ""))
                        .font(.body)
                        .foregroundColor(.chihuGray)
                }
                .padding(5)
            }
            if !post.spoilerText.isEmpty {
                Text(post.spoilerText)
                    .padding(EdgeInsets(top: .zero, leading: .zero, bottom: 5, trailing: .zero))
            }
            cellContent(from: post)
                .spoiler(isOn: $sensitive)
        }
    }
    
    func cellContent(from post: PostProtocol) -> some View {
        parseHTML(from: post)
            .environment(
                \.openURL,
                 OpenURLAction { url in
                     delegate.handleURL(url)
                     return .handled
                 }
            )
    }
    
    func getAvatarUrl(from post: PostProtocol) -> URL? {
        if let _ = post.repostValue {
            return URL(string: post.accountValue.avatar)
        } else {
            return URL(string: post.accountValue.avatar)
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
    
    func parseHTML(from post: PostProtocol) -> some View {
        guard let content = post.content,
              let html = try? HTMLParser().parse(html: content) else {
            return Markdown("")
        }
        
        let markdown = html.toMarkdown(options: .unorderedListBullets)
        
        return Markdown(markdown)
    }
    
    private func getItemURL() -> String? {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            
            guard let content = post.content, content.contains("~neodb~/") else {
                return nil
            }
            
            let input = content.replacingOccurrences(of: "~neodb~/", with: String())
            let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
            
            for match in matches {
                guard let range = Range(match.range, in: input) else {
                    return nil
                }
                let urlString = String(input[range])
                guard let _ = URL(string: urlString) else {
                    return nil
                }
                
                return urlString
            }
        } catch let error {
            print(error.localizedDescription)
        }
        
        return nil
    }
}

