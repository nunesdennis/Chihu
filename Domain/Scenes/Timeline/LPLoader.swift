//
//  LPLoader.swift
//  Chihu
//
//  Created by Dennis Nunes on 13/11/24.
//

import SwiftUI
import LinkPresentation
import UniformTypeIdentifiers

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
                guard let url = item as? URL,
                      let data = try? Data(contentsOf: url) else {
                    throw LPLoaderError.faviconDataInvalid
                }
                
                PostPreviewSingleton.shared.imagesDictionary[postId] = url
                
                if let uiImage = UIImage(data: data) {
                    image = uiImage
                    ImageCache[url] = Image(uiImage: uiImage)
                }
            }
            
            if item is Data {
                guard let data = item as? Data else {
                    throw LPLoaderError.faviconDataInvalid
                }
                
                image = UIImage(data: data)
            }
        }
        
        guard let imageResult = image else {
            throw LPLoaderError.faviconCouldNotBeLoaded
        }
        
        ImageCache[url] = Image(uiImage: imageResult)
        
        return imageResult
    }
}
