import Alamofire
import Foundation

protocol NetworkReachabilityServiceProtocol: AnyObject {
    var networkStatus: NetworkReachabilityStatus { get }
    var isReachable: Bool { get }
}

final class NetworkReachabilityService: NetworkReachabilityServiceProtocol {
    private lazy var reachabilityManager: Alamofire.NetworkReachabilityManager? = {
        let reachabilityManager = Alamofire.NetworkReachabilityManager(
            host: StepikApplicationsInfo.stepikURL
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

    var isReachable: Bool { self.networkStatus == .reachable }

    init() { }
}

enum NetworkReachabilityStatus {
    case unknown
    case reachable
    case unreachable
}
