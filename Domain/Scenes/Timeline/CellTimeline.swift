//
//  CellTimeline.swift
//  Chihu
//
//  Created by Dennis Nunes on 12/11/24.
//

import SwiftUI
import TootSDK
import HTML2Markdown
import MarkdownUI

protocol CellTimelineDelegate {
    func handleURL(_ url: URL)
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
    
    private var image: Image?
    private var avatarImage: Image?
    private var shouldLoadOnCell: Bool = false
    
    private let post: PostProtocol
    private let delegate: CellTimelineDelegate

    // MARK: - Init
    init(post: PostProtocol, image: ImageState?, avatarImage: ImageState?, delegate: CellTimelineDelegate) {
        self.sensitive = post.sensitive
        self.showSpoilerEffect = post.sensitive
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
        }
        .listRowBackground(Color.timelineCellBackgroundColor)
        .padding(10)
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
        if let repost = post.repostValue {
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
}
