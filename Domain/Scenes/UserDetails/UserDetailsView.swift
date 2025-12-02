//
//  UserDetailsView.swift
//  Chihu
//

import SwiftUI
import TootSDK
import HTML2Markdown
import MarkdownUI

extension UserDetailsView: PostInteractionsDisplayLogic {
    func display(posts: [Post]) {
        DispatchQueue.main.async {
            postLock.lock()
            self.posts = posts
            postLock.unlock()
            state = .loaded
        }
    }
    
    func displayMore(posts: [Post]) {
        DispatchQueue.main.async {
            postLock.lock()
            self.posts += posts
            postLock.unlock()
            state = .loaded
        }
    }
    
    func display(post: Post) {
        DispatchQueue.main.async {
            let index = posts.firstIndex {
                $0.id == post.id
            }
            
            if let index {
                posts[index] = post
            } else {
                dataStore.alertType = .actionFailed
                dataStore.alertMessage = LocalizedStringKey(ChihuError.codeError.localizedDescription)
                shouldShowToast = true
            }
        }
    }
    
    func displayToastError(_ error: any Error) {
        DispatchQueue.main.async {
            dataStore.alertType = .actionFailed
            dataStore.alertMessage = LocalizedStringKey(error.localizedDescription)
            shouldShowToast = true
        }
    }
    
    func displayAlertError(_ error: any Error) {
        DispatchQueue.main.async {
            dataStore.alertMessage = LocalizedStringKey(error.localizedDescription)
            shouldShowAlert = true
        }
    }
    
    func displayError(_ error: any Error) {
        DispatchQueue.main.async {
            dataStore.lastError = error
            state = .error
        }
    }
}

struct UserDetailsView: View {
    
    var dataStore: UserDetailsDataStore
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.showToast) private var showToast
    @Environment(\.reviewItem) private var reviewItem
    @Environment(\.openURL) var openURL

    @State private var replyViewDetent = PresentationDetent.medium
    @State var state: ThreadState = .firstLoad
    @State var shouldShowAlert = false
    @State var showReplyView: Bool = false
    @State var shouldShowToast: Bool = false
    @State var posts: [Post] = []
    @State var postClicked: Post?
    @State var replyPostClicked: Post?
    @State var fetchingMore: Bool = false
    
    private var postLock = NSLock()
    var postInteractionInteractor: PostInteractionsBusinessLogic?
    var wasPushed: Bool
    
    init(wasPushed: Bool = false, dataStore: UserDetailsDataStore) {
        self.dataStore = dataStore
        self.wasPushed = wasPushed
    }
    
    var body: some View {
        if wasPushed {
            mainBody
        } else {
            NavigationView {
                mainBody
            }
        }
    }
    
    var mainBody: some View {
        VStack {
            switch state {
            case .firstLoad:
                progressView
            case .loaded:
                thread
            default:
                GeometryReader { geometry in
                  ScrollView(.vertical) {
                      ErrorView(error: dataStore.lastError)
                      .frame(minHeight: geometry.size.height)
                  }
                }
                .refreshable {
                    getPosts()
                }
            }
        }
        .navigationBarTitle(dataStore.user.displayName ?? dataStore.user.acct, displayMode: .inline)
        .background(Color.timelineBackgroundColor)
        .toolbar {
            if !wasPushed {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .font(Font.body.weight(.bold))
                            .scaleEffect(0.416)
                            .foregroundColor(Color(white: colorScheme == .dark ? 0.62 : 0.51))
                            .frame(width: 30, height: 30)
                    }
                    .frame(width: 30, height: 30)
                }
            }
        }
        .sheet(isPresented: $showReplyView, onDismiss: {
            postClicked = nil
            replyPostClicked = nil
            showReplyView = false
        }) {
            if let postClicked = postClicked {
                ReplyView(delegate: self, post: postClicked).configureView()
                    .presentationDetents(
                        [.medium, .large],
                        selection: $replyViewDetent
                    )
            } else if let replyPostClicked = replyPostClicked {
                ReplyView(delegate: self, reply: replyPostClicked).configureView()
                    .presentationDetents(
                        [.medium, .large],
                        selection: $replyViewDetent
                    )
            }
        }
        .alert("Alert", isPresented: $shouldShowAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(dataStore.alertMessage ?? "Error")
        }
        .onChange(of: shouldShowToast) {
            guard let alertMessage = dataStore.alertMessage,
                  shouldShowToast else { return }
            switch dataStore.alertType {
            case .success:
                showToast(.success(nil, alertMessage))
            default:
                showToast(.failure(nil, alertMessage))
            }
            shouldShowToast = false
        }
    }
    
    var loadableAvatarImage: some View {
        Group {
            if let url = URL(string: dataStore.user.avatar) {
                CachedAsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                    default:
                        Image("ProfileAvatar").resizable()
                    }
                }
            } else {
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
    }
    
    var userCell: some View {
        HStack {
            VStack {
                loadableAvatarImage
                Spacer()
            }
            VStack(alignment: .leading, spacing: 5) {
                if let displayName = dataStore.user.displayName {
                    Text(displayName)
                        .bold()
                        .font(.headline)
                        .foregroundColor(.profileDisplayNameColor)
                }
                Text(dataStore.user.acct)
                    .font(.subheadline)
                    .foregroundColor(.profileUsernameColor)
                if !dataStore.user.acct.description.isEmpty {
                    parseHTML(from: dataStore.user.note)
                }
            }
        }
        .padding(5)
    }
    
    var thread: some View {
        List {
            userCell
                .listRowBackground(Color.chihuClear)
            ForEach(posts, id: \.self) { post in
                NavigationLink(destination: ThreadView(wasPushed: true, dataStore: ThreadDataStore(referencePost: post)).configureView()) {
                    CellTimeline(post: post, image: .needsLoading, avatarImage: .needsLoading, showUserInfo: false, delegate: self)
                        .id(post.id)
                }
                .listRowBackground(Color.chihuClear)
            }
            if posts.count >= 20 {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1)
                    .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: 40, alignment: .center)
                    .onAppear {
                        guard !fetchingMore else { return }
                        fetchMore()
                    }
                    .listRowBackground(Color.chihuClear)
            }
        }
        .refreshable {
            Task {
                getPosts()
            }
        }
        .listStyle(.plain)
        .toolbarBackground(Color.timelineNavBackgroundColor)
    }
        
    var progressView: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .scaleEffect(2)
            .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: .infinity)
            .task {
                getPosts()
            }
    }
    
    func parseHTML(from content: String) -> some View {
        guard let html = try? HTMLParser().parse(html: content) else {
            return Markdown("")
        }
        
        let markdown = html.toMarkdown(options: .unorderedListBullets)
        
        return Markdown(markdown)
    }
    
    func getPosts() {
        // TODO: Add to interactor.
        guard let baseUrlString = UserSettings.shared.instanceURL,
              let baseUrl = URL(string: baseUrlString) else {
            dataStore.lastError = ChihuError.codeError
            state = .error
            return
        }
        
        guard let accessToken = UserSettings.shared.accessToken else {
            dataStore.lastError = ChihuError.accessTokenMissing
            state = .error
            return
        }
        
        Task {
            do {
                let client = try await TootClient(connect: baseUrl, accessToken: accessToken)
                let response = try await client.getTimeline(.user(userID: dataStore.user.id))
                
                if let user = response.result.first?.account {
                    dataStore.user = user
                }
                
                display(posts: response.result)
            } catch {
                dataStore.lastError = error
                state = .error
            }
        }
        
        return
    }
    
    func fetchMore() {
        defer { fetchingMore = false }
        guard !fetchingMore else {
            return
        }
        
        fetchingMore = true
        // TODO: Add to interactor.
        guard let baseUrlString = UserSettings.shared.instanceURL,
              let baseUrl = URL(string: baseUrlString) else {
            dataStore.lastError = ChihuError.codeError
            state = .error
            return
        }
        
        guard let accessToken = UserSettings.shared.accessToken else {
            dataStore.lastError = ChihuError.accessTokenMissing
            state = .error
            return
        }
        
        Task {
            guard let lastPostId = posts.last?.id else {
                return getPosts()
            }
            
            let pageInfo = PagedInfo(maxId: lastPostId)
            
            do {
                let client = try await TootClient(connect: baseUrl, accessToken: accessToken)
                let response = try await client.getTimeline(.user(userID: dataStore.user.id), pageInfo: pageInfo)
                
                displayMore(posts: response.result)
            } catch {
                // no-op
                return
            }
        }
    }
}

extension UserDetailsView: CellTimelineDelegate {
    func didClick(on account: TootSDK.Account) {
        // no-op
    }
    
    func didClick(on post: Post) {
        // no-op
    }
    
    func handleURL(_ url: URL) {
        URLHandler.handleItemURL(url) { item in
            if let item {
                DispatchQueue.main.async {
                    let item = ItemViewModelBuilder.create(from: item)
                    reviewItem(.review(item))
                    state = .loaded
                }
            } else {
                openURL(url)
            }
        }
    }
    
    func didPressLike(on post: Post) {
        guard let postInteractionInteractor else {
            dataStore.alertType = .actionFailed
            dataStore.alertMessage = LocalizedStringKey(ChihuError.codeError.localizedDescription)
            shouldShowToast = true
            return
        }
        
        let likeRequest = PostInteraction.LikeDislike.Request(postId: post.id, favourited: post.favourited ?? false)
        postInteractionInteractor.likeDislike(request: likeRequest)
    }
    
    func didPressReply(on post: Post) {
        postClicked = post
        showReplyView = true
    }
    
    func didPressRepost(on post: Post) {
        guard let postInteractionInteractor else {
            dataStore.alertType = .actionFailed
            dataStore.alertMessage = LocalizedStringKey(ChihuError.codeError.localizedDescription)
            shouldShowToast = true
            return
        }
        
        let repostRequest = PostInteraction.Repost.Request(postId: post.id, reposted: post.reposted ?? false)
        postInteractionInteractor.repost(request: repostRequest)
    }
    
    func didPressUpdate(on post: Post) {
        replyPostClicked = post
        showReplyView = true
    }
    
    func editError() {
        dataStore.alertMessage = "Invalid url"
        shouldShowAlert = true
    }
}

extension UserDetailsView: ReplyDelegate {
    func didEndReply(with post: Post) {
        showReplyView = false
//            let index = posts.firstIndex {
//                $0.id == post.id
//            }
        
//            if let index {
//                posts[index] = post
//            } else {
            // TODO: Need to see how to handle this.
//                dataStore.posts.insert(post, at: 0)
//            }
        Task {
            await getPosts()
        }
    }
}

