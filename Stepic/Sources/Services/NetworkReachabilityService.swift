import Alamofire
import Foundation

protocol NetworkReachabilityServiceProtocol: AnyObject {
    var networkStatus: NetworkReachabilityStatus { get }
    var connectionType: NetworkReachabilityConnectionType { get }
    var isReachable: Bool { get }

    func stopListening()
    func startListening(onUpdatePerforming listener: @escaping (NetworkReachabilityStatus) -> Void)
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

    deinit {
        self.stopListening()
    }

    func stopListening() {
        self.reachabilityManager?.stopListening()
    }

    func startListening(onUpdatePerforming listener: @escaping (NetworkReachabilityStatus) -> Void) {
        self.reachabilityManager?.startListening { networkReachabilityStatus in
            listener(NetworkReachabilityStatus(networkReachabilityStatus: networkReachabilityStatus))
        }
    }
}

enum NetworkReachabilityStatus {
    case unknown
    case reachable
    case unreachable

    fileprivate init(networkReachabilityStatus: NetworkReachabilityManager.NetworkReachabilityStatus) {
        switch networkReachabilityStatus {
        case .unknown:
            self = .unknown
        case .notReachable:
            self = .unreachable
        case .reachable:
            self = .reachable
        }
    }
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
