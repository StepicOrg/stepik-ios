//
//  StepikURLSessionConfiguration.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 16.04.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class StepikURLSessionConfiguration: URLSessionConfiguration {
    override class var `default`: URLSessionConfiguration {
        let configuration = super.default
        configuration.timeoutIntervalForRequest = 10

        var headers: [AnyHashable: Any] = configuration.httpAdditionalHeaders ?? [:]
        headers["User-Agent"] = StepikURLSessionConfiguration.buildUserAgent()
        configuration.httpAdditionalHeaders = headers

        return configuration
    }

    private static func buildUserAgent() -> String {
        guard let bundleID = Bundle.main.bundleIdentifier,
              let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String else {
            return "Stepik (iOS app)"
        }

        let osVersion = [
            "\(DeviceInfo.current.OSVersion.major)",
            "\(DeviceInfo.current.OSVersion.minor)",
            "\(DeviceInfo.current.OSVersion.patch)"
        ].joined(separator: ".")

        return "Stepik/\(version) (\(bundleID); build \(build); iOS \(osVersion))"
    }
}
