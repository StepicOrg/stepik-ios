import Foundation

enum ProcessedContent: Equatable {
    case text(String)
    case html(String)

    var stringValue: String {
        switch self {
        case .text(let stringValue):
            return stringValue
        case .html(let stringValue):
            return stringValue
        }
    }

    var isWebViewSupportNeeded: Bool {
        switch self {
        case .text:
            return false
        case .html:
            return true
        }
    }
}
