//
//  URLRequest+cURL.swift
//
//  Created by Dmitry Gulyagin on 19/02/2024.
//

import struct Foundation.URLRequest

public extension URLRequest {
    
    func cURL() -> String {
        let cURL = "curl -f"
        let method = "-X \(self.httpMethod ?? "GET")"
        let url = url.flatMap { "--url '\($0.absoluteString)'" }
        
        let header = self.allHTTPHeaderFields?
            .map { "-H '\($0): \($1)'" }
            .joined(separator: " ")
        
        let data: String?
        if let httpBody, !httpBody.isEmpty {
            if let bodyString = String(data: httpBody, encoding: .utf8) { // json and plain text
                let escaped = bodyString
                    .replacingOccurrences(of: "'", with: "'\\''")
                data = "--data '\(escaped)'"
            } else { // Binary data
                let hexString = httpBody
                    .map { String(format: "%02X", $0) }
                    .joined()
                data = #"--data "$(echo '\#(hexString)' | xxd -p -r)""#
            }
        } else {
            data = nil
        }
        
        return [cURL, method, url, header, data]
            .compactMap { $0 }
            .joined(separator: " ")
    }
}
