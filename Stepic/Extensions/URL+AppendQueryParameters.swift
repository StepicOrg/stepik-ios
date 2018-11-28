//
// URL+AppendQueryParameters.swift
// stepik-ios
//
// Created by Ivan Magda on 2018-11-28.
// Copyright 2018 Stepik. All rights reserved.
//

import Foundation

extension URL {
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
            urlComponents.queryItems = items
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

    /// Append `from_mobile_app` query parameter to URL.
    mutating func appendFromMobileQueryParameter() {
        self.appendQueryParameters(["from_mobile_app": "true"])
    }
}
