//
//  ImageFileTransferable.swift
//  Chihu
//
//  Created by Assistant on 2024.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct ImageFileTransferable: Transferable {
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .image) { receivedTransferrable in
            ImageFileTransferable(url: receivedTransferrable.localURL)
        }
    }
}

extension ReceivedTransferredFile {
    var localURL: URL {
        if isOriginalFile {
            return file
        }
        let copy = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).\(file.pathExtension)")
        try? FileManager.default.copyItem(at: file, to: copy)
        return copy
    }
}
