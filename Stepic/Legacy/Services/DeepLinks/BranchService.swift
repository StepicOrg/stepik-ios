//
//  BranchService.swift
//  Stepic
//
//  Created by Ostrenkiy on 12/11/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import BranchSDK
import Foundation

final class BranchService {
    private let deepLinkRoutingService: DeepLinkRoutingService

    init(deepLinkRoutingService: DeepLinkRoutingService) {
        self.deepLinkRoutingService = deepLinkRoutingService
    }

    convenience init() {
        self.init(deepLinkRoutingService: DeepLinkRoutingService(courseViewSource: .deepLink(url: "branch")))
    }

    func setup(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        Branch.getInstance().initSession(launchOptions: launchOptions) { params, _ in
            guard let data = params as? [String: AnyObject] else {
                return
            }

            DispatchQueue.main.async { [weak self] in
                self?.deepLinkRoutingService.route(DeepLinkRoute(branchData: data))
            }
        }
    }

    func continueUserActivity(_ userActivity: NSUserActivity) {
        Branch.getInstance().continue(userActivity)
    }

    func openURL(
        app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any]
    ) {
        Branch.getInstance().application(app, open: url, options: options)
    }

    func canOpenWithBranch(url: URL) -> Bool {
        url.host == "stepik.app.link" || url.host == "stepik-alternate.app.link"
    }
}

// MARK: - DeepLinkRoute branch extension -

extension DeepLinkRoute {
    private enum BranchPayload: String {
        case screen
        case course
    }

    private enum BranchDeepLink: String {
        case course
    }

    init?(branchData data: [String: AnyObject]) {
        guard let screen = data[BranchPayload.screen.rawValue] as? String,
              let branchDeepLink = BranchDeepLink(rawValue: screen) else {
            return nil
        }

        switch branchDeepLink {
        case .course:
            if let idString = data[BranchPayload.course.rawValue] as? String,
               let id = Int(idString) {
                self = .course(courseID: id)
                return
            }
        }

        return nil
    }
}
