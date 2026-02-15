import Foundation
import TootSDK

/// MainActor observable used so SwiftUI views can observe post updates (actors' @Published is not observed by views).
@MainActor
final class PostUpdateNotifier: ObservableObject {
    static let shared = PostUpdateNotifier()
    @Published var postUpdated = ""
}

/// Singleton actor for managing posts concurrently.
actor PostsManager {
    static let shared = PostsManager()
    
    private var posts: [String: Post] = [:]
    
    /// Retrieves a post by its id.
    func post(withId id: String) -> Post? {
        return posts[id]
    }
    
    /// Inserts or updates a post(s).
    func set(_ post: Post) -> Post {
        if let oldPost = posts[post.id] {
            return update(oldPost, with: post)
        }
        
        let id = post.id
        posts[id] = post
        updatedPost(id)
        
        return post
    }
    
    func set(_ posts: [Post]) -> [Post] {
        var updatedPosts: [Post] = []
        
        for post in posts {
            updatedPosts.append(set(post))
        }
        
        return updatedPosts
    }
    
    func reset() {
        Task { @MainActor in
            PostUpdateNotifier.shared.postUpdated = ""
        }
        posts = [:]
    }
    
    func update(_ old: Post, with new: Post) -> Post {
        // Update all properties from new to old
        old.uri = new.uri
        old.createdAt = new.createdAt
        old.account = new.account
        old.content = new.content
        old.visibility = new.visibility
        old.sensitive = new.sensitive
        old.spoilerText = new.spoilerText
        old.mediaAttachments = new.mediaAttachments
        old.application = new.application
        old.mentions = new.mentions
        old.tags = new.tags
        old.emojis = new.emojis
        old.repostsCount = new.repostsCount
        old.favouritesCount = new.favouritesCount
        old.repliesCount = new.repliesCount
        old.url = new.url
        old.inReplyToId = new.inReplyToId
        old.inReplyToAccountId = new.inReplyToAccountId
        old.repost = new.repost
        old.poll = new.poll
        old.card = new.card
        old.language = new.language
        old.text = new.text
        old.editedAt = new.editedAt
        old.favourited = new.favourited
        old.reposted = new.reposted
        old.muted = new.muted
        old.bookmarked = new.bookmarked
        old.pinned = new.pinned
        old.filtered = new.filtered
        old.quote = new.quote
        updatedPost(old.id)
        
        return old
    }
    
    func updatedPost(_ id: String) {
        Task { @MainActor in
            PostUpdateNotifier.shared.postUpdated = id
        }
    }
}
