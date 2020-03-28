import Alamofire
import Foundation

protocol NetworkReachabilityServiceProtocol: AnyObject {
    var networkStatus: NetworkReachabilityStatus { get }
    var connectionType: NetworkReachabilityConnectionType { get }
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

    var connectionType: NetworkReachabilityConnectionType {
        if self.reachabilityManager?.isReachableOnEthernetOrWiFi ?? false {
            return .ethernetOrWiFi
        } else if self.reachabilityManager?.isReachableOnCellular ?? false {
            return .wwan
        } else {
            return .unknown
        }
    }

    var isReachable: Bool { self.networkStatus == .reachable }

    init() {}
}

enum NetworkReachabilityStatus {
    case unknown
    case reachable
    case unreachable
}

/// Defines the various connection types detected by reachability flags.
///
/// - ethernetOrWiFi: The connection type is either over Ethernet or WiFi.
/// - wwan:           The connection type is a WWAN connection.
/// - unknown:        The connection type is unknown.
enum NetworkReachabilityConnectionType {
    case ethernetOrWiFi
    case wwan
    case unknown
}
