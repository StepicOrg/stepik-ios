import Foundation

enum PaymentStore: String {
    case appStore = "app_store"
    case googlePlay = "google_play"

    var intValue: Int {
        switch self {
        case .appStore:
            return 1
        case .googlePlay:
            return 2
        }
    }
}
