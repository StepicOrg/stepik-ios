//
//  BranchService.swift
//  Stepic
//
//  Created by Ostrenkiy on 12/11/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import Branch

class BranchService {
    private var deepLinkRoutingService: DeepLinkRoutingService

    init(deepLinkRoutingService: DeepLinkRoutingService) {
        self.deepLinkRoutingService = deepLinkRoutingService
    }

    func setup(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        Branch.getInstance().initSession(launchOptions: launchOptions) { params, _ in
            guard let data = params as? [String: AnyObject] else {
                return
            }

            DispatchQueue.main.async { [weak self] in
                self?.deepLinkRoutingService.route(DeepLinkRoute(data: data))
            }
        }
    }
}

//DeepLinkRoute branch extension
extension DeepLinkRoute {
    init?(data: [String: AnyObject]) {
        guard let screen = data["screen"] as? String else {
            return nil
        }

        switch screen {
        case "course":
            if let id = data["course"] as? Int {
                self = .course(courseID: id)
                return
            }
        default:
            return nil
        }
        return nil
    }
}
