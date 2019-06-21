//
// URL+AppendQueryParameters.swift
// stepik-ios
//
// Created by Ivan Magda on 2018-11-28.
// Copyright 2018 Stepik. All rights reserved.
//

import Foundation

extension URL {
    /// Check for existing percent escapes first to prevent double-escaping of % character and initialize with encoded string.
    ///
    /// Returns `nil` if a `URL` cannot be formed with the string.
    init?(stringToEncode: String) {
        if stringToEncode.range(of: "%[0-9A-Fa-f]{2}", options: .regularExpression) != nil {
            self.init(string: stringToEncode)
        } else if let encodedString = stringToEncode.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            self.init(string: encodedString)
        } else {
            return nil
        }
    }

    /// URL with appending query parameters.
    ///
    /// - Parameter parameters: parameters dictionary.
    /// - Returns: URL with appending given query parameters.
    func appendingQueryParameters(_ parameters: [String: String]) -> URL? {
        if var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) {
            var items = urlComponents.queryItems ?? []
            items += parameters.map {
                URLQueryItem(name: $0, value: $1)
            }
            urlComponents.queryItems = Array(Set(items))
            return urlComponents.url
        } else {
            return nil
        }
    }

    /// Append query parameters to URL.
    ///
    /// - Parameter parameters: parameters dictionary.
    mutating func appendQueryParameters(_ parameters: [String: String]) {
        if let url = self.appendingQueryParameters(parameters) {
            self = url
        }
    }
}
