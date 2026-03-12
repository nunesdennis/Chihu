import SwiftUI
import Combine
import LinkPresentation
import UniformTypeIdentifiers

enum SharedImageCache {
    private static let cache = URLCache(
        memoryCapacity: 1024 * 1024 * 100,
        diskCapacity: 1024 * 1024 * 100
    )

    static func cachedImage(for url: URL) -> UIImage? {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)

        guard let cachedResponse = cache.cachedResponse(for: request) else {
            return nil
        }

        return UIImage(data: cachedResponse.data)
    }

    static func store(_ data: Data, for url: URL, mimeType: String = "image/jpeg") {
        let response = URLResponse(
            url: url,
            mimeType: mimeType,
            expectedContentLength: data.count,
            textEncodingName: nil
        )
        let cachedResponse = CachedURLResponse(response: response, data: data)
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)

        cache.storeCachedResponse(cachedResponse, for: request)
    }

    static func store(_ image: UIImage, for url: URL) {
        if let pngData = image.pngData() {
            store(pngData, for: url, mimeType: "image/png")
        }
    }

    static var sessionConfiguration: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = cache
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        return configuration
    }
}

class LPLoader {
    enum LPLoaderError: Error {
     
        /// Metadata loading failed
        case metadataLoadingFailed(error: Error)
     
        /// Favicon loading failed
        case faviconCouldNotBeLoaded
     
        /// Favicon data is invalid
        case faviconDataInvalid
    }
    
    static func createPoster(from postId: String, for url: URL) async throws -> UIImage {
        let metadataProvider = LPMetadataProvider()
        
        let metadata: LPLinkMetadata
        do {
            metadata = try await metadataProvider.startFetchingMetadata(for: url)
        } catch {
            throw LPLoaderError.metadataLoadingFailed(error: error)
        }
 
        guard let imageProvider = metadata.imageProvider else {
            throw LPLoaderError.faviconCouldNotBeLoaded
        }
        
        var image: UIImage?
                
        let type = String(describing: UTType.image)
        
        if imageProvider.hasItemConformingToTypeIdentifier(type) {
            let item = try await imageProvider.loadItem(forTypeIdentifier: type)
            
            if item is UIImage {
                image = item as? UIImage
            }
            
            if item is URL {
                guard let imageURL = item as? URL,
                      let data = try? Data(contentsOf: imageURL) else {
                    throw LPLoaderError.faviconDataInvalid
                }
                
                PostPreviewSingleton.shared.imagesDictionary[postId] = url
                SharedImageCache.store(data, for: url)
                SharedImageCache.store(data, for: imageURL)
                
                if let uiImage = UIImage(data: data) {
                    image = uiImage
                }
            }
            
            if item is Data {
                guard let data = item as? Data else {
                    throw LPLoaderError.faviconDataInvalid
                }
                
                PostPreviewSingleton.shared.imagesDictionary[postId] = url
                SharedImageCache.store(data, for: url)
                image = UIImage(data: data)
            }
        }
        
        guard let imageResult = image else {
            throw LPLoaderError.faviconCouldNotBeLoaded
        }
        
        PostPreviewSingleton.shared.imagesDictionary[postId] = url
        SharedImageCache.store(imageResult, for: url)
        
        return imageResult
    }
}

fileprivate class ViewModel: ObservableObject {
    enum imageState {
        case loaded(UIImage)
        case loading
        case error
    }
    
    @Published var resource: imageState = .loading
    private var currentURL: URL?
    
    private var cancellable: Set<AnyCancellable> = .init()
    
    func load(url: URL?) {
        guard let url else {
            return
        }
        
        guard currentURL != url else {
            return
        }
        
        if case let .loaded(image) = resource {
            return
        }
        
        currentURL = url
        cancellable.removeAll()
        
        if let cachedImage = SharedImageCache.cachedImage(for: url) {
            resource = .loaded(cachedImage)
            return
        }
        
        let session = URLSession(configuration: SharedImageCache.sessionConfiguration)
        
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        
        session
            .dataTaskPublisher(for: request)
            .tryMap({ (data: Data, response: URLResponse) in
                guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                    return .error
                }
                
                guard !data.isEmpty else {
                    return .error
                }
                
                SharedImageCache.store(data, for: url, mimeType: response.mimeType ?? "image/jpeg")
                
                guard let image = UIImage(data: data) else {
                    return .error
                }
                
                return .loaded(image)
            })
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure:
                    print("image loading error")
                default:
                    break
                }
            } receiveValue: { resource in
                self.resource = resource
            }
            .store(in: &cancellable)
    }
}

struct CachedAsyncImage: View {
    
    @StateObject private var viewModel: ViewModel
    
    let url: URL?
    var placeHolderImage: Image?
    
    init(_ url: URL?, placeHolderImage: Image? = nil) {
        self.url = url
        self.placeHolderImage = placeHolderImage
        _viewModel = .init(wrappedValue: .init())
    }
    
    var body: some View {
        Group {
            switch viewModel.resource {
            case .loaded(let uiImage):
                Image(uiImage: uiImage)
                    .resizable()
            case .loading:
                if let placeHolderImage {
                    placeHolderImage.resizable()
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1)
                        .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: 40, alignment: .bottom)
                }
            case .error:
                Spacer()
            }
        }
        .task(id: url) {
            viewModel.load(url: url)
        }
    }
}
