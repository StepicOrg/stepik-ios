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
    var delegate: NetworkReachabilityServiceDelegate? { get set }
}

protocol NetworkReachabilityServiceDelegate: class {
    func networkReachabilityStatusDidChange(newStatus: NetworkReachabilityStatus)
}

final class NetworkReachabilityService: NetworkReachabilityServiceProtocol {
    weak var delegate: NetworkReachabilityServiceDelegate? {
        didSet {
            self.reachabilityManager?.startListening()
        }
    }

    private lazy var reachabilityManager: Alamofire.NetworkReachabilityManager? = {
        let reachabilityManager = Alamofire.NetworkReachabilityManager(
            host: StepicApplicationsInfo.stepicURL
        )
        reachabilityManager?.listener = { [weak self] status in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.networkReachabilityStatusDidChange(
                newStatus: strongSelf.resolveNetworkStatus(status)
            )
        }
        return reachabilityManager
    }()

    init() { }

    private func resolveNetworkStatus(
        _ status: NetworkReachabilityManager.NetworkReachabilityStatus
    ) -> NetworkReachabilityStatus {
        switch status {
        case .notReachable:
            return .unreachable
        case .reachable(_):
            return .reachable
        default:
            return .unknown
        }
    }
}

enum NetworkReachabilityStatus {
    case unknown
    case reachable
    case unreachable
}
