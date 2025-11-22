//
//  ThreadView.swift
//  Chihu
//
//  Created by Angela Rosanne Santos de Oliveira on 16/11/25.
//

import SwiftUI
import TootSDK

extension ThreadView: PostInteractionsDisplayLogic {
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

struct ThreadView: View {
    
    var dataStore: ThreadDataStore
    
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
    
    var postInteractionInteractor: PostInteractionsBusinessLogic?
    var wasPushed: Bool
    
    init(wasPushed: Bool = false, dataStore: ThreadDataStore) {
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
                    let posts = await getPosts()
                    self.posts = posts
                }
            }
        }
        .navigationBarTitle("Thread", displayMode: .inline)
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
    
    var thread: some View {
        List {
            ForEach(posts, id: \.self) { post in
                NavigationLink(destination: ThreadView(wasPushed: true, dataStore: ThreadDataStore(referencePost: post)).configureView()) {
                    CellTimeline(post: post, image: .needsLoading, avatarImage: .needsLoading, delegate: self)
                        .swipeActions(edge: .leading) {
                            Button("Add to wishlist") {
                                //                                sendToWishlist(itemUUID: getItemUUIDFrom(post: post))
                            }
                            .tint(.chihuGreen)
                        }
                        .swipeActions(edge: .trailing) {
                            Button("Add to wishlist") {
                                //                                sendToWishlist(itemUUID: getItemUUIDFrom(post: post))
                            }
                            .tint(.chihuGreen)
                        }
                        .id(post.id)
                }
                .listRowBackground(Color.chihuClear)
                .onDisappear {
                    Task {
                        posts = await getPosts()
                    }
                }
            }
        }
        .refreshable {
            Task {
                posts = await getPosts()
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
                let posts = await getPosts()
                self.posts = posts
            }
    }
    
    func getPosts() async -> [Post] {
        // TODO: Add to interactor.
        guard let baseUrlString = UserSettings.shared.instanceURL,
              let baseUrl = URL(string: baseUrlString) else {
            dataStore.lastError = ChihuError.codeError
            state = .error
            return [dataStore.referencePost]
        }
        
        guard let accessToken = UserSettings.shared.accessToken else {
            dataStore.lastError = ChihuError.accessTokenMissing
            state = .error
            return [dataStore.referencePost]
        }
        
        do {
            let client = try await TootClient(connect: baseUrl, accessToken: accessToken)
            let context = try await client.getContext(id: dataStore.referencePost.id)
            let posts = context.ancestors + [dataStore.referencePost] + context.descendants
            
            state = .loaded
            return posts
        } catch {
            dataStore.lastError = error
            state = .error
        }
        
        return [dataStore.referencePost]
    }
}

extension ThreadView: CellTimelineDelegate {
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

extension ThreadView: ReplyDelegate {
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
            posts = await getPosts()
        }
    }
}

