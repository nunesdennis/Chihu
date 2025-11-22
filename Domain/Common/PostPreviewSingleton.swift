//
//  PostPreviewSingleton.swift
//  Chihu


import UIKit

class PostPreviewSingleton {
    static let shared = PostPreviewSingleton()
    
    private var dictionaryLock = NSLock()
    private var _imageDictionary: [String : URL] = [:]
    // Post id : url
    var imagesDictionary: [String : URL] {
        get {
            dictionaryLock.lock()
            defer { dictionaryLock.unlock() }
            return _imageDictionary
        }
        
        set {
            dictionaryLock.lock()
            _imageDictionary = newValue
            dictionaryLock.unlock()
        }
    }
}
