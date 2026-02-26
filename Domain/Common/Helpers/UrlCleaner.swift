//
//  UrlCleaner.swift
//  Chihu
//
//

import Foundation

class UrlCleaner {
    static let neodbItemIdentifier = "~neodb~"
    
    static func keepSiteName(from url: URL) -> String {
        guard let host = url.host else {
            return url.absoluteString
        }

        // Divide o host por "." e pega os dois últimos componentes (nome + TLD)
        let componentes = host.components(separatedBy: ".")
        
        // Garante que tem ao menos 2 componentes (ex: google + com)
        guard componentes.count >= 2 else {
            return url.absoluteString
        }

        let dominioETLD = componentes.suffix(2).joined(separator: ".")
        return dominioETLD
    }
}
