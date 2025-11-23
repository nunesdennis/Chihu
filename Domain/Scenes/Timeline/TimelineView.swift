//
//  TimelineView.swift
//  Chihu
//
//  Created by Dennis Nunes on 11/11/24.
//  
//
import SwiftUI
import TootSDK
import UIKit

protocol TimelineDisplayLogic {
    func display(viewModel: Review.Send.ViewModel)
    func display(viewModel: Timeline.Load.ViewModel) async
    func displayMore(viewModel: Timeline.Load.ViewModel) async
    func displayError(_ error: Error)
    func displayAlertError(_ error: any Error)
}

extension TimelineView: PostInteractionsDisplayLogic {
    func display(post: Post) {
        DispatchQueue.main.async {
            let index = dataStore.posts.firstIndex {
                $0.id == post.id
            }
            
            if let index {
                dataStore.posts[index] = post
            } else {
                dataStore.alertType = .actionFailed
                dataStore.alertMessage = LocalizedStringKey(ChihuError.codeError.localizedDescription)
                dataStore.shouldShowToast = true
            }
        }
    }
    
    func displayToastError(_ error: any Error) {
        DispatchQueue.main.async {
            dataStore.alertType = .actionFailed
            dataStore.alertMessage = LocalizedStringKey(error.localizedDescription)
            dataStore.shouldShowToast = true
        }
    }
}

extension TimelineView: TimelineDisplayLogic {
    func displayAlertError(_ error: any Error) {
        DispatchQueue.main.async {
            dataStore.alertMessage = LocalizedStringKey(error.localizedDescription)
            dataStore.shouldShowAlert = true
        }
    }
    
    func displayError(_ error: any Error) {
        DispatchQueue.main.async {
            dataStore.lastError = error
            dataStore.state = .error
        }
    }
    
    func display(viewModel: Timeline.Load.ViewModel) async {
        dataStore.posts = viewModel.posts
        if dataStore.posts.isEmpty {
            DispatchQueue.main.async {
                dataStore.state = .empty
            }
        } else {
            DispatchQueue.main.async {
                dataStore.state = .textLoaded
            }
        }
    }
    
    func display(viewModel: Review.Send.ViewModel) {
        DispatchQueue.main.async {
            dataStore.alertMessage = LocalizedStringKey(viewModel.message)
            dataStore.shouldShowAlert = true
        }
    }
    
    func displayMore(viewModel: Timeline.Load.ViewModel) async {
        dataStore.posts = dataStore.posts + viewModel.posts
        if dataStore.posts.isEmpty {
            DispatchQueue.main.async {
                dataStore.state = .empty
            }
        } else {
            DispatchQueue.main.async {
                dataStore.state = .textLoaded
            }
        }
    }
    
    func fetch() {
        guard let interactor else {
            dataStore.lastError = ChihuError.codeError
            dataStore.state = .error
            return
        }
        
        let requestPosts = Timeline.Load.Request(timelineType: .home, pageInfo: nil)
        interactor.load(request: requestPosts)
    }
    
    func fetchMore() {
        guard let lastId = dataStore.posts.last?.id else {
            return
        }
        
        guard let interactor else {
            dataStore.lastError = ChihuError.codeError
            dataStore.state = .error
            return
        }
        
        let pageInfo = PagedInfo(maxId: lastId)
        let requestPost = Timeline.Load.Request(timelineType: .home, pageInfo: pageInfo)
        interactor.loadMore(request: requestPost)
    }
    
    func sendToWishlist(itemUUID: String?) {
        guard let itemUUID else {
            return
        }
        
        guard let interactor else {
            dataStore.lastError = ChihuError.codeError
            dataStore.state = .error
            return
        }
        
        let requestPost = Review.Send.Request(body: Review.Send.Request.ReviewRequestBody.createDefaultWishlistBody(), itemUUID: itemUUID)
        interactor.sendRate(request: requestPost)
    }
}

struct TimelineView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.showToast) private var showToast
    @Environment(\.reviewItem) private var reviewItem
    @Environment(\.openURL) var openURL
    var interactor: (TimelineBusinessLogic & ReviewBusinessLogic)?
    var postInteractionInteractor: PostInteractionsBusinessLogic?
    @ObservedObject var dataStore: TimelineDataStore
    @Binding var tabTapped: Bool
    
    @State private var replyViewDetent = PresentationDetent.medium
    
    init(tabTapped: Binding<Bool>, dataStore: TimelineDataStore = TimelineDataStore()) {
        _tabTapped = tabTapped
        self.dataStore = dataStore
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                switch dataStore.state {
                case .firstLoad:
                    progressView
                case .textLoaded, .loaded:
                    timelineView
                case .empty:
                    GeometryReader { geometry in
                      ScrollView(.vertical) {
                          EmptyView()
                          .frame(minHeight: geometry.size.height)
                      }
                    }
                    .refreshable {
                        fetch()
                    }
                default:
                    GeometryReader { geometry in
                      ScrollView(.vertical) {
                          ErrorView(error: dataStore.lastError)
                          .frame(minHeight: geometry.size.height)
                      }
                    }
                    .refreshable {
                        fetch()
                    }
                }
            }
            .navigationTitle("Feed")
            .onAppear {
                UIRefreshControl.appearance().tintColor = UIColor(Color.chihuGreen)
            }
            .background(Color.timelineBackgroundColor)
        }
    }
    
    var timelineView: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(dataStore.posts) { post in
                    CellTimeline(post: post, image: .needsLoading, avatarImage: .needsLoading, showThreadButton: true, delegate: self)
                        .swipeActions(edge: .leading) {
                            Button("Add to wishlist") {
                                sendToWishlist(itemUUID: getItemUUIDFrom(post: post))
                            }
                            .tint(.chihuGreen)
                        }
                        .swipeActions(edge: .trailing) {
                            Button("Add to wishlist") {
                                sendToWishlist(itemUUID: getItemUUIDFrom(post: post))
                            }
                            .tint(.chihuGreen)
                        }
                        .id(post.id)
                }
                if dataStore.posts.count >= 20 {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1)
                        .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: 40, alignment: .center)
                        .onAppear {
                            fetchMore()
                        }
                        .listRowBackground(Color.chihuClear)
                        .id(UUID())
                }
            }
            .listStyle(.plain)
            .toolbarBackground(Color.timelineNavBackgroundColor)
            .refreshable {
                fetch()
            }
            .fullScreenCover(isPresented: $dataStore.openThread, onDismiss: {
                // TODO: Update post with changes from thread
                dataStore.postClicked = nil
            }, content: {
                if let postClicked = dataStore.postClicked {
                    ThreadView(dataStore: dataStore.createNewThreadDataStore(with: postClicked)).configureView()
                }
            })
            .sheet(isPresented: $dataStore.showReplyView, onDismiss: {
                dataStore.postClicked = nil
                dataStore.replyPostClicked = nil
                dataStore.showReplyView = false
            }) {
                if let postClicked = dataStore.postClicked {
                    ReplyView(delegate: self, post: postClicked).configureView()
                        .presentationDetents(
                            [.medium, .large],
                            selection: $replyViewDetent
                        )
                } else if let replyPostClicked = dataStore.replyPostClicked {
                    ReplyView(delegate: self, reply: replyPostClicked).configureView()
                        .presentationDetents(
                            [.medium, .large],
                            selection: $replyViewDetent
                        )
                }
            }
            .alert("Alert", isPresented: $dataStore.shouldShowAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(dataStore.alertMessage ?? "Error")
            }
            .onAppear {
                tabTapped = false
            }
            .onChange(of: tabTapped) {
                if tabTapped {
                    withAnimation {
                        proxy.scrollTo(dataStore.posts.first?.id ?? "")
                    }
                    tabTapped = false
                }
            }
            .onChange(of: dataStore.shouldShowToast) {
                guard let alertMessage = dataStore.alertMessage,
                      dataStore.shouldShowToast else { return }
                switch dataStore.alertType {
                case .success:
                    showToast(.success(nil, alertMessage))
                default:
                    showToast(.failure(nil, alertMessage))
                }
                dataStore.shouldShowToast = false
            }
        }
    }
    
    var progressView: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .scaleEffect(2)
            .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: .infinity)
            .task(id: UUID()) {
                fetch()
            }
    }
    
    private func getItemUUIDFrom(post: Post) -> String? {
        func alertError() {
            dataStore.shouldShowAlert = true
            dataStore.alertMessage = "Invalid url"
        }
        
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            
            guard let content = post.content, NeoDBURL.hasNeoDBlink(content) else {
                alertError()
                return nil
            }
            
            let input = content.replacingOccurrences(of: "~neodb~/", with: String())
            let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
            
            for match in matches {
                guard let range = Range(match.range, in: input) else {
                    alertError()
                    return nil
                }
                let urlString = String(input[range])
                
                if let username = post.account.username,
                   urlString.contains(username) {
                    continue
                }
                
                if urlString.contains("/tags/") {
                    continue
                }
                
                guard let url = URL(string: urlString) else {
                    continue
                }
                
                guard let _ = URL(string: urlString) else {
                    alertError()
                    return nil
                }
                
                return urlString.components(separatedBy: "/").last
            }
        } catch let error {
            print(error.localizedDescription)
        }
        
        alertError()
        return nil
    }
}

extension TimelineView: CellTimelineDelegate {
    func didClick(on post: Post) {
        DispatchQueue.main.async {
            dataStore.openThread = true
            dataStore.postClicked = post
        }
    }
    
    func didPressRepost(on post: TootSDK.Post) {
        guard let postInteractionInteractor else {
            dataStore.alertType = .actionFailed
            dataStore.alertMessage = LocalizedStringKey(ChihuError.codeError.localizedDescription)
            dataStore.shouldShowToast = true
            return
        }

        let repostRequest = PostInteraction.Repost.Request(postId: post.id, reposted: post.reposted ?? false)
        postInteractionInteractor.repost(request: repostRequest)
    }
    
    func editError() {
        DispatchQueue.main.async {
            dataStore.shouldShowAlert = true
            dataStore.alertMessage = "Invalid url"
        }
    }
    
    func didPressUpdate(on post: Post) {
        DispatchQueue.main.async {
            dataStore.replyPostClicked = post
            dataStore.showReplyView = true
        }
    }
    
    func didPressLike(on post: Post) {
        guard let postInteractionInteractor else {
            dataStore.alertType = .actionFailed
            dataStore.alertMessage = LocalizedStringKey(ChihuError.codeError.localizedDescription)
            dataStore.shouldShowToast = true
            return
        }

        let likeRequest = PostInteraction.LikeDislike.Request(postId: post.id, favourited: post.favourited ?? false)
        postInteractionInteractor.likeDislike(request: likeRequest)
    }
    
    func didPressReply(on post: Post) {
        DispatchQueue.main.async {
            dataStore.postClicked = post
            dataStore.showReplyView = true
        }
    }
    
    func handleURL(_ url: URL) {
        URLHandler.handleItemURL(url) { item in
            if let item {
                DispatchQueue.main.async {
                    let item = ItemViewModelBuilder.create(from: item)
                    reviewItem(.review(item))
                    dataStore.state = .loaded
                }
            } else {
                openURL(url)
            }
        }
    }
}

extension TimelineView: ReplyDelegate {
    func didEndReply(with post: Post) {
        DispatchQueue.main.async {
            dataStore.showReplyView = false
            let index = dataStore.posts.firstIndex {
                $0.id == post.id
            }
            
            if let index {
                dataStore.posts[index] = post
            } else {
                dataStore.posts.insert(post, at: 0)
            }
        }
    }
}
