//
//  ImageCompressor.swift
//  Chihu
//
//  Created by Assistant on 2024.
//

import Foundation
import UIKit
import UniformTypeIdentifiers

actor ImageCompressor {
    enum CompressorError: Error {
        case noData
    }
    
    public init() {}
    
    public func compressImageFrom(url: URL) async -> Data? {
        await withCheckedContinuation { continuation in
            let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
            guard let source = CGImageSourceCreateWithURL(url as CFURL, sourceOptions) else {
                continuation.resume(returning: nil)
                return
            }
            
            let maxPixelSize: Int = 4096
            
            let downsampleOptions = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
            ] as [CFString: Any] as CFDictionary
            
            guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions) else {
                continuation.resume(returning: nil)
                return
            }
            
            let data = NSMutableData()
            guard let imageDestination = CGImageDestinationCreateWithData(
                data, UTType.jpeg.identifier as CFString, 1, nil)
            else {
                continuation.resume(returning: nil)
                return
            }
            
            let isPNG: Bool = {
                guard let utType = cgImage.utType else { return false }
                return (utType as String) == UTType.png.identifier
            }()
            
            let destinationProperties = [
                kCGImageDestinationLossyCompressionQuality: isPNG ? 1.0 : 0.75
            ] as CFDictionary
            
            CGImageDestinationAddImage(imageDestination, cgImage, destinationProperties)
            CGImageDestinationFinalize(imageDestination)
            
            continuation.resume(returning: data as Data)
        }
    }
    
    public func compressImageForUpload(
        _ image: UIImage,
        maxSize: Int = 2 * 1024 * 1024, // 2MB
        maxHeight: Double = 400,
        maxWidth: Double = 400
    ) async throws -> Data {
        var image = image
        
        if image.size.height > maxHeight || image.size.width > maxWidth {
            let heightFactor = image.size.height / maxHeight
            let widthFactor = image.size.width / maxWidth
            let maxFactor = max(heightFactor, widthFactor)
            
            image = image.resized(
                to: .init(
                    width: image.size.width / maxFactor,
                    height: image.size.height / maxFactor))
        }
        
        guard var imageData = image.jpegData(compressionQuality: 0.8) else {
            throw CompressorError.noData
        }
        
        var compressionQualityFactor: CGFloat = 0.8
        if imageData.count > maxSize {
            while imageData.count > maxSize && compressionQualityFactor >= 0 {
                guard let compressedImage = UIImage(data: imageData),
                      let compressedData = compressedImage.jpegData(
                        compressionQuality: compressionQualityFactor)
                else {
                    throw CompressorError.noData
                }
                
                imageData = compressedData
                compressionQualityFactor -= 0.1
            }
        }
        
        if imageData.count > maxSize && compressionQualityFactor <= 0 {
            throw CompressorError.noData
        }
        
        return imageData
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
