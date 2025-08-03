//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Dennis Nunes on 24/12/24.
//

import SwiftUI
import UIKit
import Social
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure access to extensionItem and itemProvider
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = extensionItem.attachments?.first else {
            close()
            return
        }
        
        // Check type identifier
        let textDataType = UTType.url.identifier
        if itemProvider.hasItemConformingToTypeIdentifier(textDataType) {
            // Load the item from itemProvider
            itemProvider.loadItem(forTypeIdentifier: textDataType , options: nil) { (providedText, error) in
                if let _ = error {
                    self.close()
                    return
                }
                
                if let url = providedText as? URL {
                    DispatchQueue.main.async {
                                        // host the SwiftU view
                        let searchUrlView = SearchUrlView(url: url).configureView()
                        let contentView = UIHostingController(rootView: searchUrlView)
                                        self.addChild(contentView)
                                        self.view.addSubview(contentView.view)
                                        
                                        // set up constraints
                                        contentView.view.translatesAutoresizingMaskIntoConstraints = false
                                        contentView.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
                                        contentView.view.bottomAnchor.constraint (equalTo: self.view.bottomAnchor).isActive = true
                                        contentView.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
                                        contentView.view.rightAnchor.constraint (equalTo: self.view.rightAnchor).isActive = true
                                    }
                } else {
                    self.close()
                    return
                }
            }
        } else {
            close()
            return
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("close"), object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                self.close()
            }
        }
    }

    /// Close the Share Extension
    func close() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
