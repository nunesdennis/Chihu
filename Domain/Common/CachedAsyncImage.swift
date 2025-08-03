
import SwiftUI

fileprivate class ImageCache {
    static private var cache: [URL: Image] = [:]
    static subscript(url: URL) -> Image? {
        get {
            ImageCache.cache[url]
        }
        set {
            ImageCache.cache[url] = newValue
        }
    }
}

/// Loads, displays and caches a modifiable image from the specified URL in phases.
///
/// If you set the asynchronous image's URL to `nil`, or after you set the
/// URL to a value but before the load operation completes, the phase is
/// ``AsyncImagePhase/empty``. After the operation completes, the phase
/// becomes either ``AsyncImagePhase/failure(_:)`` or
/// ``AsyncImagePhase/success(_:)``. In the first case, the phase's
/// ``AsyncImagePhase/error`` value indicates the reason for failure.
/// In the second case, the phase's ``AsyncImagePhase/image`` property
/// contains the loaded image. Use the phase to drive the output of the
/// `content` closure, which defines the view's appearance:
///
///     CachedAsyncImage(url: URL(string: "https://example.com/icon.png")) { phase in
///         if let image = phase.image {
///             image // Displays the loaded image.
///         } else if phase.error != nil {
///             Color.red // Indicates an error.
///         } else {
///             Color.blue // Acts as a placeholder.
///         }
///     }
///
/// To add transitions when you change the URL, apply an identifier to the
/// ``CachedAsyncImage``.
public struct CachedAsyncImage<Content>: View where Content: View{

    private let url: URL?
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content
    
    /// Loads, displays and caches a modifiable image from the specified URL in phases.
    ///
    /// - Parameters:
    ///   - url: The URL of the image to display.
    ///   - scale: The scale to use for the image. The default is `1`. Set a
    ///     different value when loading images designed for higher resolution
    ///     displays. For example, set a value of `2` for an image that you
    ///     would name with the `@2x` suffix if stored in a file on disk.
    ///   - transaction: The transaction to use when the phase changes.
    ///   - content: A closure that takes the load phase as an input, and
    ///     returns the view to display for the specified phase.
    public init(url: URL?,
                scale: CGFloat = 1.0,
                transaction: Transaction = Transaction(),
                @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }

    public var body: some View {
        if let url, let cached = ImageCache[url] {
            content(.success(cached))
        } else {
            AsyncImage(url: url,
                scale: scale,
                transaction: transaction) { phase in
                cacheAndRender(phase: phase)
            }
        }
    }
    
    private func cacheAndRender(phase: AsyncImagePhase) -> some View {
        if case .success (let image) = phase, let url {
            ImageCache[url] = image
        }
        return content(phase)
    }
}
