//
//  NetworkReachabilityService.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 09.10.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire

protocol NetworkReachabilityServiceProtocol: class {
    var networkStatus: NetworkReachabilityStatus { get }
    var isReachable: Bool { get }
}

final class NetworkReachabilityService: NetworkReachabilityServiceProtocol {
    private lazy var reachabilityManager: Alamofire.NetworkReachabilityManager? = {
        let reachabilityManager = Alamofire.NetworkReachabilityManager(
            host: StepicApplicationsInfo.stepicURL
        )
        return reachabilityManager
    }()

    var networkStatus: NetworkReachabilityStatus {
        switch self.reachabilityManager?.isReachable {
        case .some(true):
            return .reachable
        case .some(false):
            return .unreachable
        case .none:
            return .unknown
        }
    }

    var isReachable: Bool {
        return self.networkStatus == .reachable
    }

    init() { }
}

enum NetworkReachabilityStatus {
    case unknown
    case reachable
    case unreachable
}
